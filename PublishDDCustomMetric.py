# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import DDMetricCellular
import json

from awscrt import io, mqtt, auth, http
from awsiot import mqtt_connection_builder
import time as t
import os



ENDPOINT = os.environ.get('END_POINT')
CLIENT_ID = os.environ.get('THING_NAME')
PATH_TO_CERT = os.environ.get('DEVICE_CERT')
PATH_TO_KEY = os.environ.get('DEVICE_KEY')
PATH_TO_ROOT = os.environ.get('ROOT_CA')

print("establishing connection with CLIENT_ID={1}, ENDPOINT={0}, CERT={2}, KEY={3}, ROOT_CERT={4}".format(ENDPOINT, CLIENT_ID, PATH_TO_CERT, PATH_TO_KEY, PATH_TO_ROOT))


MESSAGE = "Hello World"
TOPIC = "$aws/things/" + CLIENT_ID + "/defender/metrics/" + "json"
RANGE = 2000000

# Callback when the subscribed topic receives a message
def on_message_received(topic, payload, dup, qos, retain, **kwargs):
    print()
    #print("Received message from topic '{}': {}".format(topic, payload))

def publishMetrics():
    event_loop_group = io.EventLoopGroup(1)
    host_resolver = io.DefaultHostResolver(event_loop_group)
    client_bootstrap = io.ClientBootstrap(event_loop_group, host_resolver)
    mqtt_connection = mqtt_connection_builder.mtls_from_path(
        endpoint=ENDPOINT,
        cert_filepath=PATH_TO_CERT,
        pri_key_filepath=PATH_TO_KEY,
        client_bootstrap=client_bootstrap,
        ca_filepath=PATH_TO_ROOT,
        client_id=CLIENT_ID,
        clean_session=False,
        keep_alive_secs=6
    )
    print("Connecting to {} with client ID '{}'...".format(
        ENDPOINT, CLIENT_ID))
    # Make the connect() call
    connect_future = mqtt_connection.connect()
    # Future.result() waits until a result is available
    connect_future.result()
    print("Connected!")

    subscribe_future1 = mqtt_connection.subscribe(TOPIC + "/accepted", on_message_received)
    subscribe_future2 = mqtt_connection.subscribe(TOPIC + "/rejected", on_message_received)
    #subscribe_future2.result()

    # Subscribe
    print("Subscribing to topic '{}'...".format(TOPIC + "/accepted"))
    sub_topic_1 = TOPIC + "/accepted"
    sub_topic_2 = TOPIC + "/rejected"

    print("Subscribing to topic '{}'...".format(TOPIC + "/accepted"))
    subscribe_future1, packet_id = mqtt_connection.subscribe(
        topic=sub_topic_1,
        qos=mqtt.QoS.AT_LEAST_ONCE,
        callback=on_message_received)

    subscribe_result = subscribe_future1.result()
    print("Subscribed with {}".format(str(subscribe_result['qos'])))

    print("Subscribing to topic '{}'...".format(TOPIC + "/rejected"))
    subscribe_future2, packet_id = mqtt_connection.subscribe(
        topic=sub_topic_2,
        qos=mqtt.QoS.AT_LEAST_ONCE,
        callback=on_message_received)

    subscribe_result = subscribe_future2.result()
    print("Subscribed with {}".format(str(subscribe_result['qos'])))

    # Publish message to server desired number of times.
    print('Begin Publish')
    for i in range(RANGE):
        data = DDMetricCellular.getMetric()
        payloadtosend = json.dumps(data)
        mqtt_connection.publish(topic=TOPIC, payload=payloadtosend, qos=mqtt.QoS.AT_LEAST_ONCE)
        print(str(i) + "     Published: '" + payloadtosend + "' to the topic: " + TOPIC)
        t.sleep(300)
    print('Publish End')
    disconnect_future = mqtt_connection.disconnect()
    disconnect_future.result()

if __name__ == '__main__':
    publishMetrics()