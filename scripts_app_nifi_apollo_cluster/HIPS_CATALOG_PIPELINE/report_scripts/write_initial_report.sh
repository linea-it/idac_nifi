#!/bin/bash

BASE_DIR=/scratch/users/app.nifi/hips_catalog


JOB_DIR="$1"

JOB_INFO=$(scontrol show job -o "${SLURM_JOB_ID}")

WORKDIR=$(echo "$JOB_INFO" | grep -oP 'WorkDir=\K\S+')
SUBMITTIME=$(echo "$JOB_INFO" | grep -oP 'SubmitTime=\K\S+')
JOBSTATE=$(echo "$JOB_INFO" | grep -oP 'JobState=\K\S+')

CONFIG_FILE="$BASE_DIR/hipscatalog_gen/config.yaml"

INPUT_DIR=$(grep -A1 '^[[:space:]]*paths:' "$CONFIG_FILE" \
    | grep '^[[:space:]]*-' \
    | head -n1 \
    | sed 's/^[[:space:]]*-[[:space:]]*"//; s/"$//')

N_WORKERS=$(grep -E '^[[:space:]]*n_workers:' "$CONFIG_FILE" | awk '{print $2}')
THREADS_PER_WORKER=$(grep -E '^[[:space:]]*threads_per_worker:' "$CONFIG_FILE" | awk '{print $2}')
MEMORY_PER_WORKER=$(grep -E '^[[:space:]]*memory_per_worker:' "$CONFIG_FILE" | sed 's/.*memory_per_worker:[[:space:]]*//; s/"//g')
OUT_DIR=$(grep -E '^[[:space:]]*out_dir:' "$CONFIG_FILE" | sed 's/.*out_dir:[[:space:]]*//; s/"//g')

cat > "${JOB_DIR}/initial_report.json" << EOF
{
  "job_id": "${SLURM_JOB_ID}",
  "job_name": "${SLURM_JOB_NAME}",
  "user": "${SLURM_JOB_USER}",
  "partition": "${SLURM_JOB_PARTITION}",
  "nodelist": "${SLURM_JOB_NODELIST}",
  "workdir": "${WORKDIR}",
  "submit_time": "${SUBMITTIME}",
  "status": "${JOBSTATE}",
  "n_workers": ${N_WORKERS},
  "threads_per_worker": ${THREADS_PER_WORKER},
  "memory_per_worker": "${MEMORY_PER_WORKER}",
  "input_dir": "${INPUT_DIR}",
  "out_dir": "${OUT_DIR}"
}
EOF

scontrol show job -o "${SLURM_JOB_ID}" \
    > "${JOB_DIR}/metadata.txt"
