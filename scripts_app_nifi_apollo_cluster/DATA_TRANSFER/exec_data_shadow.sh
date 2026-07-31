#!/bin/bash

BASE_DIR=/scratch/users/app.nifi
cd $BASE_DIR/data_sdwcopy

/scripts/app.nifi/DATA_SHADOWCOPY/data_shadow.sh

sleep 5

/scripts/app.nifi/DATA_SHADOWCOPY/scan_data.sh $BASE_DIR/data_origem

