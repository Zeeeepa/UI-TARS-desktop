# Deploying UI-TARS-desktop with DeepSeek API

This guide provides instructions for deploying UI-TARS-desktop with DeepSeek API integration using Docker.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) installed (usually comes with Docker Desktop)
- DeepSeek API key (obtain from [DeepSeek Platform](https://platform.deepseek.com/))

## Quick Deployment

The easiest way to deploy is using the provided script:

```bash
./deploy-with-deepseek.sh
```

This script will:
1. Check for Docker and Docker Compose installation
2. Create a `.env` file if it doesn't exist
3. Prompt for your DeepSeek API key
4. Build and start the Docker containers

## Manual Deployment

If you prefer to deploy manually, follow these steps:

### 1. Set up environment variables

Create a `.env` file in the project root directory:

```
# Copy the example file
cp .env.example .env

# Edit the file and add your DeepSeek API key
nano .env
```

Make sure to set the following variables:
- `DEEPSEEK_API_KEY`: Your DeepSeek API key
- `DEEPSEEK_API_BASE_URL`: The DeepSeek API base URL (default: https://api.deepseek.com/v1)

### 2. Build and start the Docker containers

```bash
docker-compose up -d --build
```

### 3. Access the application

Once the containers are running, you can access the application at:
```
http://localhost:3000
```

## Configuration

### DeepSeek Models

The following DeepSeek models are available:
- `deepseek-chat`: DeepSeek-V3

You can configure the model in the application settings.

### Custom API Endpoint

If you're using a custom DeepSeek API endpoint, you can set it in the `.env` file:

```
DEEPSEEK_API_BASE_URL=https://your-custom-endpoint.com/v1
```

## Troubleshooting

### Viewing Logs

To view the application logs:

```bash
docker-compose logs -f
```

### Stopping the Application

To stop the application:

```bash
docker-compose down
```

### Common Issues

1. **API Key Issues**: Ensure your DeepSeek API key is valid and has sufficient credits.
2. **Network Issues**: If you're behind a corporate firewall, you may need to configure proxy settings.
3. **Docker Permission Issues**: On Linux, you might need to run Docker commands with `sudo` or add your user to the Docker group.

## Additional Commands

### Restart the Application

```bash
docker-compose restart
```

### Update After Code Changes

```bash
docker-compose up -d --build
```

### Completely Remove Containers and Volumes

```bash
docker-compose down -v
```

