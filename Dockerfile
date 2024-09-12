FROM openjdk:17-jdk-slim
WORKDIR /minecraft

# Install curl
RUN apt-get update && apt-get install -y curl

COPY . .
RUN chmod +x start.sh

RUN echo "level-name=/WorldBackup/your_world_folder" > server.properties


EXPOSE 25565
CMD ["./start.sh"]
