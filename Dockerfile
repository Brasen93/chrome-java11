FROM maven:3.6.3-jdk-11 as maven

FROM selenium/standalone-chrome as chrome
ENV JAVA_HOME=/usr/local/openjdk-11
ENV JAVA_BASE_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_
ENV JAVA_URL_VERSION=11.0.7_10
ENV MAVEN_HOME=/usr/share/maven
ENV JAVA_VERSION=11.0.7

USER root
COPY --from=maven /usr/local/openjdk-11 /usr/local/openjdk-11
COPY --from=maven /usr/share/maven /usr/share/maven
RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

USER 1000


