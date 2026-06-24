#!/bin/bash

BASE_DIR=/scratch/users/app.nifi/science_catalog


JOB_DIR="$1"
OUTPUT_DIR="$2"

JOB_INFO=$(scontrol show job -o "${SLURM_JOB_ID}")

WORKDIR=$(echo "$JOB_INFO" | grep -oP 'WorkDir=\K\S+')
SUBMITTIME=$(echo "$JOB_INFO" | grep -oP 'SubmitTime=\K\S+')
JOBSTATE=$(echo "$JOB_INFO" | grep -oP 'JobState=\K\S+')

CONFIG_FILE="$BASE_DIR/science_catalogs_core/config.yaml"

INPUT_DIR=$(grep -E '^[[:space:]]*catalog_folder:' "$CONFIG_FILE" \
    | sed 's/.*catalog_folder:[[:space:]]*//; s/"//g')

CORES=$(grep -E '^[[:space:]]*cores:' "$CONFIG_FILE" | awk '{print $2}')
PROCESSES=$(grep -E '^[[:space:]]*processes:' "$CONFIG_FILE" | awk '{print $2}')
MEMORY=$(grep -E '^[[:space:]]*memory:' "$CONFIG_FILE" | sed 's/.*memory:[[:space:]]*//; s/"//g')


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
  "cores": ${CORES},
  "processes": ${PROCESSES},
  "memory": "${MEMORY}",
  "input_dir": "${INPUT_DIR}",
  "output_dir": "${OUTPUT_DIR}"
}
EOF
