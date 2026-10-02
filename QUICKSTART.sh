#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     OpenViking + Ollama Complete Container Setup             ║
║                                                              ║
║     Context Database for AI Agents + Local LLMs              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "\n${YELLOW}Prerequisites:${NC}"
echo "  • Docker (version 20.10+)"
echo "  • Docker Compose (version 2.0+)"
echo "  • 8GB RAM minimum (16GB recommended)"
echo "  • 20GB free disk space for models and data"

echo -e "\n${YELLOW}Quick Start Options:${NC}"
echo ""
echo -e "${GREEN}1. Docker Compose (Easiest)${NC}"
echo "   $ docker compose up --pull always"
echo ""
echo -e "${GREEN}2. Docker Run${NC}"
echo "   $ docker build -t openviking-complete ."
echo "   $ docker run -d -p 1933:1933 -p 11434:11434 \\"
echo "     -v ~/.openviking:/app/.openviking \\"
echo "     -v ~/.ollama:/root/.ollama \\"
echo "     openviking-complete"
echo ""
echo -e "${GREEN}3. With GPU Support${NC}"
echo "   $ docker compose -f docker-compose.yml -f docker-compose.gpu.yml up"

echo -e "\n${YELLOW}Accessing Services:${NC}"
echo "  • Web UI/Studio:     ${BLUE}http://localhost:1933/studio${NC}"
echo "  • OpenViking API:    ${BLUE}http://localhost:1933${NC}"
echo "  • Ollama API:        ${BLUE}http://localhost:11434${NC}"

echo -e "\n${YELLOW}Useful Commands:${NC}"
echo ""
echo -e "${GREEN}Check status:${NC}"
echo "  $ docker logs openviking-complete"
echo "  $ curl http://localhost:1933/health"
echo "  $ curl http://localhost:11434/api/tags"
echo ""
echo -e "${GREEN}CLI operations:${NC}"
echo "  $ docker exec openviking-complete ov status"
echo "  $ docker exec openviking-complete ov ls viking://"
echo "  $ docker exec openviking-complete ov find \"your query\""
echo ""
echo -e "${GREEN}Configure:${NC}"
echo "  $ docker exec -it openviking-complete bash"
echo "  $ vim /app/.openviking/ov.conf"
echo ""
echo -e "${GREEN}Add models:${NC}"
echo "  $ docker exec openviking-complete ollama pull phi2"
echo "  $ docker exec openviking-complete ollama list"
echo ""
echo -e "${GREEN}View logs:${NC}"
echo "  $ docker logs -f openviking-complete"

echo -e "\n${YELLOW}Model Information:${NC}"
echo ""
echo -e "${GREEN}Pre-loaded Models:${NC}"
echo "  • nomic-embed-text (306MB)  - Fast embedding model"
echo "  • mistral (4.1GB)           - Capable 7B parameter LLM"
echo ""
echo -e "${GREEN}Alternative Models:${NC}"
echo "  Embedding:"
echo "    - all-minilm          (22MB, very fast)"
echo "    - bge-small           (33MB, fast)"
echo "  LLM:"
echo "    - phi2                (1.6GB, very fast, lower quality)"
echo "    - neural-chat         (4.1GB, good balance)"
echo "    - dolphin-mixtral     (26GB, high quality, slow)"

echo -e "\n${YELLOW}First-Time Setup:${NC}"
echo "1. Start container: docker compose up"
echo "2. Container will guide you through configuration"
echo "   Choose '1' for local Ollama (already set up)"
echo "3. Web Studio will be ready at: http://localhost:1933/studio"
echo "4. Start using with your AI agents!"

echo -e "\n${YELLOW}Connecting AI Agents:${NC}"
echo "  • Server: http://localhost:1933 (or your server IP)"
echo "  • Ollama: http://localhost:11434"
echo "  • Models: nomic-embed-text (embed), mistral (llm)"
echo ""
echo "  See: https://docs.openviking.ai/en/agent-integrations/"

echo -e "\n${YELLOW}Troubleshooting:${NC}"
echo "  • Port already in use?"
echo "    Change ports in docker-compose.yml"
echo "  • High memory usage?"
echo "    Use lighter models (phi2 instead of mistral)"
echo "  • Build taking too long?"
echo "    Use pre-built image: docker pull volcengine/openviking"

echo -e "\n${YELLOW}Documentation:${NC}"
echo "  • Full README:       ${BLUE}./CONTAINER_README.md${NC}"
echo "  • OpenViking Docs:   ${BLUE}https://docs.openviking.ai${NC}"
echo "  • Ollama Library:    ${BLUE}https://ollama.ai/library${NC}"

echo -e "\n${BLUE}Ready to start? Run:${NC}"
echo -e "  ${GREEN}docker compose up${NC}\n"
