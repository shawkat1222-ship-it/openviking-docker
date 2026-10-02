#!/bin/bash

# Model Management Script for OpenViking + Ollama Container
# Helps manage and switch models without manual configuration

set -e

CONTAINER_NAME="${1:-openviking-complete}"
COMMAND="${2:-help}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function print_help() {
    cat << EOF
${BLUE}OpenViking + Ollama Model Manager${NC}

Usage: ./manage-models.sh [container-name] [command] [args]

${YELLOW}Commands:${NC}

  ${GREEN}list${NC}
    Show all available models in container

  ${GREEN}pull${NC} <model>
    Download and cache a model
    Example: ./manage-models.sh openviking-complete pull dolphin-mixtral

  ${GREEN}set-embedding${NC} <model>
    Change embedding model
    Example: ./manage-models.sh openviking-complete set-embedding all-minilm

  ${GREEN}set-llm${NC} <model>
    Change LLM model
    Example: ./manage-models.sh openviking-complete set-llm phi2

  ${GREEN}recommend${NC}
    Show recommended models for different use cases

  ${GREEN}status${NC}
    Show current model configuration and container status

  ${GREEN}test${NC} [model]
    Test a model's functionality
    Example: ./manage-models.sh openviking-complete test mistral

  ${GREEN}cleanup${NC}
    Remove unused models to free space

${YELLOW}Examples:${NC}

  # Use smaller, faster models
  ./manage-models.sh openviking-complete pull phi2
  ./manage-models.sh openviking-complete set-embedding all-minilm
  ./manage-models.sh openviking-complete set-llm phi2

  # Use higher-quality models
  ./manage-models.sh openviking-complete pull neural-chat
  ./manage-models.sh openviking-complete set-llm neural-chat

EOF
}

function check_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}Error: Container '${CONTAINER_NAME}' not running${NC}"
        exit 1
    fi
}

function list_models() {
    echo -e "${BLUE}Available models in container:${NC}\n"
    docker exec "$CONTAINER_NAME" ollama list
}

function pull_model() {
    local model=$1
    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        echo "Usage: ./manage-models.sh $CONTAINER_NAME pull <model>"
        exit 1
    fi
    
    echo -e "${YELLOW}Pulling model: ${GREEN}$model${NC}"
    docker exec "$CONTAINER_NAME" ollama pull "$model"
    echo -e "${GREEN}✓ Model pulled successfully${NC}"
}

function set_embedding_model() {
    local model=$1
    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        exit 1
    fi
    
    # Test if model exists
    if ! docker exec "$CONTAINER_NAME" ollama show "$model" > /dev/null 2>&1; then
        echo -e "${RED}Error: Model '${model}' not found in container${NC}"
        echo "Pull it first with: ./manage-models.sh $CONTAINER_NAME pull $model"
        exit 1
    fi
    
    # Update config
    local config_file="/app/.openviking/ov.conf"
    docker exec "$CONTAINER_NAME" bash -c \
        "sed -i \"s/\\\"embedding_model\\\": \\\"[^\\\"]*\\\"/\\\"embedding_model\\\": \\\"${model}\\\"/\" $config_file"
    
    echo -e "${GREEN}✓ Embedding model set to: ${YELLOW}${model}${NC}"
    echo "Restart the container for changes to take effect"
}

function set_llm_model() {
    local model=$1
    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        exit 1
    fi
    
    # Test if model exists
    if ! docker exec "$CONTAINER_NAME" ollama show "$model" > /dev/null 2>&1; then
        echo -e "${RED}Error: Model '${model}' not found in container${NC}"
        echo "Pull it first with: ./manage-models.sh $CONTAINER_NAME pull $model"
        exit 1
    fi
    
    # Update config
    local config_file="/app/.openviking/ov.conf"
    docker exec "$CONTAINER_NAME" bash -c \
        "sed -i \"s/\\\"vlm_model\\\": \\\"[^\\\"]*\\\"/\\\"vlm_model\\\": \\\"${model}\\\"/\" $config_file"
    
    echo -e "${GREEN}✓ LLM model set to: ${YELLOW}${model}${NC}"
    echo "Restart the container for changes to take effect"
}

function show_recommendations() {
    cat << EOF
${BLUE}Model Recommendations${NC}

${YELLOW}For Speed (Low Resource):${NC}
  Embedding: all-minilm (22MB, blazing fast)
  LLM:       phi2 (1.6GB, runs on 4GB RAM)
  
  Pull with:
    ./manage-models.sh openviking-complete pull all-minilm
    ./manage-models.sh openviking-complete pull phi2
    ./manage-models.sh openviking-complete set-embedding all-minilm
    ./manage-models.sh openviking-complete set-llm phi2

${YELLOW}Balanced (Default, Recommended):${NC}
  Embedding: nomic-embed-text (306MB, fast, accurate)
  LLM:       mistral (4.1GB, good quality, reasonable speed)
  
  Already pre-loaded in container

${YELLOW}For Quality (High Resource):${NC}
  Embedding: bge-large-en (1.3GB, high quality)
  LLM:       neural-chat (4.1GB, high quality)
  
  Pull with:
    ./manage-models.sh openviking-complete pull neural-chat
    ./manage-models.sh openviking-complete set-llm neural-chat

${YELLOW}For Large Scale (Very High Resource):${NC}
  LLM:       dolphin-mixtral (26GB, state-of-the-art quality)
  
  Requires 32GB+ RAM and GPU recommended
  Pull with:
    ./manage-models.sh openviking-complete pull dolphin-mixtral
    ./manage-models.sh openviking-complete set-llm dolphin-mixtral

${YELLOW}All Available Models:${NC}
  See: https://ollama.ai/library

EOF
}

function show_status() {
    echo -e "${BLUE}Container Status:${NC}"
    
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}✗ Container not running${NC}"
        return
    fi
    
    echo -e "${GREEN}✓ Container running${NC}"
    
    echo -e "\n${YELLOW}Loaded Models:${NC}"
    docker exec "$CONTAINER_NAME" ollama list
    
    echo -e "\n${YELLOW}Current Configuration:${NC}"
    docker exec "$CONTAINER_NAME" cat /app/.openviking/ov.conf | head -20 || echo "No config found"
    
    echo -e "\n${YELLOW}Memory Usage:${NC}"
    docker stats "$CONTAINER_NAME" --no-stream --format "table {{.MemUsage}}\t{{.MemPerc}}"
}

function test_model() {
    local model=${1:-mistral}
    
    if ! docker exec "$CONTAINER_NAME" ollama show "$model" > /dev/null 2>&1; then
        echo -e "${RED}Error: Model '${model}' not found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Testing model: ${GREEN}${model}${NC}\n"
    
    docker exec "$CONTAINER_NAME" ollama run "$model" \
        "Why is OpenViking useful for AI agents? Answer in one sentence." \
        --format json | jq '.response' || \
    docker exec "$CONTAINER_NAME" ollama run "$model" \
        "Why is OpenViking useful for AI agents?"
    
    echo -e "\n${GREEN}✓ Test complete${NC}"
}

function cleanup_models() {
    echo -e "${YELLOW}Removing models that aren't in use...${NC}"
    docker exec "$CONTAINER_NAME" bash -c \
        "ollama list | grep -v MODIFIED | awk '{print \$1}' | while read model; do ollama rm \$model; done" || true
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Main execution
case "$COMMAND" in
    help)
        print_help
        ;;
    list)
        check_container
        list_models
        ;;
    pull)
        check_container
        pull_model "${3}"
        ;;
    set-embedding)
        check_container
        set_embedding_model "${3}"
        ;;
    set-llm)
        check_container
        set_llm_model "${3}"
        ;;
    recommend)
        show_recommendations
        ;;
    status)
        check_container
        show_status
        ;;
    test)
        check_container
        test_model "${3}"
        ;;
    cleanup)
        check_container
        cleanup_models
        ;;
    *)
        echo -e "${RED}Unknown command: ${COMMAND}${NC}"
        print_help
        exit 1
        ;;
esac
