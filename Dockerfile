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

FROM maven:3.6.3-jdk-11

USER seluser

RUN mkdir /home/seluser/.m2
VOLUME /home/seluser/.m2
