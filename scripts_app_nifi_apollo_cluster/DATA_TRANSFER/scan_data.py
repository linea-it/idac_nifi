# This python script collects information from a given directory searching for LSST data preview or data release content.
# It was developed based on DP1 content and may need changes for future releases.

# How to use:
# Activate the env: conda activate /scripts/app.nifi/ENV/workenv;
# python3 <scriptname>.py <content base directory>

import os
import sys
import datetime
import duckdb
import json

def main():

    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <diretorio>")
        sys.exit(1)

    diretorio = sys.argv[1]
    if not os.path.isdir(diretorio):
        print(f"Erro: {diretorio} não é um diretório válido")
        sys.exit(1)

    con = duckdb.connect()

    total_registros = 0
    colunas_distintas = set()
    tracts = set()
    total_volume = 0
    count_hsp = 0
    count_fits = 0
    count_parq = 0

    # Loop no diretório (recursivo)
    for root, _, files in os.walk(diretorio):
        for filename in files:
            filepath = os.path.join(root, filename)

            # Soma tamanho do arquivo
            try:
                total_volume += os.path.getsize(filepath)
            except OSError:
                pass

            # Contagem por extensão
            if filename.endswith(".hsp"):
                count_hsp += 1
            elif filename.endswith(".fits"):
                count_fits += 1
            elif filename.endswith((".parq",".parquet")):
                count_parq += 1

                # Trecho processado com DuckDB
                try:
                    n_registros = con.execute(
                        f"SELECT COUNT(*) FROM parquet_scan('{filepath}')"
                    ).fetchone()[0]
                    total_registros += n_registros

                    cols = con.execute(
                        f"DESCRIBE SELECT * FROM parquet_scan('{filepath}')"
                    ).fetchdf()
                    colunas_distintas.update(cols["column_name"].values)

                    # Junta tracts (se existir)
                    if "tract" in cols["column_name"].values:
                        df_tracts = con.execute(
                            f"SELECT DISTINCT tract FROM parquet_scan('{filepath}')"
                        ).fetchdf()

                        # remove valores nulos
                        df_tracts = df_tracts.dropna()

                        if not df_tracts.empty:
                            tracts.update(df_tracts["tract"].tolist())
                        else:
                            # coluna existe, mas está vazia
                            dirname = os.path.basename(root)
                            tracts.add(f"{dirname}")

                except Exception as e:
                    print(f"Erro ao processar {filepath}: {e}")


    # separa tracts numéricos e tracts marcados como vazios
    numeric_tracts = sorted([t for t in tracts if isinstance(t, (int, float))])
    empty_tracts = sorted([t for t in tracts if isinstance(t, str)])


    total_volume_gb = round(total_volume / (1024 ** 3), 2)

    # Monta o dicionário com os campos desejados
    dados = {
        "last_updt": str(datetime.datetime.now()).split('.')[0],
        "total_vol": total_volume,
        "total_vol_gb": total_volume_gb,
        "total_obj": total_registros,
        "total_col": len(colunas_distintas),
        "total_hsp": count_hsp,
        "total_fits": count_fits,
        "total_parq": count_parq,
        "total_tracts": len(numeric_tracts) + len(empty_tracts),
        "list_tracts": numeric_tracts,
        "empty_tracts": empty_tracts
    }

    # Caminho dos arquivos de saída
    output_dir = "/scratch/users/app.nifi/data_transfer"
    json_file = os.path.join(output_dir, "scan_data.json")
    count_file = os.path.join(output_dir, "qt_arq.txt")

    # Garante que o diretório exista
    os.makedirs(output_dir, exist_ok=True)

    # Escreve o arquivo JSON
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(dados, f, indent=4)

    # Soma o total de arquivos
    total_arquivos = count_hsp + count_fits + count_parq

    # Escreve apenas o número no arquivo qt_arq.txt
    with open(count_file, "w", encoding="utf-8") as f:
        f.write(f"{total_arquivos}\n")


if __name__ == "__main__":
    main()
