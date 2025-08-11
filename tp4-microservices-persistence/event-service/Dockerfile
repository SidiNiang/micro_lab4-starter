FROM openjdk:17-jdk-slim

# Installer Gradle
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip gradle-8.4-bin.zip && \
    mv gradle-8.4 /opt/gradle && \
    ln -s /opt/gradle/bin/gradle /usr/bin/gradle && \
    rm gradle-8.4-bin.zip && \
    apt-get clean

WORKDIR /app

# Copier les fichiers de build
COPY build.gradle .
COPY settings.gradle .
COPY gradle.properties .

# Télécharger les dépendances
RUN gradle build -x test --no-daemon || return 0

# Copier le code source
COPY src src

# Construire l'application
RUN gradle clean build -x test --no-daemon

EXPOSE 8080

CMD ["java", "-jar", "build/libs/event-service-0.0.1-SNAPSHOT.jar"]
