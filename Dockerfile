FROM openjdk:17-jdk-slim
WORKDIR /minecraft
COPY . .
RUN chmod +x start.sh
EXPOSE 25565
CMD ["./start.sh"]
