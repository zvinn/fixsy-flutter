# Contributing to Fixsy Mobile

Thank you for your interest in contributing to **Fixsy**! Open source is at the heart of what makes developer communities thrive, and we welcome contributions of all kinds.

---

## 🌟 How Can You Contribute?

You can contribute to Fixsy in many ways:
- 🐛 **Reporting Bugs:** Open an issue describing the unexpected behavior, steps to reproduce, and your environment.
- 💡 **Suggesting Features:** Propose ideas for new modules, UI enhancements, or animations.
- 📝 **Improving Documentation:** Fix typos, add translation guides, or improve code comments.
- 💻 **Submitting Code:** Fix issues or implement new features via Pull Requests.

---

## 🛠️ Development Workflow

1. **Fork the Repository:**
   Click the **Fork** button at the top right of the [Fixsy repository](https://github.com/zvinn/fixsy-flutter).

2. **Clone your Fork:**
   ```bash
   git clone https://github.com/<your-username>/fixsy-flutter.git
   cd fixsy-flutter
   ```

3. **Create a Feature Branch:**
   ```bash
   git checkout -b feature/my-new-feature
   ```

4. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

5. **Code Guidelines:**
   - Adhere to Clean Architecture: separate business logic into domain/data/presentation layers.
   - Run static analysis to ensure 0 warnings:
     ```bash
     flutter analyze
     ```
   - Ensure all automated unit and widget tests pass:
     ```bash
     flutter test
     ```

6. **Commit & Push:**
   Use conventional commits (e.g. `feat:`, `fix:`, `docs:`, `refactor:`, `test:`):
   ```bash
   git commit -m "feat: add support for custom service categories"
   git push origin feature/my-new-feature
   ```

7. **Open a Pull Request:**
   Submit your PR against the `main` branch with a clear description of the change and any relevant issue links.

---

## 📜 Code of Conduct

Please be respectful and constructive in all discussions, issues, and pull requests. We are dedicated to providing a harassment-free experience for everyone.

---

Thank you for helping make Fixsy even better! 🚀
