FROM openjdk:17-jdk-slim
WORKDIR /minecraft

# Install curl
RUN apt-get update && apt-get install -y curl

COPY . .
RUN chmod +x start.sh
EXPOSE 25565
CMD ["./start.sh"]
