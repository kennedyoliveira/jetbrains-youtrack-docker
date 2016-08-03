FROM ubuntu:16.04
MAINTAINER Kennedy Oliveira <kennedy.oliveira@outlook.com>

ENV YOUTRACK_VERSION 6.5.17105
ENV YOUTRACK_HOME /opt/jetbrains-youtrack
ENV YOUTRACK_DATA_DIR /var/lib/jetbrains-youtrack
ENV YOUTRACK_PORT 8080
ENV YOUTRACK_USER youtrack
ENV YOUTRACK_BASE_URL http://localhost:$YOUTRACK_PORT/

# Creates users and groups
RUN groupadd --system $YOUTRACK_USER
RUN useradd --system -g $YOUTRACK_USER -d $YOUTRACK_HOME $YOUTRACK_USER

# Creates the dir to hold the persistent data & Fix Permissions
RUN mkdir -p $YOUTRACK_HOME $YOUTRACK_DATA_DIR && \
    chown -R $YOUTRACK_USER:$YOUTRACK_USER $YOUTRACK_HOME $YOUTRACK_DATA_DIR && \
    chmod 740 -R $YOUTRACK_HOME $YOUTRACK_DATA_DIR

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

# Fix permissions of new files
RUN chown -R $YOUTRACK_USER:$YOUTRACK_USER $YOUTRACK_DATA_DIR ${YOUTRACK_HOME}  && \
    chmod -R 740 $YOUTRACK_DATA_DIR $YOUTRACK_HOME

# Change user and workdir
USER $YOUTRACK_USER
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