# Use a Debian-based image as the base
FROM debian:buster

# Add a build argument for the version
ARG BASE_URL
ARG VERSION

# Install dependencies
RUN apt-get update && apt-get install -y wget libssl1.1 && rm -rf /var/lib/apt/lists/*

# Download and install the specified version of SingleStore Studio
RUN wget "${BASE_URL}${VERSION}" -O /tmp/singlestoredb-studio.deb \
    && dpkg -i /tmp/singlestoredb-studio.deb \
    && rm /tmp/singlestoredb-studio.deb

# Expose the default port and set the command to start SingleStore Studio
EXPOSE 8080
CMD ["singlestoredb-studio"]
