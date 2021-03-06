FROM cyclic/jira-base:latest
MAINTAINER Thomas Goddard <ohmygoddard@gmail.com>

# Configuration
ENV JIRA_VERSION 7.11.2

# Get environment variables for building
ARG SOURCE_COMMIT
ARG SOURCE_TAG
ARG BUILD_DATE

# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.name="jira-software" \
	org.label-schema.description="A Docker image for Jira Software" \
	org.label-schema.url="https://www.atlassian.com/software/jira" \
	org.label-schema.vcs-ref=$SOURCE_COMMIT \
	org.label-schema.vcs-url="https://github.com/cyclic/docker-jira-software" \
	org.label-schema.version=$SOURCE_TAG \
	org.label-schema.schema-version="1.0"

# Download and install jira software in /opt with proper permissions and clean unnecessary files

RUN curl -Lks https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-$JIRA_VERSION.tar.gz -o /tmp/jira.tar.gz \
	&& mkdir -p /opt/jira \
	&& tar -zxf /tmp/jira.tar.gz --strip=1 -C /opt/jira \
	&& chown -R root:root /opt/jira \
	&& chown -R 547:root /opt/jira/logs /opt/jira/temp /opt/jira/work \
	&& chown -R jira:jira /data/jira \
	&& rm /tmp/jira.tar.gz

# Add jira customizer and launcher
COPY launch.sh /launch

# Make jira customizer and launcher executable
RUN chmod +x /launch

# Expose ports
EXPOSE 8080

# Removed for ECS
# VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]

# Workdir
WORKDIR /opt/jira

# Launch jira
ENTRYPOINT ["/launch"]
