#!/bin/bash

DATA_ORIGEM="$1"
DATA_DESTINO="$2"
DATA_TRANSFER="/scratch/users/app.nifi/data_transfer"

ARQ_FLAG="$DATA_TRANSFER/move.completed"

# ============================================================
# AGUARDA ARQUIVO FLAG
# ============================================================

while [ ! -f "$ARQ_FLAG" ]; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ARQ FLAG ainda não existe. Aguardando..."
    sleep 30
done

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - ARQ FLAG encontrado!"
echo

# ============================================================
# CRIA OS LINKS SIMBÓLICOS
# ============================================================

echo
echo "Criando links simbólicos..."

find "$DATA_DESTINO" -type f -print0 | while IFS= read -r -d '' ARQUIVO_DESTINO; do

    # Caminho relativo em relação ao data_destino
    CAMINHO_RELATIVO="${ARQUIVO_DESTINO#$DATA_DESTINO/}"

    # Caminho onde o link será criado no data_origem
    LINK="$DATA_ORIGEM/$CAMINHO_RELATIVO"

    # Cria os subdiretórios necessários
    mkdir -p "$(dirname "$LINK")"

    # Cria o link simbólico apontando para o arquivo em data_destino
    ln -s "$ARQUIVO_DESTINO" "$LINK"

    echo "$LINK -> $ARQUIVO_DESTINO"

done


# ============================================================
# 4. VERIFICA SE TODOS OS LINKS FORAM CRIADOS
# ============================================================

QT_LINKS=$(find "$DATA_ORIGEM" -type l | wc -l)

echo
echo "=================================================="
echo "Links criados      : $QT_LINKS"
echo "Date		 : $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================="
