#!/bin/bash

# ============================================================
# Move dados após a criação do qt_arq.txt
#
# Uso:
#   ./move_data.sh <diretorio_origem> <diretorio_destino>
# ============================================================

DATA_TRANSFER="/scratch/users/app.nifi/data_transfer"
QT_ARQ="$DATA_TRANSFER/qt_arq.txt"
ARQ_MOVE="$DATA_TRANSFER/move.completed"

DATA_ORIGEM="$1"
DATA_DESTINO="$2"

# ------------------------------------------------------------
# Verifica parâmetros
# ------------------------------------------------------------

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <diretorio_origem> <diretorio_destino>"
    exit 1
fi

if [ ! -d "$DATA_ORIGEM" ]; then
    echo "ERRO: diretório de origem não existe:"
    echo "$DATA_ORIGEM"
    exit 1
fi

mkdir -p "$DATA_DESTINO"

# ------------------------------------------------------------
# Aguarda qt_arq.txt
# ------------------------------------------------------------

while [ ! -f "$QT_ARQ" ]; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - qt_arq.txt ainda não existe. Aguardando..."
    sleep 10
done

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - qt_arq.txt encontrado!"
echo

# ------------------------------------------------------------
# Inicia movimentação
# ------------------------------------------------------------

echo "Origem : $DATA_ORIGEM"
echo "Destino: $DATA_DESTINO"
echo

echo "Iniciando movimentação dos arquivos..."

rsync -av --info=progress2 \
    --remove-source-files \
    --ignore-existing \
    --prune-empty-dirs \
    "$DATA_ORIGEM/" "$DATA_DESTINO/"

STATUS=$?

# ------------------------------------------------------------
# Resultado
# ------------------------------------------------------------

if [ $STATUS -eq 0 ]; then
    echo
    echo "============================================================"
    echo "Movimentação concluída com sucesso."
    echo "============================================================"
    touch "$ARQ_MOVE"
else
    echo
    echo "============================================================"
    echo "ERRO durante a movimentação."
    echo "Código de retorno do rsync: $STATUS"
    echo "============================================================"
    exit $STATUS
fi
echo
