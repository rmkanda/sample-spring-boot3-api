FROM eclipse-temurin:17-jre as builder
WORKDIR /app

COPY ./target/*.jar ./app.jar

RUN java -Djarmode=layertools -jar app.jar extract
RUN ls -lR


FROM gcr.io/distroless/java17-debian11
WORKDIR /app

USER 10024:10024

ENV LANG en_US.UTF-8
ENV JAVA_TOOL_OPTIONS="-Xmx512m -Dserver.port=8080 -Djava.io.tmpdir=/dev/shm -Djava.security.egd=file:/dev/./urandom -Djdk.tls.rejectClientInitiatedRenegotiation=true"
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
EXPOSE 8080