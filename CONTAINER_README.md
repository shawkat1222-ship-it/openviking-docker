# OpenViking + Ollama Complete Container

An all-in-one Docker image combining **OpenViking Server**, **Web Studio**, and **Ollama** with pre-configured embedding and language models for a self-contained AI agent context database.

## Features

- **OpenViking Server**: Context database for AI agents with memory, knowledge, and skills management
- **Web Studio**: Interactive UI for browsing and managing context
- **Ollama Integration**: Local LLM support with pre-cached models
- **Pre-loaded Models**:
  - `nomic-embed-text` - Lightweight embedding model for semantic search
  - `mistral` - Small but capable LLM for bot inference
- **VikingBot**: Built-in AI agent framework for autonomous context compilation and learning
- **Supervisor**: Manages both OpenViking and Ollama services in a single container

## Quick Start

### Using Docker Compose (Recommended)

```bash
docker compose up --pull always
```

Then access:
- **Web UI**: http://localhost:1933/studio
- **OpenViking API**: http://localhost:1933
- **Ollama API**: http://localhost:11434

### Using Docker Run

```bash
docker build -t openviking-complete .
docker run -d \
  -p 1933:1933 \
  -p 11434:11434 \
  -v ~/.openviking:/app/.openviking \
  -v ~/.ollama:/root/.ollama \
  openviking-complete
```

## Configuration

### First Run Setup

On first start, the container will guide you through initial configuration:

1. **Local Ollama** (default) - Uses embedded Ollama instance
2. **Volcengine API** - Uses Volcengine model services
3. **OpenAI API** - Uses OpenAI models
4. **Other providers** - Kimi, GLM, etc.

Configuration is stored in `/app/.openviking/ov.conf` and persists in the volume.

### Using Ollama Models

The container comes with:
- **Embedding Model**: `nomic-embed-text` (306MB, fast, accurate)
- **LLM Model**: `mistral` (4.1GB, balanced quality/speed)

#### Switch embedding model:
```bash
docker exec <container_id> ollama pull all-minilm
# Then edit ov.conf: change embedding_model to "all-minilm"
```

#### Switch LLM model:
```bash
docker exec <container_id> ollama pull phi2
# Then edit ov.conf: change vlm_model to "phi2"
```

#### Available lightweight models:
- **Embedding**: `nomic-embed-text`, `all-minilm`, `bge-small`
- **LLM**: `phi2` (1.6GB), `neural-chat` (4.1GB), `mistral` (4.1GB), `dolphin-mixtral` (26GB)

### Persist Configuration

Mount volumes to preserve configuration and models across restarts:

```bash
docker run -d \
  -v ~/.openviking:/app/.openviking \
  -v ~/.ollama:/root/.ollama \
  openviking-complete
```

## Usage

### Check Service Status

```bash
# OpenViking health
curl http://localhost:1933/health

# Ollama models
curl http://localhost:11434/api/tags

# View container logs
docker logs -f <container_id>
```

### Use with OpenViking CLI

```bash
docker exec <container_id> ov status
docker exec <container_id> ov ls viking://
docker exec <container_id> ov find "your query"
```

### Test Ollama Directly

```bash
# Generate with mistral
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Why is OpenViking useful for AI agents?"
}'

# Get embeddings
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "embedding test"
}'
```

## Architecture

```
┌─────────────────────────────────────┐
│  Docker Container                   │
├─────────────────────────────────────┤
│                                     │
│  Supervisor (Process Manager)       │
│  ├── OpenViking (port 1933)        │
│  │   ├── Server                    │
│  │   ├── Web Studio (/studio)      │
│  │   └── VikingBot                 │
│  │                                 │
│  └── Ollama (port 11434)           │
│      ├── nomic-embed-text          │
│      └── mistral                   │
│                                     │
├─────────────────────────────────────┤
│  Volumes                            │
│  ├── openviking_data                │
│  └── ollama_data                    │
└─────────────────────────────────────┘
```

## Building Locally

```bash
git clone https://github.com/volcengine/OpenViking
cd OpenViking
docker build -t openviking-complete .
docker compose up
```

Build time: ~15-30 minutes (depending on system and network)
Final image size: ~5-8GB (includes models)

## Ports

| Port  | Service           |
|-------|-------------------|
| 1933  | OpenViking Server |
| 11434 | Ollama API        |

## Troubleshooting

### Services not starting

```bash
docker logs openviking-complete
```

Check for:
- Supervisor process manager errors
- Ollama initialization issues
- OpenViking configuration errors

### Ollama models not available

```bash
docker exec openviking-complete ollama list
docker exec openviking-complete ollama pull nomic-embed-text
```

### High memory usage

Ollama models are cached in-memory. To reduce memory:
- Use smaller models: `phi2` instead of `mistral`
- Reduce model count
- Configure memory limits:

```bash
docker run --memory=4g openviking-complete
```

### Configuration issues

Edit directly:

```bash
docker exec -it openviking-complete bash
vim /app/.openviking/ov.conf
# or run:
openviking-server init
```

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `OLLAMA_HOST` | `0.0.0.0:11434` | Ollama bind address |
| `OLLAMA_MODELS` | `/root/.ollama/models` | Model cache directory |
| `OPENVIKING_CONFIG_FILE` | `/app/.openviking/ov.conf` | Config file path |
| `OPENVIKING_SETUP_MODE` | `1` | Automatic setup (1=Ollama, 2=Volcengine, 3=OpenAI) |

## Model Performance

### Embedding (nomic-embed-text)
- **Size**: 306MB
- **Dimensions**: 768
- **Speed**: Fast (~1ms/embedding)
- **Quality**: High for short documents

### LLM (mistral)
- **Size**: 4.1GB
- **Parameters**: 7B
- **Speed**: ~5-10 tokens/sec (CPU), ~50+ tokens/sec (GPU)
- **Quality**: Balanced reasoning and speed

## Connecting Agents

To connect your AI agent to this container:

1. **OpenViking Server URL**: `http://localhost:1933` (or your server's IP)
2. **Ollama Base URL**: `http://localhost:11434`
3. **Default Models**:
   - Embedding: `nomic-embed-text`
   - LLM: `mistral`

See [OpenViking Integrations](https://docs.openviking.ai/en/agent-integrations/) for agent-specific setup.

## License

- **OpenViking**: AGPLv3 (see [LICENSE](https://github.com/volcengine/OpenViking/blob/main/LICENSE))
- **Ollama**: MIT
- **This setup**: Same as OpenViking (AGPLv3)

## Resources

- [OpenViking Docs](https://docs.openviking.ai/)
- [Ollama Models](https://ollama.ai/library)
- [VikingBot Guide](https://docs.openviking.ai/en/guides/17-vikingbot)
