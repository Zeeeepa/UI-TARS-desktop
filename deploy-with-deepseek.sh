#!/bin/bash

# Deploy UI-TARS-desktop with DeepSeek API integration
# This script helps set up and deploy the application with Docker

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== UI-TARS-desktop DeepSeek Deployment ===${NC}"
echo "This script will help you deploy UI-TARS-desktop with DeepSeek API integration."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    echo "Visit https://docs.docker.com/get-docker/ for installation instructions."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed. Please install Docker Compose first.${NC}"
    echo "Visit https://docs.docker.com/compose/install/ for installation instructions."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}Created .env file. Please edit it with your DeepSeek API key.${NC}"
fi

# Prompt for DeepSeek API key if not set
if ! grep -q "DEEPSEEK_API_KEY=" .env || grep -q "DEEPSEEK_API_KEY=your_deepseek_api_key" .env; then
    echo -e "${YELLOW}Please enter your DeepSeek API key:${NC}"
    read -r api_key
    sed -i "s/DEEPSEEK_API_KEY=.*/DEEPSEEK_API_KEY=$api_key/" .env
    echo -e "${GREEN}DeepSeek API key has been set.${NC}"
fi

# Prompt for DeepSeek API base URL if needed
if ! grep -q "DEEPSEEK_API_BASE_URL=" .env; then
    echo -e "${YELLOW}Do you want to use a custom DeepSeek API base URL? (default: https://api.deepseek.com/v1) [y/N]:${NC}"
    read -r custom_url_choice
    if [[ $custom_url_choice =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Please enter the DeepSeek API base URL:${NC}"
        read -r base_url
        echo "DEEPSEEK_API_BASE_URL=$base_url" >> .env
        echo -e "${GREEN}DeepSeek API base URL has been set.${NC}"
    else
        echo "DEEPSEEK_API_BASE_URL=https://api.deepseek.com/v1" >> .env
        echo -e "${GREEN}Using default DeepSeek API base URL.${NC}"
    fi
fi

# Build and start the Docker containers
echo -e "${YELLOW}Building and starting Docker containers...${NC}"
docker-compose up -d --build

# Check if containers are running
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment successful!${NC}"
    echo -e "UI-TARS-desktop is now running with DeepSeek integration."
    echo -e "You can access it at http://localhost:3000"
    echo -e "${YELLOW}To view logs:${NC} docker-compose logs -f"
    echo -e "${YELLOW}To stop the application:${NC} docker-compose down"
else
    echo -e "${RED}Deployment failed. Please check the error messages above.${NC}"
fi

