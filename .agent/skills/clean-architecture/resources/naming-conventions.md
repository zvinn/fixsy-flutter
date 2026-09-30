# Naming Conventions & File Organization

Standardized naming makes the project searchable and readable.

### 1. Files & Classes
*   **Repositories**: Interface name should be `[Feature]Repository`. Implementation should be `[Feature]RepositoryImpl`.
*   **Models**: Data Transfer Objects should end in `Model` (e.g., `UserModel`).
*   **Entities**: Pure business objects should have no suffix (e.g., `User`).
*   **Widgets**: UI components should end in `Widget` or `Screen`.
*   **State Management**: Use `Provider` or `Notifier` suffixes.

### 2. Directory Structure Conventions
*   **Core**: Shared logic, themes, and base classes go in `lib/core/`.
*   **Services**: Low-level infrastructure (API, SharedPrefs) goes in `lib/data/services/`.
*   **l10n**: All text must be in localization files, never hardcoded in UI.

### 3. Code Cleanliness (Clean Code)
*   **Functions**: Should do one thing and be small (ideally < 20 lines).
*   **Arguments**: Functions should have 3 or fewer arguments.
*   **Comments**: Use comments to explain *why*, not *what*. Code should be self-documenting.
