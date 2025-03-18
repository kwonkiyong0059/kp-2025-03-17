# 첫 번째 스테이지: 빌드 스테이지
FROM gradle:jdk-21-and-23-graal-jammy AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드와 Gradle 래퍼 복사
COPY build.gradle.kts .
COPY settings.gradle.kts .

# 종속성 설치
RUN gradle dependencies --no-daemon

# 소스 코드 복사
COPY src src

# 애플리케이션 빌드
RUN gradle build --no-daemon -x test

# 두 번째 스테이지: 실행 스테이지
FROM ghcr.io/graalvm/jdk-community:23

# 작업 디렉토리 설정
WORKDIR /app

# 첫 번째 스테이지에서 빌드된 JAR 파일 복사
COPY --from=builder /app/build/libs/*.jar app.jar

# 🔹 application-secret.yml 파일을 Docker 컨테이너 내부로 복사
COPY src/main/resources/application-secret.yml /app/config/application-secret.yml

# 실행할 JAR 파일 지정 (Spring이 해당 설정을 읽을 수 있도록 경로 추가)
ENTRYPOINT ["java", "-jar", "-Dspring.config.location=file:/app/config/application-secret.yml", "-Dspring.profiles.active=prod", "app.jar"]
