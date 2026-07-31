#!/bin/bash

#=============================================================================
# Scan Directories - Rubin Data Preview
# Created by nubia.garcia (nubia.garcia@linea.org.br) - 2025-12-01
# Based Eloir's code.
#
# Esse script foi criado para ser inserido no pipeline do NiFi
#
# ./scan_data.sh <dir_origem>
# =============================================================================

if [ $# -ne 1 ]; then
    echo "Uso: $0 <dir_origem>"
    exit 1
fi

ORIGEM="$1"

if [ ! -d "$ORIGEM" ]; then
    echo "Error: $ORIGEM This is not a valid path."
    exit 1
fi

# Arquivo que contem apenas a o valor total de arquivos
QT_ARQ="/scratch/users/app.nifi/data_transfer/qt_arq.txt"

total_volume=0
count_hsp=0
count_fits=0
count_parquet=0
count_tracts=0
count_total=0


# Salva a lista de diretórios em um arquivo temporário
# para evitar problemas com subshell
tmpfile=$(mktemp)

find "$ORIGEM" -type d > "$tmpfile"

# Loop pelos diretórios
while read -r dir; do

    # Lista os arquivos diretamente dentro deste diretório
    files=$(find "$dir" -maxdepth 1 -type f 2>/dev/null)

    if [ -n "$files" ]; then
        echo "Path to files found: $dir"

        for file in $files; do

            # Soma tamanho do arquivo
            size=$(stat -c%s "$file" 2>/dev/null)
            total_volume=$((total_volume + size))

            # Conta arquivos por extensão
            case "$file" in

                *.hsp)
                    count_hsp=$((count_hsp + 1))
                    count_total=$((count_total + 1))
                    ;;

                *.fits)
                    count_fits=$((count_fits + 1))
                    count_total=$((count_total + 1))
                    ;;

                *.parq|*.parquet)
                    count_parquet=$((count_parquet + 1))
                    count_total=$((count_total + 1))
                    ;;

            esac

        done

        echo
    fi

done < "$tmpfile"

rm "$tmpfile"


#=============================================================================
# Salva somente a quantidade total de arquivos
#=============================================================================

echo "$count_total" > "$QT_ARQ"


#=============================================================================
# Resumo
#=============================================================================

echo "=== Details ==="
echo "Total Volume (bytes): $total_volume"
echo "Total .hsp          : $count_hsp"
echo "Total .fits         : $count_fits"
echo "Total .parq/.parquet: $count_parquet"
echo "Total files         : $count_total"
