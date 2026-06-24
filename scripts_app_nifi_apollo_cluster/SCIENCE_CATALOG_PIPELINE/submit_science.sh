#!/bin/bash
#SBATCH -p cpu_dev
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-science
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/science_catalog/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/science_catalog/logs/%x-%j.err

# --------------------------
# JOB DIR AND INITIAL REPORT
# --------------------------

BASE_DIR=/scratch/users/app.nifi/science_catalog
SCRIPTS_DIR=/scripts/app.nifi/SCIENCE_CATALOG_PIPELINE
OUTPUT_DIR="$BASE_DIR/nifi-run001"


JOB_DIR=$BASE_DIR/logs/JOB-${SLURM_JOB_ID}
mkdir -p "$JOB_DIR"

$SCRIPTS_DIR/report_scripts/write_initial_report.sh "$JOB_DIR" "$OUTPUT_DIR"

# -----------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# -----------------------------------

export MICROMAMBA_BIN=/scratch/users/app.nifi/science_catalog/bin/micromamba

EXEC=$BASE_DIR/science_catalogs_core/run.sh

srun $EXEC $BASE_DIR/science_catalogs_core/config.yaml $OUTPUT_DIR
PIPELINE_RC=$?

# ------------
# FINAL REPORT
# ------------

$SCRIPTS_DIR/report_scripts/write_final_report.sh "$JOB_DIR" "$OUTPUT_DIR" "$PIPELINE_RC"

exit $PIPELINE_RC
