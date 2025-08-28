# ===== Build stage =====
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy pom files first (for caching)
COPY pom.xml .
COPY core/pom.xml core/
COPY web/pom.xml web/

# Download dependencies (better cache)
RUN mvn dependency:go-offline

# Copy full source
COPY . .

# Build (skip tests for faster build in Docker)
RUN mvn clean package -DskipTests

# ===== Run stage =====
FROM tomcat:10.1-jdk17
WORKDIR /usr/local/tomcat/webapps

# Remove default ROOT app
RUN rm -rf ROOT

# Copy generated WAR (assuming your web module produces time-tracker-web.war)
COPY --from=builder /app/web/target/*.war ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
