Adakite is an aggregator for nostr, it subscribes to every relay and stores the new events where you want.

## Configuration

Create a `.env` file with the following variables:

```
STORAGE_RELAYS=wss://your-relay-1.com,wss://your-relay-2.com
```

## Running

### Using Docker (recommended)

Using the pre-built image from GitHub Container Registry:

```bash
docker compose -f docker-compose.ghcr.yml up -d
```

Or build locally:

```bash
docker compose up -d --build
```

### Running locally

```bash
dart pub get
dart run bin/adakite.dart
```
