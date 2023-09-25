# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

if [[ $# -eq 0 ]] ; then
    echo 'please input the 'thing name' to create.. '
    exit 1
fi


# name of the IoT Device Thing
THING_NAME=$1
 
# create the thing
echo "Creating IoT Thing " ${THING_NAME}
aws iot create-thing --thing-name ${THING_NAME} | tee create-thing.json
 
# create and download the keys and device certificate
echo "Creating keys and device certificate"
aws iot create-keys-and-certificate --certificate-pem-outfile ${THING_NAME}-certificate.pem.crt --public-key-outfile ${THING_NAME}-public.pem.key --private-key-outfile ${THING_NAME}-private.pem.key --set-as-active | tee create-keys-and-certificate.json
 
# create the thing policy
echo "Creating thing policy"
aws iot create-policy --policy-name ${THING_NAME}_dd_metric_export --policy-document file://dd-custom-metric-policy.json
 
# attach the certificate to the thing
echo "Attaching thing policy to the thing principal"
CERT_ARN=$(jq -r '.certificateArn' < create-keys-and-certificate.json)
aws iot attach-thing-principal --thing-name ${THING_NAME} --principal ${CERT_ARN}
 
# attach policy to the certificate
aws iot attach-policy --policy-name ${THING_NAME}_dd_metric_export --target ${CERT_ARN}

#Create a static thing group and add newly created thing to that group
echo "Creating thing group dd-metric-export-group"
aws iot create-thing-group --thing-group-name dd-metric-export-group
aws iot add-thing-to-thing-group --thing-group-name dd-metric-export-group --thing-name ${THING_NAME}
 
# download the amazon root ca
wget https://www.amazontrust.com/repository/AmazonRootCA1.pem
 
# find out what endpoint we need to connect to
aws iot describe-endpoint --endpoint-type iot:Data-ATS | tee describe-endpoint.json


# create S3 bucket  to store the exported metrics
ACCOUNT_ID=`aws sts get-caller-identity --query "Account" --output text`

echo "Creating S3 bucket ${ACCOUNT_ID}.dd.metric.export to store the exported metric"
aws s3api create-bucket --bucket ${ACCOUNT_ID}.dd.metric.export --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1