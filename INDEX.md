# OpenViking + Ollama Complete Container - Index

## 🎯 Start Here

**First time?** Read in this order:
1. [QUICKSTART.sh](./QUICKSTART.sh) - Interactive setup guide (run: `bash QUICKSTART.sh`)
2. [CONTAINER_README.md](./CONTAINER_README.md) - Comprehensive documentation
3. Run: `docker compose up --pull always`

**Just want to build and run?**
```bash
docker compose up
# Then visit: http://localhost:1933/studio
```

---

## 📁 Files Reference

### 🐳 Docker Configuration
| File | Purpose |
|------|---------|
| **Dockerfile** | Multi-stage build with OpenViking + Ollama + models |
| **docker-compose.yml** | Standard development/deployment setup |
| **docker-compose.prod.yml** | Production configuration with monitoring |
| **docker-compose.gpu.yml** | GPU acceleration override (optional) |
| **supervisord.conf** | Process management for OpenViking + Ollama |
| **.dockerignore** | Excludes unnecessary files from build |

### ⚙️ Startup & Configuration
| File | Purpose |
|------|---------|
| **docker-entrypoint.sh** | Interactive startup script (guides first-time setup) |
| **ov.conf.example** | Configuration template |

### 📚 Documentation
| File | Purpose | Read When |
|------|---------|-----------|
| **CONTAINER_README.md** | Complete guide (7000+ words) | Need full info |
| **SETUP_SUMMARY.md** | Quick overview of all components | Understanding architecture |
| **QUICKSTART.sh** | Interactive setup (colored output) | Getting started |
| **VALIDATION_CHECKLIST.txt** | Post-deployment verification | After first run |
| **ENV_REFERENCE.txt** | Environment variable guide | Customizing behavior |

### 🛠️ Utilities
| File | Purpose |
|------|---------|
| **manage-models.sh** | Switch models, check status, run tests |

---

## 🚀 Quick Commands

```bash
# Build and run
docker compose up --pull always

# Check status
docker logs -f openviking-complete

# Test services
curl http://localhost:1933/health
curl http://localhost:11434/api/tags

# Manage models
chmod +x manage-models.sh
./manage-models.sh openviking-complete status
./manage-models.sh openviking-complete recommend
./manage-models.sh openviking-complete pull phi2

# Access Web UI
# → http://localhost:1933/studio

# With GPU
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up
```

---

## 📊 What's Inside

### Services
- **OpenViking Server** (port 1933)
  - Context database for AI agents
  - Memory, knowledge, skills management
  - Web Studio UI
  - VikingBot framework
  
- **Ollama** (port 11434)
  - Local LLM serving
  - Pre-loaded models

### Pre-loaded Models
| Model | Type | Size | Speed | Quality |
|-------|------|------|-------|---------|
| nomic-embed-text | Embedding | 306MB | Very Fast | High |
| mistral | LLM | 4.1GB | Medium | Balanced |

### Process Management
- Supervisor runs both services in single container
- Auto-restart on failure
- Centralized logging
- Health checks

---

## 🔧 Configuration

### Initial Setup
Container guides you through configuration on first run:
1. Choose provider (Local Ollama recommended)
2. Select models
3. Configure API keys if needed

### Change Models
```bash
./manage-models.sh openviking-complete pull phi2
./manage-models.sh openviking-complete set-llm phi2
```

### Switch Provider
Edit `/app/.openviking/ov.conf` (in mounted volume)
- **Ollama** (local, recommended)
- **Volcengine** (cloud models)
- **OpenAI** (advanced models)
- **Other** (Kimi, GLM, etc.)

### GPU Acceleration
```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up
```

---

## 📈 Performance

### Recommended Setups

**Fast & Minimal (2GB)**
- Model: phi2 + all-minilm
- RAM: 4GB minimum
- Speed: 50+ tokens/sec (CPU)

**Balanced (Default, 4.5GB)**
- Model: mistral + nomic-embed-text
- RAM: 8GB recommended
- Speed: 5-10 tokens/sec (CPU)

**High Quality (5GB+)**
- Model: neural-chat + bge-large
- RAM: 16GB recommended
- Speed: Moderate (CPU) / Fast (GPU)

**GPU-Enabled**
- Any model
- Speed: 50-100+ tokens/sec
- Requires NVIDIA GPU + Docker runtime

---

## 🔗 Connecting Agents

To connect AI agents to this container:

```
Server URL: http://localhost:1933 (or your IP)
Ollama URL: http://localhost:11434
Embedding: nomic-embed-text
LLM: mistral
```

See [OpenViking Integration Docs](https://docs.openviking.ai/en/agent-integrations/)

---

## 📋 Next Steps

1. **Build Container**
   ```bash
   docker compose up --pull always
   ```

2. **Verify Services** (wait 60 seconds)
   ```bash
   curl http://localhost:1933/health
   curl http://localhost:11434/api/tags
   ```

3. **Access Web UI**
   - Open: http://localhost:1933/studio

4. **Add Resources**
   ```bash
   docker exec openviking-complete ov add-resource https://github.com/yourrepo
   ```

5. **Connect Agents**
   - Use server address from step 4
   - See integration docs

---

## 🐛 Troubleshooting

**Services won't start?**
```bash
docker logs openviking-complete
# Check for supervisor or Ollama errors
```

**Models not loading?**
```bash
docker exec openviking-complete ollama list
docker exec openviking-complete ollama pull nomic-embed-text
```

**High memory usage?**
```bash
# Use smaller models
./manage-models.sh openviking-complete pull phi2
./manage-models.sh openviking-complete set-llm phi2
```

**Port conflicts?**
Edit `docker-compose.yml` ports section

More help: [CONTAINER_README.md](./CONTAINER_README.md#troubleshooting)

---

## 📚 Documentation Map

```
QUICKSTART.sh              ← Start here (interactive)
    ↓
CONTAINER_README.md        ← Full guide & troubleshooting
    ├→ SETUP_SUMMARY.md    ← Architecture overview
    ├→ ENV_REFERENCE.txt   ← Environment variables
    └→ VALIDATION_CHECKLIST.txt ← Post-run checklist
    
manage-models.sh           ← Model management
    ↓
./manage-models.sh openviking-complete help
```

---

## ✅ Health Check

After starting, verify everything works:

```bash
# Service health
curl http://localhost:1933/health
curl http://localhost:11434/api/tags

# Container logs
docker logs openviking-complete

# Model status
./manage-models.sh openviking-complete status

# Test inference
./manage-models.sh openviking-complete test mistral
```

---

## 🎯 Success Indicators

✓ Both services (OpenViking + Ollama) running
✓ Web Studio loads at http://localhost:1933/studio
✓ Models loaded and accessible
✓ Configuration persists after restart
✓ Health checks pass
✓ Can connect AI agents

---

## 🔗 External Resources

- [OpenViking Documentation](https://docs.openviking.ai/)
- [Ollama Model Library](https://ollama.ai/library)
- [VikingBot Guide](https://docs.openviking.ai/en/guides/17-vikingbot)
- [OpenViking Agent Integrations](https://docs.openviking.ai/en/agent-integrations/)

---

**Status**: Complete container setup ready for deployment
**Build Time**: 15-30 minutes (includes model download)
**Final Size**: ~5-8GB with models
**Components**: OpenViking + Ollama + Web Studio + VikingBot
