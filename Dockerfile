# Wybierz obraz bazowy z JDK, który posłuży do kompilacji aplikacji
FROM maven:3.8.5-openjdk-11 AS builder

# Ustaw katalog roboczy wewnątrz kontenera
WORKDIR /app

# Skopiuj pliki aplikacji (np. `pom.xml` i `src/`) do katalogu roboczego
COPY pom.xml . 
COPY src ./src

# Sprawdź, czy plik pom.xml istnieje, jeśli nie, zakończ budowanie z błędem
RUN test -f pom.xml || (echo "ERROR: Missing pom.xml file" && exit 1)

# Sprawdź, czy katalog src istnieje, jeśli nie, zakończ budowanie z błędem
RUN test -d src || (echo "ERROR: Missing src directory" && exit 1)

# Uruchom komendę Maven, aby pobrać zależności i zbudować aplikację
RUN mvn clean package -DskipTests

# Drugi etap: wybór lekkiego obrazu JRE dla gotowej aplikacji
FROM openjdk:11-jre-slim

# Ustaw katalog roboczy dla drugiego etapu
WORKDIR /app

# Skopiuj wygenerowany plik `.jar` z pierwszego etapu
COPY --from=builder /app/target/*.jar app.jar

# Ustaw domyślną komendę uruchamiającą aplikację
ENTRYPOINT ["java", "-jar", "app.jar"]
