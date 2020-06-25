FROM selenium/standalone-chrome

USER root

################################################################################################################
# Install JDK
# https://github.com/docker-library/openjdk/blob/master/8-jdk/Dockerfile
# Selenum is based on Xenial, so it is a bit different
################################################################################################################


RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    unzip \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo; \
    echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
  } > /usr/local/bin/docker-java-home \
  && chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV JAVA_VERSION 8u91
ENV JAVA_DEBIAN_VERSION 8u91-b14-0ubuntu4~16.04.1

RUN set -x \
  && apt-get update \
  && apt-get install -y \
    openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
  && rm -rf /var/lib/apt/lists/* \
  && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure



################################################################################################################
# Install Maven
# https://github.com/carlossg/docker-maven
################################################################################################################


ENV MAVEN_VERSION 3.3.9

RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar -xzC /usr/share/maven --strip-components=1 \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG /home/seluser/.m2
ENV COPY_REFERENCE_FILE_LOG $MAVEN_CONFIG/copy_reference_file.log

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

USER seluser

RUN mkdir /home/seluser/.m2
VOLUME /home/seluser/.m2
