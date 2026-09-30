# Layer Specific Rules & Dependency Flow

### 1. The Dependency Rule
Dependencies must only point **inwards** toward the core logic (Domain).
*   **Domain** knows nothing about Data or Presentation.
*   **Data** depends on Domain (to implement repositories).
*   **Presentation** depends on Domain (to execute use cases or get entities).

### 2. Layers Responsibility

#### Presentation Layer (UI)
*   **Goal**: Display information and handle user interaction.
*   **Contains**: Widgets, Screens, Providers, ViewModels.
*   **Rule**: Must NOT contain business logic or raw API calls.

#### Domain Layer (Business Logic)
*   **Goal**: The "heart" of the app. Contains the business rules.
*   **Contains**: Entities (plain classes), Use Cases, Repository Interfaces.
*   **Rule**: Must depend on NO other layers.

#### Data Layer (Implementation)
*   **Goal**: How we get the data.
*   **Contains**: Repository Implementations, Data Sources, Models (DTOs).
*   **Rule**: Handles JSON serialization and caching logic.

### 3. Folder Structure per Feature
```text
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── pages/
    └── widgets/
```
