## AWS IoT Device Defender Metric Export

This repository contains resources for the blog post "How to export your IoT device metrics evaluated in AWS IoT Device Defender":
1. createResources.sh : Script to create resources needed for build out of the solution elaborated in the blog. This script creates a Thing, a policy and principal to govern the identity and authorization for this thing, adds the created thing to a static thing group and creates a S3 bucket to store the metrics exported from AWS IoT Device Defender.
2. cleanupResources.sh: Script to delete the resources and the temporary files created by createResource.sh
3. publishMetric.sh : Script to run a python client which publishes custom metric to AWS IoT Device Defender
4. PublishDDCustomMetric.py : MQTT client which publishes custom metric to AWS IoT Device Defender every 5 mins
5. DDMetricCellular.py : Utility code to generate a random value representing Cellular RSSI
6. dd-custom-metric-policy.json : Policy file defining the access permissions for the Thing created by createResource.sh

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

