#!/bin/bash
#SBATCH -p cpu_dev
#SBATCH --mem-per-cpu=8G
#SBATCH -J nifi-data-transfer
#SBATCH --chdir=/scratch/users/app.nifi
#SBATCH --output=/scratch/users/%u/data_sdwcopy/%x-%j.out
#SBATCH --error=/scratch/users/%u/data_sdwcopy/%x-%j.err

# -------------------
# SETUP VARIAVEIS 
# -------------------

BASE_DIR=/scratch/users/app.nifi/data_sdwcopy
SCRIPTS_DIR=/scripts/app.nifi/DATA_SHADOWCOPY

JOB_DIR=$BASE_DIR/logs/DATASDWCOPY-JOB-${SLURM_JOB_ID}
mkdir -p "$JOB_DIR"

#-------------------
# INITIAL REPORT
#-------------------

#$SCRIPTS_DIR/report_scripts/write_initial_report.sh "$JOB_DIR"

# ---------------------------------------------------------
# ACTIVATION ENV AND EXECUTE PIPELINE
# ---------------------------------------------------------

EXEC=$SCRIPTS_DIR/exec_data_shadow.sh

srun $EXEC
PIPELINE_RC=$?

# ------------------
# FINAL REPORT
# ------------------

#$SCRIPTS_DIR/report_scripts/write_final_report.sh \
#    "$JOB_DIR" \
#    "$PIPELINE_RC"

exit $PIPELINE_RC
