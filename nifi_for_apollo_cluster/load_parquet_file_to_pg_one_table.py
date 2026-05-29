import duckdb
import os
import concurrent.futures
import time
import sys


if len(sys.argv) <= 5:
    print('Insufficient arguments')
    sys.exit()



# PostgreSQL parameters
## connection string Postgres
PG_CONN = sys.argv[1] # example PG_CONN: "user=app.postgres dbname=lsst_dp02_dc2"
## schema and table to import data
SCHEMA_NAME = sys.argv[2]
TABLE_NAME = sys.argv[3]

# directory where are the parquet files
DATA_DIR = sys.argv[4]

# parallel jobs
MAX_WORKERS = int(sys.argv[5])





## MAP COLUMNS TO NORMALIZED TABLES
GROUP_COLUMN_MAP = {
        'grupo00': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "coord_dec", "coord_ra", "detect_isPrimary", "patch", "tract", "refBand", "refExtendedness" ],
        'grupo01': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "deblend_nChild", "deblend_skipped", "detect_fromBlend", "detect_isDeblendedModelSource", "detect_isDeblendedSource", "detect_isIsolated", "detect_isPatchInner", "detect_isTractInner", "footprintArea", "g_extendedness", "g_extendedness_flag", "i_extendedness", "i_extendedness_flag", "parentObjectId", "r_extendedness", "r_extendedness_flag", "shape_flag", "shape_xx", "shape_xy", "shape_yy", "sky_object", "skymap", "u_extendedness", "u_extendedness_flag", "y_extendedness", "y_extendedness_flag", "z_extendedness", "z_extendedness_flag" ],
        'grupo02': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_cModel_flag", "g_cModel_flag_apCorr", "g_cModelFlux", "g_cModelFlux_inner", "g_cModelFluxErr", "i_cModel_flag", "i_cModel_flag_apCorr", "i_cModelFlux", "i_cModelFlux_inner", "i_cModelFluxErr", "r_cModel_flag", "r_cModel_flag_apCorr", "r_cModelFlux", "r_cModelFlux_inner", "r_cModelFluxErr", "u_cModel_flag", "u_cModel_flag_apCorr", "u_cModelFlux", "u_cModelFlux_inner", "u_cModelFluxErr", "y_cModel_flag", "y_cModel_flag_apCorr", "y_cModelFlux", "y_cModelFlux_inner", "y_cModelFluxErr", "z_cModel_flag", "z_cModel_flag_apCorr", "z_cModelFlux", "z_cModelFlux_inner", "z_cModelFluxErr" ],
        'grupo03': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_free_cModelFlux", "g_free_cModelFlux_flag", "g_free_cModelFlux_inner", "g_free_cModelFluxErr", "i_free_cModelFlux", "i_free_cModelFlux_flag", "i_free_cModelFlux_inner", "i_free_cModelFluxErr", "r_free_cModelFlux", "r_free_cModelFlux_flag", "r_free_cModelFlux_inner", "r_free_cModelFluxErr", "u_free_cModelFlux", "u_free_cModelFlux_flag", "u_free_cModelFlux_inner", "u_free_cModelFluxErr", "y_free_cModelFlux", "y_free_cModelFlux_flag", "y_free_cModelFlux_inner", "y_free_cModelFluxErr", "z_free_cModelFlux", "z_free_cModelFlux_flag", "z_free_cModelFlux_inner", "z_free_cModelFluxErr" ],
        'grupo04': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_psfFlux", "g_psfFlux_area", "g_psfFlux_flag", "g_psfFlux_flag_apCorr", "g_psfFlux_flag_edge", "g_psfFlux_flag_noGoodPixels", "g_psfFluxErr", "i_psfFlux", "i_psfFlux_area", "i_psfFlux_flag", "i_psfFlux_flag_apCorr", "i_psfFlux_flag_edge", "i_psfFlux_flag_noGoodPixels", "i_psfFluxErr", "r_psfFlux", "r_psfFlux_area", "r_psfFlux_flag", "r_psfFlux_flag_apCorr", "r_psfFlux_flag_edge", "r_psfFlux_flag_noGoodPixels", "r_psfFluxErr", "u_psfFlux", "u_psfFlux_area", "u_psfFlux_flag", "u_psfFlux_flag_apCorr", "u_psfFlux_flag_edge", "u_psfFlux_flag_noGoodPixels", "u_psfFluxErr", "y_psfFlux", "y_psfFlux_area", "y_psfFlux_flag", "y_psfFlux_flag_apCorr", "y_psfFlux_flag_edge", "y_psfFlux_flag_noGoodPixels", "y_psfFluxErr", "z_psfFlux", "z_psfFlux_area", "z_psfFlux_flag", "z_psfFlux_flag_apCorr", "z_psfFlux_flag_edge", "z_psfFlux_flag_noGoodPixels", "z_psfFluxErr" ],
        'grupo05': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_free_psfFlux", "g_free_psfFlux_flag", "g_free_psfFluxErr", "i_free_psfFlux", "i_free_psfFlux_flag", "i_free_psfFluxErr", "r_free_psfFlux", "r_free_psfFlux_flag", "r_free_psfFluxErr", "u_free_psfFlux", "u_free_psfFlux_flag", "u_free_psfFluxErr", "y_free_psfFlux", "y_free_psfFlux_flag", "y_free_psfFluxErr", "z_free_psfFlux", "z_free_psfFlux_flag", "z_free_psfFluxErr" ],
        'grupo06': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_bdE1", "g_bdE2", "g_bdReB", "g_bdReD", "i_bdE1", "i_bdE2", "i_bdReB", "i_bdReD", "r_bdE1", "r_bdE2", "r_bdReB", "r_bdReD", "u_bdE1", "u_bdE2", "u_bdReB", "u_bdReD", "y_bdE1", "y_bdE2", "y_bdReB", "y_bdReD", "z_bdE1", "z_bdE2", "z_bdReB", "z_bdReD" ],
        'grupo07': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap0p5Flux", "g_gaap0p5Flux_flag_bigPsf", "g_gaap0p5FluxErr", "i_gaap0p5Flux", "i_gaap0p5Flux_flag_bigPsf", "i_gaap0p5FluxErr", "r_gaap0p5Flux", "r_gaap0p5Flux_flag_bigPsf", "r_gaap0p5FluxErr", "u_gaap0p5Flux", "u_gaap0p5Flux_flag_bigPsf", "u_gaap0p5FluxErr", "y_gaap0p5Flux", "y_gaap0p5Flux_flag_bigPsf", "y_gaap0p5FluxErr", "z_gaap0p5Flux", "z_gaap0p5Flux_flag_bigPsf", "z_gaap0p5FluxErr" ],
        'grupo08': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap0p7Flux", "g_gaap0p7Flux_flag_bigPsf", "g_gaap0p7FluxErr", "i_gaap0p7Flux", "i_gaap0p7Flux_flag_bigPsf", "i_gaap0p7FluxErr", "r_gaap0p7Flux", "r_gaap0p7Flux_flag_bigPsf", "r_gaap0p7FluxErr", "u_gaap0p7Flux", "u_gaap0p7Flux_flag_bigPsf", "u_gaap0p7FluxErr", "y_gaap0p7Flux", "y_gaap0p7Flux_flag_bigPsf", "y_gaap0p7FluxErr", "z_gaap0p7Flux", "z_gaap0p7Flux_flag_bigPsf", "z_gaap0p7FluxErr" ],
        'grupo09': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap1p0Flux", "g_gaap1p0Flux_flag_bigPsf", "g_gaap1p0FluxErr", "i_gaap1p0Flux", "i_gaap1p0Flux_flag_bigPsf", "i_gaap1p0FluxErr", "r_gaap1p0Flux", "r_gaap1p0Flux_flag_bigPsf", "r_gaap1p0FluxErr", "u_gaap1p0Flux", "u_gaap1p0Flux_flag_bigPsf", "u_gaap1p0FluxErr", "y_gaap1p0Flux", "y_gaap1p0Flux_flag_bigPsf", "y_gaap1p0FluxErr", "z_gaap1p0Flux", "z_gaap1p0Flux_flag_bigPsf", "z_gaap1p0FluxErr" ],
        'grupo10': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap1p5Flux", "g_gaap1p5Flux_flag_bigPsf", "g_gaap1p5FluxErr", "i_gaap1p5Flux", "i_gaap1p5Flux_flag_bigPsf", "i_gaap1p5FluxErr", "r_gaap1p5Flux", "r_gaap1p5Flux_flag_bigPsf", "r_gaap1p5FluxErr", "u_gaap1p5Flux", "u_gaap1p5Flux_flag_bigPsf", "u_gaap1p5FluxErr", "y_gaap1p5Flux", "y_gaap1p5Flux_flag_bigPsf", "y_gaap1p5FluxErr", "z_gaap1p5Flux", "z_gaap1p5Flux_flag_bigPsf", "z_gaap1p5FluxErr" ],
        'grupo11': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap2p5Flux", "g_gaap2p5Flux_flag_bigPsf", "g_gaap2p5FluxErr", "i_gaap2p5Flux", "i_gaap2p5Flux_flag_bigPsf", "i_gaap2p5FluxErr", "r_gaap2p5Flux", "r_gaap2p5Flux_flag_bigPsf", "r_gaap2p5FluxErr", "u_gaap2p5Flux", "u_gaap2p5Flux_flag_bigPsf", "u_gaap2p5FluxErr", "y_gaap2p5Flux", "y_gaap2p5Flux_flag_bigPsf", "y_gaap2p5FluxErr", "z_gaap2p5Flux", "z_gaap2p5Flux_flag_bigPsf", "z_gaap2p5FluxErr" ],
        'grupo12': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaap3p0Flux", "g_gaap3p0Flux_flag_bigPsf", "g_gaap3p0FluxErr", "i_gaap3p0Flux", "i_gaap3p0Flux_flag_bigPsf", "i_gaap3p0FluxErr", "r_gaap3p0Flux", "r_gaap3p0Flux_flag_bigPsf", "r_gaap3p0FluxErr", "u_gaap3p0Flux", "u_gaap3p0Flux_flag_bigPsf", "u_gaap3p0FluxErr", "y_gaap3p0Flux", "y_gaap3p0Flux_flag_bigPsf", "y_gaap3p0FluxErr", "z_gaap3p0Flux", "z_gaap3p0Flux_flag_bigPsf", "z_gaap3p0FluxErr" ],
        'grupo13': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaapFlux_flag", "g_gaapFlux_flag_edge", "g_gaapFlux_flag_gaussianization", "i_gaapFlux_flag", "i_gaapFlux_flag_edge", "i_gaapFlux_flag_gaussianization", "r_gaapFlux_flag", "r_gaapFlux_flag_edge", "r_gaapFlux_flag_gaussianization", "u_gaapFlux_flag", "u_gaapFlux_flag_edge", "u_gaapFlux_flag_gaussianization", "y_gaapFlux_flag", "y_gaapFlux_flag_edge", "y_gaapFlux_flag_gaussianization", "z_gaapFlux_flag", "z_gaapFlux_flag_edge", "z_gaapFlux_flag_gaussianization" ],
        'grupo14': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaapOptimalFlux", "g_gaapOptimalFlux_flag_bigPsf", "g_gaapOptimalFluxErr", "i_gaapOptimalFlux", "i_gaapOptimalFlux_flag_bigPsf", "i_gaapOptimalFluxErr", "r_gaapOptimalFlux", "r_gaapOptimalFlux_flag_bigPsf", "r_gaapOptimalFluxErr", "u_gaapOptimalFlux", "u_gaapOptimalFlux_flag_bigPsf", "u_gaapOptimalFluxErr", "y_gaapOptimalFlux", "y_gaapOptimalFlux_flag_bigPsf", "y_gaapOptimalFluxErr", "z_gaapOptimalFlux", "z_gaapOptimalFlux_flag_bigPsf", "z_gaapOptimalFluxErr" ],
        'grupo15': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "g_gaapPsfFlux", "g_gaapPsfFluxErr", "i_gaapPsfFlux", "i_gaapPsfFluxErr", "r_gaapPsfFlux", "r_gaapPsfFluxErr", "u_gaapPsfFlux", "u_gaapPsfFluxErr", "y_gaapPsfFlux", "y_gaapPsfFluxErr", "z_gaapPsfFlux", "z_gaapPsfFluxErr" ],
        'grupo00': [ "objectId /*% (pow(10,floor(log(objectId::bigint))))::bigint as objectId */", "coord_dec", "coord_ra", "detect_isPrimary", "patch", "tract", "refBand", "refExtendedness" ],

}



def get_table_name(filename):
    base_name = filename.replace(".parq", "")
    truncated_name = base_name[:63]
    #return f'postgres_db.import_parquet_dest_duckto_330.\"{truncated_name}\"'
    #return f'postgres_db.import_parquet_dest_duckto_330.\"objects_all"'
    #return f'postgres_db.teste_normalizacao_vazio.\"objects_all"'
    return f'postgres_db.{SCHEMA_NAME}.\"{TABLE_NAME}"'

def insert_with_columns_from_parquet_to_postgres(parquet_file):
    table_name = get_table_name(parquet_file)
    file_path = os.path.join(DATA_DIR, parquet_file)

    start_time = time.time()
    print(f"🔄 [{start_time}] Iniciando importação: {parquet_file}")

    try:
        with duckdb.connect() as con:
            con.execute("install postgres;")
            con.execute("load postgres;")

            con.execute(f"attach '{PG_CONN}' as postgres_db (type postgres, schema 'teste_normalizacao_vazio');")

            for group_name, columns in GROUP_COLUMN_MAP.items():
                columns_str = ','.join(columns)
                copy_sql = f"""
                insert into postgres_db.teste_normalizacao_vazio.objects_{group_name} 
                select {columns_str} 
                from read_parquet('{file_path}', compression = 'none');
                """

                print(f"🔄 [{start_time}] Iniciando importação de grupo: {group_name} ({parquet_file}")
                con.execute(copy_sql)
                print(f"🔄 [{start_time}] Finalizada importação de grupo: {group_name} ({parquet_file})")


        end_time = time.time()
        elapsed_time = end_time - start_time
        print(f"✅ [{end_time}] Concluído: {parquet_file} -> {table_name} em {elapsed_time:.2f} segundos")

    except Exception as e:
        print(f"❌ Erro ao importar {parquet_file}: {e}")


# FUNCTION TO LOAD PARQUET FILES TO ONLY ONE TABLE
def copy_parquet_to_postgres(parquet_file):
    table_name = get_table_name(parquet_file)
    file_path = os.path.join(DATA_DIR, parquet_file)


    start_time = time.time()
    print(f"🔄 [{start_time}] Iniciando importação: {parquet_file} -> {table_name}")

    try:
        with duckdb.connect() as con:
            con.execute("install postgres;")
            con.execute("load postgres;")

            con.execute(f"attach '{PG_CONN}' as postgres_db (type postgres, schema '{SCHEMA_NAME}');")
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
    parquet_files = [f for f in os.listdir(DATA_DIR) if f.endswith(".parq")]

    start_time = time.time()
    print(f"🚀 [{start_time}] Iniciando importação de {len(parquet_files)} arquivos...")

    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        executor.map(copy_parquet_to_postgres, parquet_files)
        #executor.map(insert_with_columns_from_parquet_to_postgres, parquet_files)

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"✅ [{end_time}] Importação finalizada em {elapsed_time:.2f} segundos!")

if __name__ == "__main__":
    main()
