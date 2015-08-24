FROM azul/zulu-openjdk-debian:latest
MAINTAINER Adrian Haasler García <dev@adrianhaasler.com>

# Configuration
ENV FISHEYE_HOME /data/fisheye
ENV FISHEYE_VERSION 3.9.0

# Install dependencies
RUN apt-get update && apt-get install -y \
	curl \
	tar \
	xmlstarlet

# Create the user that will run the fisheye instance and his home directory (also make sure that the parent directory exists)
RUN mkdir -p $(dirname $FISHEYE_HOME) \
	&& useradd -m -d $FISHEYE_HOME -s /bin/bash -u 547 fisheye

# Download and install fisheye in /opt with proper permissions and clean unnecessary files
RUN curl -Lks http://www.atlassian.com/software/fisheye/downloads/binary/fisheye-$FISHEYE_VERSION.tar.gz -o /tmp/fisheye.tar.gz \
	&& mkdir -p /opt/fisheye \
	&& tar -zxf /tmp/fisheye.tar.gz --strip=1 -C /opt/fisheye \
	&& chown -R root:root /opt/fisheye \
	&& chown -R 547:root /opt/fisheye/logs /opt/fisheye/temp /opt/fisheye/work \
	&& rm /tmp/fisheye.tar.gz

# Add fisheye customizer and launcher
COPY launch.sh /launch

# Make fisheye customizer and launcher executable
RUN chmod +x /launch

# Expose ports
EXPOSE 8060

# Workdir
WORKDIR /opt/fisheye

# Launch fisheye
ENTRYPOINT ["/launch"]
