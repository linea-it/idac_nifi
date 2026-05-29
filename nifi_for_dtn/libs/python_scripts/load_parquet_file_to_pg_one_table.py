import duckdb
import os
import concurrent.futures
import time
import sys

PG_CONN = "host=10.148.0.90 port=5432 user=user_nifi dbname=nifi"
#DATA_DIR = "/lustre/t1/cl/lsst/dp02/primary/catalogs/object"
#DATA_DIR = "/lustre/t0/scratch/users/luigi.silva/issue_3_criar_arquivos_para_ingestao_no_postgres/run_2025-02-17_14-08/data"
DATA_DIR = "/data/staging/dp02/"
MAX_WORKERS = 15

def get_table_name(filename):
    base_name = filename.replace(".parq", "")
    truncated_name = base_name[:63]
    #return f'postgres_db.import_parquet_dest_duckto_330.\"{truncated_name}\"'
    return f'postgres_db.import_parquet_dest_duckto_330.\"objects_all"'

def copy_parquet_to_postgres(parquet_file):
    table_name = get_table_name(parquet_file)
    file_path = os.path.join(DATA_DIR, parquet_file)


    start_time = time.time()
    print(f"🔄 [{start_time}] Iniciando importação: {parquet_file} -> {table_name}")

    try:
        with duckdb.connect() as con:
            con.execute("install postgres;")
            con.execute("load postgres;")

            con.execute(f"attach '{PG_CONN}' as postgres_db (type postgres, schema 'import_parquet_dest_duckto_330');")
            copy_sql = f"""
            copy {table_name} from '{file_path}'
            with (compression none, format parquet);
            """
            con.execute(copy_sql)

        end_time = time.time()
        elapsed_time = end_time - start_time
        print(f"✅ [{end_time}] Concluído: {parquet_file} -> {table_name} em {elapsed_time:.2f} segundos")

    except Exception as e:
        print(f"❌ Erro ao importar {parquet_file}: {e}")

def main():
#    parquet_files = [f for f in os.listdir(DATA_DIR) if f.endswith(".parq")]
    parquet_files = sys.argv[1]
    start_time = time.time()
    print(f"🚀 [{start_time}] Iniciando importação de {len(parquet_files)} arquivos...")

    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        executor.map(copy_parquet_to_postgres, parquet_files)

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"✅ [{end_time}] Importação finalizada em {elapsed_time:.2f} segundos!")

if __name__ == "__main__":
    main()
