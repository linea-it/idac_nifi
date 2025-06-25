#!/usr/bin/python3

import sys
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from io import StringIO, BytesIO

# Lê o conteúdo do FlowFile do stdin
flowfile_content = sys.stdin.read()

# Assume que o texto é um CSV (ajuste para JSON se necessário)
csv_data = StringIO(flowfile_content)

# Converte o texto para um DataFrame do pandas
df = pd.read_csv(csv_data)

# Converte o DataFrame para Parquet em uma variável
parquet_buffer = BytesIO()
table = pa.Table.from_pandas(df)
pq.write_table(table, parquet_buffer)

# Retorna o conteúdo Parquet como binário (pode ser usado em FlowFile)
sys.stdout.buffer.write(parquet_buffer.getvalue())