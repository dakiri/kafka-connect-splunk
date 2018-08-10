Docker kafka connector fork of https://github.com/splunk/kafka-connect-splunk for my personnal learning of kafka.

The image contain the necessary to recompile the connector from sources.

## Prepare the configuration

A persistent volume can be bind to /opt/splunk-kafka-connect/config

Must contain :

- the start script start.sh which responsible for :
   + edit /etc/hosts in case of hosting the kafka container and the broker on the same machine
   + launching the connector service

- the configuration like connect-distributed-quickstart.properties 

In this file edit the parameter bootstrap.servers to match your server url. 

## Run

Use makefile to start container via docker-compose

run up:          Run container in console mode
daemon:          Run container in daemon mode
restart:	 Restart the daemon
stop:            Stop container
shell bash:      Launch shell in container

## Using the connector

### bind a new connector

`
curl 192.168.2.38:8083/connectors -X POST -H "Content-Type: application/json" -d'{
  "name": "splunk-prod",
    "config": {
     "connector.class": "com.splunk.kafka.connect.SplunkSinkConnector",
     "tasks.max": "2",
     "topics": "mytopic,t1",
     "splunk.hec.uri":"https://192.168.2.38:8088",
     "splunk.hec.token": "2e8c1aba-9218-4a65-a232-fa0782a7dcf0",
     "splunk.hec.ack.enabled" : "true",
     "splunk.hec.ssl.validate.certs" : "false",
     "splunk.hec.raw" : "false",
     "splunk.hec.json.event.enrichment" : "org=fin,bu=daki",
     "splunk.hec.track.data" : "true",
     "splunk.hec.max.batch.size":"50"
    }
}'
` 

splunk.hec.max.batch.size : Maximum batch size when posting events to Splunk. The size is the actual number of Kafka events, and not byte size. By default, this is set to 100. 

### List all connector

curl http://192.168.2.38:8083/connectors

### Delete a connector

curl http://192.168.2.38:8083/connectors/splunk-prod -X DELETE

## Build the container

make build

or make build-nc  Build the container without caching


## Compile a new version

make daemon
make shell
/opt/src/build.sh

