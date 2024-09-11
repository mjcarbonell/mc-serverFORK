FROM openjdk:8-jre-slim

# Set working directory
WORKDIR /app

# Copy necessary files
COPY . .

# Set the executable permissions for scripts
RUN chmod +x start.sh

# EULA
RUN echo "eula=true" > eula.txt
# Expose the Minecraft server port
EXPOSE 25565

# Start the server
CMD ["./start.sh"]