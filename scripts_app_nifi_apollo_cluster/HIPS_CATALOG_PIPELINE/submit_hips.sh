#!/bin/bash
#SBATCH -p cpu_dev
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-hipscatalog-gen
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/hips_catalog/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/hips_catalog/logs/%x-%j.err

# ---------------------------------------------------------
# JOB DIR AND INITIAL METADATA
# ---------------------------------------------------------

BASE_DIR=/scratch/users/app.nifi/hips_catalog
SCRIPTS_DIR=/scripts/app.nifi/HIPS_CATALOG_PIPELINE
ENV_DIR=/scripts/app.nifi/HIPS_CATALOG_PIPELINE/.env
#ENV_DIR=/scratch/users/app.nifi/hips_catalog

JOB_DIR=$BASE_DIR/logs/JOB-${SLURM_JOB_ID}
mkdir -p "$JOB_DIR"

$SCRIPTS_DIR/report_scripts/write_initial_report.sh "$JOB_DIR"

# ---------------------------------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# ---------------------------------------------------------
source /opt/conda/etc/profile.d/conda.sh
conda activate $ENV_DIR/hips-env

EXEC=$SCRIPTS_DIR/pipeline_exec.sh

srun $EXEC
PIPELINE_RC=$?

# ---------------------------------------------------------
# FINAL REPORT
# ---------------------------------------------------------

$SCRIPTS_DIR/report_scripts/write_final_report.sh \
    "$JOB_DIR" \
    "$PIPELINE_RC"

exit $PIPELINE_RC
