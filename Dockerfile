FROM ubuntu:16.04
MAINTAINER Kennedy Oliveira <kennedy.oliveira@outlook.com>

ENV YOUTRACK_VERSION 6.5.17105
ENV YOUTRACK_HOME /opt/jetbrains-youtrack
ENV YOUTRACK_DATA_DIR /var/lib/jetbrains-youtrack
ENV YOUTRACK_PORT 8080
ENV YOUTRACK_BASE_URL http://localhost:$YOUTRACK_PORT/

# Creates the dir to hold the persistent data & Fix Permissions
RUN mkdir -p $YOUTRACK_HOME $YOUTRACK_DATA_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jre-headless \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download & install youtrack
RUN wget https://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.zip -O /tmp/youtrack.zip && \
    unzip /tmp/youtrack.zip -d ${YOUTRACK_HOME}/ && \
    rm -rf /tmp/youtrack.zip && \
    rm -rf ${YOUTRACK_HOME}/internal/java

# Copy the init script
COPY ["docker-entrypoint.sh", "/opt/jetbrains-youtrack/"]

# Fix script permissions
RUN chmod 755 /opt/jetbrains-youtrack/docker-entrypoint.sh

# Change workdir
WORKDIR $YOUTRACK_HOME

# Basic configuration for youtrack
RUN bin/youtrack.sh configure \
    --backups-dir $YOUTRACK_DATA_DIR/backups \
    --data-dir $YOUTRACK_DATA_DIR/data/ \
    --logs-dir $YOUTRACK_DATA_DIR/logs \
    --temp-dir $YOUTRACK_DATA_DIR/temp \
    --listen-port $YOUTRACK_PORT \
    --base-url $YOUTRACK_BASE_URL

VOLUME ["$YOUTRACK_DATA_DIR/data/", "$YOUTRACK_DATA_DIR/backups", "$YOUTRACK_DATA_DIR/logs", "$YOUTRACK_DATA_DIR/temp"]

EXPOSE $YOUTRACK_PORT

ENTRYPOINT ["./docker-entrypoint.sh"]