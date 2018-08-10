#!/bin/bash

FORCE_DOWNLOAD=0
kafkaversion=1.1.0

usage="$(basename "$0") [-h] [-d] [-v version] 
-- program to compile kafka splunk connector
where:
   -h show this help text
   -d force download last version from https://github.com/splunk/kafka-connect-splunk
   -v define kafka version (not fully implemented !!!)
"

while getopts dhf: option
do
 case "${option}"
 in
   d) FORCE_DOWNLOAD=1;;
   v) kafkaversion=$OPTARG;;
   h) echo "$usage"
      exit
     ;;
 esac
done

if [ "$FORCE_DOWNLOAD" = 1 ] 
 then 
 echo "Downloading version from git repository"
 rm /opt/src/develop.zip
 wget https://github.com/splunk/kafka-connect-splunk/archive/develop.zip -P /opt/src/resources/

fi

unzip /opt/src/resources/develop.zip -d /opt/src/
cd /opt/src/kafka-connect-splunk-develop/

# variables
builddir=/tmp/myBuild/splunk-kafka-connect

gitversion=SNAPSHOT
jarversion=${gitversion}

# if no version found from git tag, it is a dev build
packagename=splunk-kafka-connect-${gitversion}.tar.gz

# record git info in version.properties file under resources folder
resourcedir='src/main/resources'
/bin/rm -f ${resourcedir}/version.properties
echo gitversion=${gitversion} >> ${resourcedir}/version.properties

curdir=`pwd`

/bin/rm -rf ${builddir}
mkdir -p ${builddir}/connectors
mkdir -p ${builddir}/bin
mkdir -p ${builddir}/config
mkdir -p ${builddir}/libs

# copy missing lib
cp /opt/src/resources/libs/commons-logging-1.2.jar ${builddir}/libs/commons-logging-1.2.jar

# Build the package
echo "Building the connector package ..."
mvn versions:set -DnewVersion=${jarversion}
mvn package > /dev/null

# Copy over the pacakge
echo "Copy over splunk-kafka-connect jar ..."
cp target/splunk-kafka-connect-${jarversion}.jar ${builddir}/connectors
cp config/* ${builddir}/config
cp README.md ${builddir}
cp LICENSE ${builddir}

cp /opt/src/resources/kafka_2.11-${kafkaversion}.tgz  ${builddir}
cd ${builddir} && tar xzf kafka_2.11-${kafkaversion}.tgz

# Copy over kafka connect runtime
echo "Copy over kafka connect runtime ..."
cp kafka_2.11-${kafkaversion}/bin/connect-distributed.sh ${builddir}/bin
cp kafka_2.11-${kafkaversion}/bin/kafka-run-class.sh ${builddir}/bin
cp kafka_2.11-${kafkaversion}/config/connect-log4j.properties ${builddir}/config
cp kafka_2.11-${kafkaversion}/libs/*.jar ${builddir}/libs

# Clean up
echo "Clean up ..."
/bin/rm -rf kafka_2.11-${kafkaversion}
/bin/rm -f kafka_2.11-${kafkaversion}.tgz

# Package up
echo "Package ${packagename} ..."
cd .. && tar czf ${packagename} splunk-kafka-connect

echo "Copy package ${packagename} to ${curdir} ..."
cp ${packagename} ${curdir}

/bin/rm -rf splunk-kafka-connect ${packagename}
echo "Done with build & packaging"

echo

cat << EOP
To run the splunk-kafka-connect, do the following steps:
1. untar the package: tar xzf splunk-kafka-connect.tar.gz
2. config config/connect-distributed.properties according to your env
3. run: bash bin/connect-distributed.sh config/connect-distributed.properties
4. Use Kafka Connect REST api to create data collection tasks
EOP

