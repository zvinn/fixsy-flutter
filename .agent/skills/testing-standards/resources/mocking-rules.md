# Mocking Rules & Best Practices

Isolating components is key to fast and reliable tests.

### 1. What to Mock
- **External Dependencies**: APIs, Databases, Shared Preferences.
- **Other Layers**: If testing a Bloc, mock its Repository. If testing a Repository, mock its Data Source.

### 2. Libraries
- Use `mockito` or `mocktail`.
- Use `@GenerateMocks` for `mockito` where possible.

### 3. Verification
- Always verify that critical methods were called.
- **Example**: `verify(() => mockRepo.getData()).called(1);`

### 4. Shared Mocks
- If a mock is used in multiple files, consider creating a `test/mocks/` directory to share definitions.
