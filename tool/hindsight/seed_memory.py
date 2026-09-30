#!/usr/bin/env python3
"""
Seed foundational architectural memories and project rules into Hindsight.
Uses async_mode=True to queue operations cleanly for the background worker.
"""

import time
from hindsight_client import retain, recall

memories = [
    "Fixsy Clean Architecture Structure: Domain Layer contains Entities, Repository Contracts, and UseCases with zero Flutter dependencies. Data Layer contains Data Transfer Objects (Models with fromJson/toJson), RemoteDataSources, LocalDataSources, and Repository Implementations. Presentation Layer contains StateNotifier/ChangeNotifier Providers, Screens, and Reusable Widgets. Never access Cloud Firestore or network APIs directly from UI/Presentation layer.",
    "Fixsy Networking & Security Stack: All network requests must route through the centralized ApiClient utilizing Dio. ApiClient integrates AuthInterceptor, TokenVault backed by FlutterSecureStorage, automatic 401 token refresh queue with lock, and structured AppLogger error handling. Principle III strictly forbids hardcoded API keys or credentials in code; all configuration is driven by .env and EnvConfig.",
    "Fixsy Offline-First & Cache Management: Local caching is powered by CacheManager using Sembast NoSQL storage with configurable TTL and CachePolicy (cacheFirst, networkFirst, staleWhileRevalidate). Background mutation synchronization is handled by offline sync queues.",
    "Fixsy Workflow & Quality Standards: Maintain an active daily git contribution streak with high quality atomic commits. Enforce 0 errors and 0 warnings on 'flutter analyze'. All UI layouts must support first-class Arabic RTL using Directionality and EdgeInsetsDirectional.",
]

print("Seeding foundational Fixsy knowledge into Hindsight (async queue mode)...")
for i, mem in enumerate(memories, 1):
    res = retain(mem, bank="fixsy_agent", async_mode=True)
    print(f"[{i}/{len(memories)}] Queued operation: {res.get('operation_id') or 'ok'}")
    time.sleep(2)

print("\nAll foundational memories queued for worker extraction & indexing.")
