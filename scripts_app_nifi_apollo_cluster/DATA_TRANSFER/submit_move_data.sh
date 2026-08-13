#!/bin/bash
#SBATCH -p cpu_pipelines
#SBATCH --account=hpc-pipelines
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-move_data_DP1
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/data_transfer/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/data_transfer/logs/%x-%j.err

# --------------------------
# SETUP VARIAVEIS
# --------------------------
BASE_DIR=/scratch/users/app.nifi/data_transfer
SCRIPTS_DIR=/scripts/app.nifi

DATA_ORIGEM="$1"
DATA_DESTINO="$2"

# -----------------------------------
# EXECUTE SCRIPT
# -----------------------------------

EXEC=$SCRIPTS_DIR/DATA_TRANSFER/move_data.sh

srun "$EXEC" "$DATA_ORIGEM" "$DATA_DESTINO"
