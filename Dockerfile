# Start from the official Debian base image
FROM debian:bullseye

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y sudo unzip openjdk-17-jre-headless screen wget curl

# Create the server directory
RUN mkdir -p /minecraft

# Copy your server files (including mods) to the Docker image
COPY ./mods /minecraft/mods
COPY ./config /minecraft/config
COPY ./defaultconfigs /minecraft/defaultconfigs
COPY ./server.properties /minecraft/server.properties
COPY ./server-icon.png /minecraft/server-icon.png
COPY ./start.sh /minecraft/start.sh

# Set the working directory to the Minecraft server directory
WORKDIR /minecraft

# Ensure the start script is executable
RUN chmod +x start.sh

# Expose Minecraft server port
EXPOSE 25565

# Run the server
CMD ["./start.sh"]
