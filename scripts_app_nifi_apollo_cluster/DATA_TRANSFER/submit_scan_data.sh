#!/bin/bash
#SBATCH -p cpu_pipelines
#SBATCH --account=hpc-pipelines
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-scan_data_DP1
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/data_transfer/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/data_transfer/logs/%x-%j.err

# --------------------------
# SETUP VARIAVEIS
# --------------------------

DATARELEASE=DP1

BASE_DIR=/scratch/users/app.nifi/data_transfer
SCRIPTS_DIR=/scripts/app.nifi
ENV=$SCRIPTS_DIR/ENV/workenv


SCAN_DIR="$1"

# -----------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# -----------------------------------

source /opt/conda/etc/profile.d/conda.sh
conda activate "$ENV"

EXEC=$SCRIPTS_DIR/DATA_TRANSFER/scan_data.py

srun python3 "$EXEC" "$SCAN_DIR"
