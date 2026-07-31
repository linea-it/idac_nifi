#!/bin/bash

DATA_ORIGEM="/scratch/users/app.nifi/data_origem"
DATA_DESTINO="/scratch/users/app.nifi/data_destino"
DATA_TRANSFER="/scratch/users/app.nifi/data_transfer"

ARQ_QT="$DATA_TRANSFER/qt_arq.txt"
ARQ_FINISHED="$DATA_TRANSFER/mv.finished"

INTERVALO=30


# ============================================================
# VERIFICA A QT DE ARQ PRESENTES NO DIRETORIO DESTINO
# ============================================================

QT_ORIGEM=$(cat "$ARQ_QT")

echo "Quantidade esperada: $QT_ORIGEM"
echo "Aguardando arquivos em: $DATA_DESTINO"


# ============================================================
# AGUARDA TODOS OS ARQUIVOS CHEGAREM NO DATA_DESTINO
# ============================================================

while true; do

    QT_DESTINO=$(find "$DATA_DESTINO" -type f | wc -l)

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Esperados: $QT_ORIGEM | Encontrados: $QT_DESTINO"

    if [ "$QT_DESTINO" -eq "$QT_ORIGEM" ]; then
        echo "Todos os arquivos foram movidos."
        break
    fi

    sleep "$INTERVALO"

done


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
echo "============================================"
echo "Arquivos esperados : $QT_ORIGEM"
echo "Arquivos no destino: $QT_DESTINO"
echo "Links criados      : $QT_LINKS"
echo "============================================"

touch "$ARQ_FINISHED"
