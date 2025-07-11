# Docker Compose Setup

This project includes a Docker Compose configuration for running the Rails application with SQLITE in development mode.

## Services

- **app**: Rails application (development mode with live code reloading)

## Quick Start

1. **make sure u have docker installed along with docker compose** 

2. **Start all services:**
   ```bash
   docker compose up -d
   ```

3. **Access the application:**
   - Main app: http://localhost:3000

## Testing the functionality

1. **encode**
   ```bash
   curl --location 'http://localhost:3000/encode' \
   --header 'Content-Type: application/json' \
   --data '{"original_link": "https://example.com?id=15"}'
   ```
2. **decode**
   ```bash
   curl --location 'http://localhost:3000/decode' \
   --header 'Content-Type: application/json' \
   --data '{"short_link": "https://shorten.coM/AAAAAAYjL"}'
   ```