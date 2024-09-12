FROM openjdk:17-jdk-slim
WORKDIR /minecraft

# Install curl
RUN apt-get update && apt-get install -y curl

COPY . .
RUN chmod +x start.sh
# test
RUN echo "level-name=/WorldBackup/your_world_folder" > server.properties
RUN echo '[{"uuid":"3e88f0a2-dc1e-41ab-815d-1595cbe1d888","name":"MAXMOOHAHA","level":4,"bypassesPlayerLimit":false}]' > ops.json
RUN echo '[{"uuid":"ee36b6d4-c52d-4535-81f0-8c790c7cb812","name":"FaTe__tempurrr","level":4,"bypassesPlayerLimit":false}]' > ops.json


EXPOSE 25565
CMD ["./start.sh"]
