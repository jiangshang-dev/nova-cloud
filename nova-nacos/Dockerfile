FROM openjdk:21

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8848
EXPOSE 8849

ENTRYPOINT ["java","-jar","app.jar"]