#!/bin/bash

BASE_DIR=/scratch/users/app.nifi/hips_catalog

cd $BASE_DIR/hipscatalog_gen/

hipscatalog-gen --config config.yaml
