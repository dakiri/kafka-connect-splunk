FROM debian:stretch-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https vim procps wget gnupg iputils-ping dnsutils \
                python gcc python-dev unzip openssl musl-dev
	
RUN mkdir /usr/share/man/man1 -p
RUN apt-get install -y --no-install-recommends openjdk-8-jre-headless libcap2-bin git openjdk-8-jdk

RUN wget -q https://bootstrap.pypa.io/get-pip.py -P / && python get-pip.py && pip install requests && pip install psutil

RUN mkdir -p /bin/apache-maven/
COPY ./src/apache-maven-3.5.4-bin.tar.gz /bin/apache-maven-3.5.4-bin.tar.gz
RUN tar xzf /bin/apache-maven-3.5.4-bin.tar.gz -C /opt/

ENV PATH=${PATH}:/opt/apache-maven-3.5.4/bin

# Prepare sources
RUN mkdir -p /opt/src
COPY ./scripts/build.sh /opt/src/build.sh
COPY ./src/develop.zip /opt/src/resources/develop.zip

COPY ./src/kafka_2.11-1.1.0.tgz /opt/src/resources/kafka_2.11-1.1.0.tgz
COPY ./src/commons-logging-1.2.jar  /opt/src/resources/libs/

RUN /opt/src/build.sh

# Extract package 
RUN tar -xf /opt/src/kafka-connect-splunk-develop/splunk-kafka-connect-SNAPSHOT.tar.gz -C /opt/

# Basic configuration
COPY ./src/connect-quickstart.properties /opt/splunk-kafka-connect/config/connect-quickstart.properties
# Start script 
COPY ./scripts/start.sh /opt/splunk-kafka-connect/config/start.sh
# Vim configuration
ADD ./tools/vim/.vimrc /root/.vimrc

WORKDIR /opt/splunk-kafka-connect

VOLUME ["/opt/splunk-kafka-connect/config"]
EXPOSE 8083

CMD ["/bin/bash", "-c", "/opt/splunk-kafka-connect/config/start.sh"]

