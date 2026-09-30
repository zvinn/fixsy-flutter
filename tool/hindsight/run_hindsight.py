import os
import sys
from pathlib import Path

# Force UTF-8 on Windows consoles to prevent cp1252 UnicodeEncodeError
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

os.environ["PYTHONIOENCODING"] = "utf-8"

# Locate .env safely in project root
project_root = Path(__file__).resolve().parents[2]
env_file = project_root / ".env"

if env_file.exists():
    for line in env_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip().strip("'\"")
        if k and v and k not in os.environ:
            os.environ[k] = v

gemini_key = os.environ.get("GEMINI_API_KEY")

if gemini_key:
    os.environ["HINDSIGHT_API_LLM_PROVIDER"] = "gemini"
    os.environ["HINDSIGHT_API_LLM_API_KEY"] = gemini_key
    os.environ["HINDSIGHT_API_LLM_MODEL"] = "gemini-3.6-flash"
    os.environ["HINDSIGHT_API_EMBEDDINGS_PROVIDER"] = "local"
    os.environ["HINDSIGHT_API_DATABASE_URL"] = "pg0://hindsight-mcp"
    # Disable prompt caching to prevent Free Tier 429 quota errors on Gemini
    os.environ["HINDSIGHT_API_LLM_PROMPT_CACHE_ENABLED"] = "false"

# Monkey-patch print_banner to prevent cp1252 charmap encoding crash on Windows
try:
    import hindsight_api.banner
    hindsight_api.banner.print_banner = lambda: print("Hindsight API Initializing...")
except Exception:
    pass

from hindsight_api.mcp_local import main

if __name__ == "__main__":
    main()
