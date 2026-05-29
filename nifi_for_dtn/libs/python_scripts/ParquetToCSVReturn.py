#!/usr/bin/python3

import sys
import pandas as pd
from io import BytesIO, StringIO

# Lê o conteúdo Parquet do FlowFile (stdin) como binário
parquet_data = BytesIO(sys.stdin.buffer.read())

# Carrega o arquivo Parquet em um DataFrame do pandas
df = pd.read_parquet(parquet_data)

# Converte o DataFrame para CSV em memória
csv_buffer = StringIO()
df.to_csv(csv_buffer, index=False)

# Escreve o CSV resultante no stdout (para ser usado pelo FlowFile)
sys.stdout.write(csv_buffer.getvalue())