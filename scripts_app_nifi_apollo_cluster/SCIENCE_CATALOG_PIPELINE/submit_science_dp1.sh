#!/bin/bash
#SBATCH -p cpu
#SBATCH --mem-per-cpu=16G
#SBATCH -J nifi-scienceclgs_dp1
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/science_catalog/logs/%x-%j.out
#SBATCH --error=/scratch/users/%u/science_catalog/logs/%x-%j.err

# --------------------------
# SETUP VARIAVEIS
# --------------------------

DATARELEASE=DP1

BASE_DIR=/scratch/users/app.nifi/science_catalog
SCRIPTS_DIR=/scripts/app.nifi/SCIENCE_CATALOG_PIPELINE
OUTPUT_DIR="$BASE_DIR/nifi_scienceclgs_$DATARELEASE"


JOB_DIR=$BASE_DIR/logs/$DATARELEASE-JOB-${SLURM_JOB_ID}
mkdir -p "$JOB_DIR"


#--------------------------
# INITIAL REPORT
#--------------------------

$SCRIPTS_DIR/report_scripts/write_initial_report.sh "$JOB_DIR" "$OUTPUT_DIR"

# -----------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# -----------------------------------

export MICROMAMBA_BIN=/scratch/users/app.nifi/science_catalog/bin/micromamba

EXEC=$BASE_DIR/science_catalogs_core/run.sh

srun $EXEC $BASE_DIR/science_catalogs_core/config.yaml $OUTPUT_DIR
PIPELINE_RC=$?

# -----------------------
# FINAL REPORT
# ----------------------

$SCRIPTS_DIR/report_scripts/write_final_report.sh "$JOB_DIR" "$OUTPUT_DIR" "$PIPELINE_RC"

exit $PIPELINE_RC
