# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#Export environment variables

echo -e "\nExporting environment variables..."

export THING_NAME=$(jq -r '.thingName' < create-thing.json)
export DEVICE_CERT=${THING_NAME}-certificate.pem.crt
export DEVICE_KEY=${THING_NAME}-private.pem.key
export END_POINT=$(jq -r '.endpointAddress' < describe-endpoint.json)
export ROOT_CA=AmazonRootCA1.pem

echo -e "\nInstalling aws iot sdk.."
pip3 install --user awsiotsdk
#echo $THING_NAME $DEVICE_CERT $DEVICE_KEY $END_POINT $ROOT_CA

echo -e "\nRunning the publisher..."
python3 PublishDDCustomMetric.py
