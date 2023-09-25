# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


# when done, delete thing resources
THING_NAME=$(jq -r '.thingName' < create-thing.json)
CERT_ARN=$(jq -r '.certificateArn' < create-keys-and-certificate.json)

echo "detaching policy.. "
aws iot detach-policy --policy-name ${THING_NAME}_dd_metric_export --target ${CERT_ARN}

echo "detaching thing principal.. "
aws iot detach-thing-principal --thing-name ${THING_NAME} --principal ${CERT_ARN}

echo "deleting policy.. "
aws iot delete-policy --policy-name ${THING_NAME}_dd_metric_export

echo "deleting certificate policy.. "
aws iot update-certificate --certificate-id $(jq -r '.certificateId' < create-keys-and-certificate.json) --new-status INACTIVE
aws iot delete-certificate --certificate-id $(jq -r '.certificateId' < create-keys-and-certificate.json)

echo "deleting thing group.. "
aws iot remove-thing-from-thing-group --thing-group-name dd-metric-export-group --thing-name ${THING_NAME}
aws iot delete-thing-group --thing-group-name dd-metric-export-group

echo "deleting thing.. "
aws iot delete-thing --thing-name ${THING_NAME}
rm ${THING_NAME}-certificate.pem.crt ${THING_NAME}-public.pem.key ${THING_NAME}-private.pem.key create-keys-and-certificate.json describe-endpoint.json create-thing.json AmazonRootCA1.pem

echo "Cleanup complete.. "