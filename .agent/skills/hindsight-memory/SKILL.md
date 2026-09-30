---
name: hindsight-memory
description: >-
  Cognitive persistent long-term memory for Antigravity AI pair programming on Fixsy.
  Use this skill to retain architectural decisions, layer boundaries, user preferences,
  security rules, and bug solutions, and to recall past context before coding or planning.
---

# Hindsight Memory Skill for Antigravity

This skill formalizes the persistent cognitive memory workflow (`retain`, `recall`, `reflect`) for the Fixsy project using Hindsight.

---

## 1. When to Use Hindsight

### A. Pre-Flight Recall (`recall`)
Before starting any new feature, creating a new service/repository, refactoring existing code, or writing a specification:
- Query Hindsight to recall previously established architectural decisions, coding patterns, and user preferences.
- Example:
  ```bash
  python tool/hindsight/hindsight_client.py recall "Clean Architecture layer boundaries"
  python tool/hindsight/hindsight_client.py recall "Dio ApiClient and token refresh rules"
  python tool/hindsight/hindsight_client.py recall "Arabic RTL and layout guidelines"
  ```

### B. Post-Action Retention (`retain`)
After completing a feature, ratifying an architectural decision, establishing a pattern, or resolving a difficult bug:
- Retain the key takeaway, rationale, and decision into the `fixsy_agent` bank.
- Example:
  ```bash
  python tool/hindsight/hindsight_client.py retain "Fixsy Routing: Replaced MaterialPageRoute with named routes in AppRoutes."
  ```

### C. Periodic Reflection (`reflect`)
To synthesize mental models and consolidate knowledge across disparate memories:
- Example:
  ```bash
  python tool/hindsight/hindsight_client.py reflect "What are our core architectural conventions?"
  ```

---

## 2. CLI Tool Reference

All commands are executed via [tool/hindsight/hindsight_client.py](file:///c:/Users/A%20PLUS/fixsy_flutter/tool/hindsight/hindsight_client.py):

| Command | Description | Example |
| :--- | :--- | :--- |
| `health` | Verify server and database connectivity | `python tool/hindsight/hindsight_client.py health` |
| `recall "<query>"` | Retrieve relevant memories with relevance scores | `python tool/hindsight/hindsight_client.py recall "security tokens"` |
| `retain "<content>"` | Queue/store new memory into persistent bank | `python tool/hindsight/hindsight_client.py retain "..."` |
| `reflect "<query>"` | Synthesize mental models and observations | `python tool/hindsight/hindsight_client.py reflect "quality standards"` |
| `stats` | View memory bank metrics and stats | `python tool/hindsight/hindsight_client.py stats` |

---

## 3. Server Management & Auto-Heal

If `hindsight_client.py health` fails or indicates the local server is not running:
1. Start the server in the background:
   ```bash
   uv run --with hindsight-api python tool/hindsight/run_hindsight.py
   ```
2. The server binds to `http://localhost:8888`, embeds PostgreSQL with pgvector, and uses `gemini-3.6-flash` with local ONNX embeddings.
3. No Docker is required. All state persists across reboots in `~/.pg0/hindsight-mcp`.

---

## 4. Fixsy Ground Rules Encoded in Memory

- **Principle I: Clean Architecture Strictness** — Zero Flutter/UI imports in Domain Layer. UI only talks to Providers; Providers only talk to Repositories.
- **Principle II: Centralized Network & ApiClient** — Never instantiate raw `Dio()` or `http.Client()`. Use `ApiClient` with AuthInterceptor and TokenVault.
- **Principle III: Zero-Trust Secrets** — Absolute ban on hardcoded credentials or API keys. Always use `.env` and `EnvConfig`.
- **Principle IV: Offline-First** — Local caching via `CacheManager` with Sembast and TTL policies.
- **Principle X: Daily Git Streaks & Code Quality** — Maintain streak with clean, atomic commits; keep 0 flutter analyze errors and warnings.
