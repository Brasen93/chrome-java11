FROM maven:3.6.3-jdk-11 as maven
# --- MAVEN BASE ---

FROM debian:bullseye as chrome

# --- BASIC CONF ---
RUN apt-get update -yqq && \
	apt-get upgrade -yqq && \
    	apt-get install -yqq wget unzip gnupg curl && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# --- MAVEN ---
ENV JAVA_HOME=/usr/local/openjdk-11
ENV JAVA_BASE_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_
ENV JAVA_URL_VERSION=11.0.7_10
ENV MAVEN_HOME=/usr/share/maven
ENV JAVA_VERSION=11.0.7

COPY --from=maven /usr/local/openjdk-11 /usr/local/openjdk-11
COPY --from=maven /usr/share/maven /usr/share/maven
RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

#RUN apt-get install -yqq python3-pip && pip install selenium


# --- CHROME ---
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update && \
	apt-get install -y google-chrome-stable
RUN rm /usr/bin/google-chrome && ln -s /etc/alternatives/google-chrome /usr/bin/oldchrome
ADD xvfb-chrome /usr/bin/xvfb-chrome
RUN chmod a+rwx /usr/bin/xvfb-chrome
RUN ln -s /usr/bin/xvfb-chrome /usr/bin/google-chrome && \
	ln -s /usr/bin/xvfb-chrome /usr/bin/chrome && \
	ln -s /usr/bin/xvfb-chrome /usr/bin/chromium-browser

# --- CHROMEDRIVER ---
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# --- XVFB ---
RUN apt-get install -yqq xvfb
ENV DISPLAY=:99
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
RUN mkdir /tmp/.X11-unix && \
	chmod 1777 /tmp/.X11-unix
RUN Xvfb :99 -screen 0 1280x1024x8 -nolisten tcp &
 
# --- USER ---
RUN useradd -ms /bin/bash selenide
WORKDIR /home/selenide
USER selenide
