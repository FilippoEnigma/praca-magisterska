# Pierwszy etap: Kompilacja aplikacji
# Używamy obrazu Maven z Java 11, aby zbudować aplikację
FROM maven:3.8.5-openjdk-11 AS builder

# Ustawienie katalogu roboczego wewnątrz kontenera
WORKDIR /app

# Skopiowanie plików projektu (pom.xml i katalogu src) do kontenera
COPY pom.xml .
COPY src ./src

# Sprawdzenie obecności pom.xml i katalogu src
RUN test -f pom.xml || (echo "ERROR: Missing pom.xml file" && exit 1)
RUN test -d src || (echo "ERROR: Missing src directory" && exit 1)

# Kompilacja aplikacji przy użyciu Maven bez uruchamiania testów
RUN mvn clean package -DskipTests

# Drugi etap: Przygotowanie obrazu produkcyjnego
# Używamy lekkiego obrazu JRE dla gotowej aplikacji
FROM openjdk:11-jre-slim

# Ustawienie katalogu roboczego dla aplikacji
WORKDIR /app

# Skopiowanie wygenerowanego pliku .jar z pierwszego etapu budowania
COPY --from=builder /app/target/*.jar app.jar

# Ustawienie domyślnej komendy do uruchamiania aplikacji
ENTRYPOINT ["java", "-jar", "app.jar"]
