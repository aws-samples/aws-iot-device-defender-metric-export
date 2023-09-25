# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


import time
import json
import random

def getMetric():
    data = {}

    header = {}
    id = int(time.time())
    header['report_id'] = id
    header['version'] = "1.0"

    custom_metrics = {}

    rssi_val1 = {}
    rssi_val1['number'] = round(random.uniform(-140, -40))

    rssi = [rssi_val1]
    custom_metrics['mobilerssi'] = rssi

    data['header'] = header
    data['custom_metrics'] = custom_metrics

    return data

if __name__ == '__main__':
    data = getMetric()
    print(json.dumps(data))
    # print(json.dumps(data, indent=4))