# Build stage
FROM dart:3.10 AS build

WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml ./

# Get dependencies
RUN dart pub get

# Copy source code
COPY . .

# Compile to native executable
RUN dart compile exe bin/adakite.dart -o bin/adakite

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled executable
COPY --from=build /app/bin/adakite /app/adakite

# Copy .env file (can be overridden with volume mount)
COPY .env .env

ENTRYPOINT ["/app/adakite"]
