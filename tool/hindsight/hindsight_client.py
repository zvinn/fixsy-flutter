#!/usr/bin/env python3
"""
Hindsight Client for Antigravity AI Agent
Provides cognitive long-term memory operations: Retain, Recall, Reflect.
"""

import sys
import os
import json
import argparse
import urllib.request
import urllib.error

# Force UTF-8 on Windows
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

DEFAULT_HOST = os.environ.get("HINDSIGHT_HOST", "http://localhost:8888")
DEFAULT_BANK = os.environ.get("HINDSIGHT_BANK_ID", "fixsy_agent")


def _request(path: str, data: dict | None = None, method: str = "GET") -> dict:
    url = f"{DEFAULT_HOST}{path}"
    headers = {"Content-Type": "application/json"}
    body = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=45) as resp:
            content = resp.read().decode("utf-8")
            return json.loads(content) if content else {}
    except urllib.error.URLError as e:
        print(f"[Error connecting to Hindsight at {url}]: {e}", file=sys.stderr)
        sys.exit(1)


def retain(content: str, bank: str = DEFAULT_BANK, async_mode: bool = True) -> dict:
    """Store facts, code decisions, architectural rules, or context into Hindsight memory.
    Defaults to async_mode=True so operations are background-queued and rate-limit resilient.
    """
    payload = {
        "items": [{"content": content}],
        "async": async_mode
    }
    return _request(f"/v1/default/banks/{bank}/memories", data=payload, method="POST")


def recall(query: str, bank: str = DEFAULT_BANK, max_results: int = 5) -> dict:
    """Retrieve relevant memories, architectural decisions, and context matching a query."""
    payload = {
        "query": query,
        "max_results": max_results,
        "prefer_observations": True
    }
    return _request(f"/v1/default/banks/{bank}/memories/recall", data=payload, method="POST")


def reflect(query: str, bank: str = DEFAULT_BANK) -> dict:
    """Synthesize high-level mental models and observations over existing memories."""
    payload = {
        "query": query
    }
    return _request(f"/v1/default/banks/{bank}/reflect", data=payload, method="POST")


def get_stats(bank: str = DEFAULT_BANK) -> dict:
    """Get statistics for the specified memory bank."""
    return _request(f"/v1/default/banks/{bank}/stats", method="GET")


def check_health() -> dict:
    """Check health and database connectivity of Hindsight server."""
    return _request("/health", method="GET")


def main():
    parser = argparse.ArgumentParser(description="Hindsight Agent Memory CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Health
    subparsers.add_parser("health", help="Check Hindsight server health")

    # Retain
    p_retain = subparsers.add_parser("retain", help="Store a memory into Hindsight")
    p_retain.add_argument("content", type=str, help="Content to retain")
    p_retain.add_argument("--bank", type=str, default=DEFAULT_BANK, help="Bank ID")
    p_retain.add_argument("--async", dest="async_mode", action="store_true", help="Retain asynchronously")

    # Recall
    p_recall = subparsers.add_parser("recall", help="Retrieve memories for a query")
    p_recall.add_argument("query", type=str, help="Search query")
    p_recall.add_argument("--bank", type=str, default=DEFAULT_BANK, help="Bank ID")
    p_recall.add_argument("--limit", type=int, default=5, help="Max results")

    # Reflect
    p_reflect = subparsers.add_parser("reflect", help="Synthesize mental models over memories")
    p_reflect.add_argument("query", type=str, help="Reflection focus / query")
    p_reflect.add_argument("--bank", type=str, default=DEFAULT_BANK, help="Bank ID")

    # Stats
    p_stats = subparsers.add_parser("stats", help="Get bank statistics")
    p_stats.add_argument("--bank", type=str, default=DEFAULT_BANK, help="Bank ID")

    args = parser.parse_args()

    if args.command == "health":
        print(json.dumps(check_health(), indent=2, ensure_ascii=False))
    elif args.command == "retain":
        res = retain(args.content, bank=args.bank, async_mode=args.async_mode)
        print(f"Retained successfully in bank '{args.bank}': {res.get('items_count', 1)} item(s).")
    elif args.command == "recall":
        res = recall(args.query, bank=args.bank, max_results=args.limit)
        results = res.get("results", [])
        print(f"Recalled {len(results)} memory/memories for '{args.query}':\n")
        for i, item in enumerate(results, 1):
            score = item.get("scores", {}).get("final", 0.0)
            text = item.get("text", "")
            entities = ", ".join(item.get("entities", []))
            print(f"[{i}] (Score: {score:.3f}) {text}")
            if entities:
                print(f"    Entities: {entities}")
            print()
    elif args.command == "reflect":
        res = reflect(args.query, bank=args.bank)
        print(json.dumps(res, indent=2, ensure_ascii=False))
    elif args.command == "stats":
        print(json.dumps(get_stats(args.bank), indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
