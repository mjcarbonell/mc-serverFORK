# Start from the official Debian base image
FROM debian:bullseye

# Installation of dependencies
RUN apt-get update -y && \
    apt-get install -y sudo unzip openjdk-17-jre-headless screen wget curl

# Download and install PaperMC (you can update the URL to the version you prefer)
RUN wget -O /minecraft_server.jar "https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/388/downloads/paper-1.18.2-388.jar"

# Download Mojang EULA
RUN wget -O /eula.txt "https://cdn.team-ic.dev/eula.txt"

# Create a directory for the Minecraft server
RUN mkdir -p /minecraft

# Move server files into the directory
RUN mv /minecraft_server.jar /minecraft/server.jar
RUN mv /eula.txt /minecraft/eula.txt

# Set working directory to the Minecraft server
WORKDIR /minecraft

# Expose the Minecraft server port
EXPOSE 25565

# Create a start script
RUN echo '#!/bin/bash\njava -Xms1G -Xmx1G -jar server.jar nogui' > /start.sh
RUN chmod +x /start.sh

# Start the Minecraft server
CMD ["/bin/bash", "/start.sh"]
