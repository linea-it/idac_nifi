#!/bin/bash

BASE_DIR=/scratch/users/app.nifi/hips_catalog

JOB_DIR="$1"
PIPELINE_RC="$2"

# accounting pode demorar alguns segundos
sleep 15

SACCT_DATA=$(sacct -j "${SLURM_JOB_ID}" \
    --parsable2 \
    --noheader \
    --format=JobID,JobName,State,Elapsed,End,AllocCPUS,MaxRSS)

STEP_DATA=$(echo "$SACCT_DATA" | grep "|pipeline_exec.sh|")

IFS='|' read -r \
    _ \
    _ \
    STATE \
    ELAPSED \
    END \
    ALLOCCPUS \
    MAXRSS <<< "$STEP_DATA"


JOB_ID="${SLURM_JOB_ID}"
JOB_NAME="${SLURM_JOB_NAME}"

LOG_FILES="$BASE_DIR/logs/JOB-$JOB_ID"
ERR_FILE="$BASE_DIR/logs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}.err"


# Tamanho do stderr

if [ -f "$ERR_FILE" ]; then
    STDERR_SIZE=$(stat -c%s "$ERR_FILE" 2>/dev/null || echo 0)
else
    STDERR_SIZE=0
fi

CONFIG_FILE="$BASE_DIR/hipscatalog_gen/config.yaml"

INPUT_DIR=$(grep -A1 '^[[:space:]]*paths:' "$CONFIG_FILE" \
    | grep '^[[:space:]]*-' \
    | head -n1 \
    | sed 's/^[[:space:]]*-[[:space:]]*"//; s/"$//')

OUT_DIR=$(grep -E '^[[:space:]]*out_dir:' "$CONFIG_FILE" | sed 's/.*out_dir:[[:space:]]*//; s/"//g')


cat > "${JOB_DIR}/final_report.json" << EOF
{
  "job_id": "${JOB_ID}",
  "job_name": "${JOB_NAME}",
  "state": "${STATE}",
  "elapsed": "${ELAPSED}",
  "end_time": "${END}",
  "alloc_cpus": "${ALLOCCPUS}",
  "log_files": "${LOG_FILES}",
  "stderr_file": "${ERR_FILE}",
  "stderr_size": "${STDERR_SIZE}",
  "max_rss": "${MAXRSS}",
  "input_dir": "${INPUT_DIR}",
  "out_dir": "${OUT_DIR}"
}
EOF

touch "${JOB_DIR}/job.finished"
