#!/usr/bin/python3

import duckdb

fileSourcePath = '/opt/nifi/nifi-current/files/input'
fileDestinationPath = '/opt/nifi/nifi-current/files/output'
fileName = 'super-trunfo-dinossaurs-2-duckdb'

readParquet = duckdb.sql(f''' SELECT * FROM read_parquet('{fileSourcePath}/{fileName}.parquet') ''').to_df()

readParquet.columns = [col.upper() for col in readParquet.columns]

readParquet.to_parquet(f"{fileDestinationPath}/{fileName}.parquet", index=False, engine='pyarrow')
