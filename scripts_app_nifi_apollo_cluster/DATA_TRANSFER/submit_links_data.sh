#!/bin/bash
#SBATCH -p cpu_pipelines
#SBATCH --account=hpc-pipelines
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-links_data_DP1
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/data_transfer/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/data_transfer/logs/%x-%j.err

# --------------------------
# SETUP VARIAVEIS
# --------------------------

DATARELEASE=DP1

BASE_DIR=/scratch/users/app.nifi/data_transfer
SCRIPTS_DIR=/scripts/app.nifi

ARQ_FINISHED="$BASE_DIR/mv.finished"

ORIGEM_DIR="$1"
DESTINO_DIR="$2"

# -----------------------------------
# EXECUTE SCRIPT
# -----------------------------------

EXEC=$SCRIPTS_DIR/DATA_TRANSFER/links_for_data.sh

srun "$EXEC" "$ORIGEM_DIR" "$DESTINO_DIR"

#--------------------------
# CHECK ARQ IN FINAL DIR
#--------------------------

$SCRIPTS_DIR/DATA_TRANSFER/scan_data.py "$DESTINO_DIR"

touch "$ARQ_FINISHED"
