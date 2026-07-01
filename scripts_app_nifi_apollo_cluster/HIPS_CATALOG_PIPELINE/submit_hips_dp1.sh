#!/bin/bash
#SBATCH -p cpu
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-hipscatalog-dp1
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/hips_catalog/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/hips_catalog/logs/%x-%j.err

# -------------------
# SETUP VARIAVEIS 
# -------------------

DATARELEASE=DP1

BASE_DIR=/scratch/users/app.nifi/hips_catalog
SCRIPTS_DIR=/scripts/app.nifi/HIPS_CATALOG_PIPELINE
ENV_DIR=/scripts/app.nifi/HIPS_CATALOG_PIPELINE/.env

JOB_DIR=$BASE_DIR/logs/$DATARELEASE-JOB-${SLURM_JOB_ID}
mkdir -p "$JOB_DIR"

#-------------------
# INITIAL REPORT
#-------------------

$SCRIPTS_DIR/report_scripts/write_initial_report.sh "$JOB_DIR"

# ---------------------------------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# ---------------------------------------------------------
source /opt/conda/etc/profile.d/conda.sh
conda activate $ENV_DIR/hips-env

EXEC=$SCRIPTS_DIR/pipeline_exec.sh

srun $EXEC
PIPELINE_RC=$?

# ------------------
# FINAL REPORT
# ------------------

$SCRIPTS_DIR/report_scripts/write_final_report.sh \
    "$JOB_DIR" \
    "$PIPELINE_RC"

exit $PIPELINE_RC
