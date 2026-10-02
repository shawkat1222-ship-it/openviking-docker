#!/bin/bash
set -e

# OpenViking + Ollama Setup Script
# This script initializes the container with proper configurations

echo "=== OpenViking + Ollama Container Setup ==="
echo ""

# Create necessary directories
mkdir -p /app/.openviking

# Check if ov.conf exists
if [ ! -f /app/.openviking/ov.conf ]; then
    echo "No ov.conf found. Choose setup method:"
    echo ""
    echo "1. Local Ollama (recommended for this container)"
    echo "2. Volcengine/Doubao API"
    echo "3. OpenAI API"
    echo "4. Other provider (Kimi, GLM, etc.)"
    echo ""
    
    if [ -z "$OPENVIKING_SETUP_MODE" ]; then
        read -p "Enter choice (1-4): " choice
    else
        choice=$OPENVIKING_SETUP_MODE
        echo "Using OPENVIKING_SETUP_MODE=$choice"
    fi
    
    case $choice in
        1)
            echo ""
            echo "Configuring for local Ollama..."
            cat > /app/.openviking/ov.conf << 'EOF'
{
  "provider": "ollama",
  "embedding_model": "nomic-embed-text",
  "vlm_model": "mistral",
  "api_base": "http://localhost:11434",
  "api_key": ""
}
EOF
            echo "✓ Ollama configuration created"
            echo "Available models:"
            echo "  - nomic-embed-text (embedding)"
            echo "  - mistral (LLM for bot)"
            echo ""
            echo "To use different models, edit /app/.openviking/ov.conf"
            ;;
        2)
            echo ""
            echo "Configuring for Volcengine..."
            read -sp "Enter API Key: " api_key
            echo ""
            cat > /app/.openviking/ov.conf << EOF
{
  "provider": "volcengine",
  "api_key": "$api_key",
  "api_base": "https://api.arkose.volcengine.com",
  "embedding_model": "bge-base-zh",
  "vlm_model": "doubao-2-pro"
}
EOF
            echo "✓ Volcengine configuration created"
            ;;
        3)
            echo ""
            echo "Configuring for OpenAI..."
            read -sp "Enter API Key: " api_key
            echo ""
            cat > /app/.openviking/ov.conf << EOF
{
  "provider": "openai",
  "api_key": "$api_key",
  "api_base": "https://api.openai.com/v1",
  "embedding_model": "text-embedding-3-small",
  "vlm_model": "gpt-4o-mini"
}
EOF
            echo "✓ OpenAI configuration created"
            ;;
        *)
            echo "Starting with default Ollama config. Edit ov.conf in volume."
            cat > /app/.openviking/ov.conf << 'EOF'
{
  "provider": "ollama",
  "embedding_model": "nomic-embed-text",
  "vlm_model": "mistral",
  "api_base": "http://localhost:11434",
  "api_key": ""
}
EOF
            ;;
    esac
else
    echo "Using existing /app/.openviking/ov.conf"
fi

echo ""
echo "=== Services Starting ==="
echo ""
echo "OpenViking Server: http://localhost:1933"
echo "Web Studio:        http://localhost:1933/studio"
echo "Ollama API:        http://localhost:11434"
echo ""
echo "To check status:"
echo "  curl http://localhost:1933/health"
echo "  curl http://localhost:11434/api/tags"
echo ""
echo "To view logs:"
echo "  docker logs -f <container_id>"
echo ""

# Start services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
