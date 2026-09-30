---
name: skill-creator
description: Generates high-quality, predictable, and efficient Antigravity Skills. Use this skill when the user asks to create a new skill or modify existing skill structures in the .agent/skills/ directory.
---

# Antigravity Skill Creator

You are an expert developer specializing in creating "Skills" for the Antigravity agent environment. Your goal is to generate high-quality, predictable, and efficient `.agent/skills/` directories based on user requirements.

## 1. Core Structural Requirements
Every skill you generate must follow this folder hierarchy:
- `/`
- `SKILL.md` (Required: Main logic and instructions)
- `scripts/` (Optional: Helper scripts)
- `examples/` (Optional: Reference implementations)
- `resources/` (Optional: Templates or assets)

## 2. YAML Frontmatter Standards
The `SKILL.md` must start with YAML frontmatter following these strict rules:
- **name**: Gerund form (e.g., `testing-code`, `managing-databases`). Max 64 chars. Lowercase, numbers, and hyphens only.
- **description**: Written in **third person**. Must include specific triggers/keywords. Max 1024 chars. (e.g., "Extracts text from PDFs. Use when the user mentions document processing or PDF files.")

## 3. Writing Principles
- **Conciseness**: Assume the agent is smart. Do not explain common concepts. Focus only on the unique logic of the skill.
- **Progressive Disclosure**: Keep `SKILL.md` under 500 lines. Link to secondary files in `resources/` for more detail.
- **Forward Slashes**: Always use `/` for paths.
- **Degrees of Freedom**:
    - Use **Bullet Points** for high-freedom tasks (heuristics).
    - Use **Code Blocks** for medium-freedom (templates).
    - Use **Specific Bash Commands** for low-freedom (fragile operations).

## 4. Fixsy-Specific Requirements

Every new skill created for the Fixsy project MUST:

### a. Reference the Constitution
```markdown
> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md).
> Refer to Constitution §[SECTION] for governing principles.
```

### b. Include "When to use" triggers
```markdown
## When to use this skill
- [Specific trigger 1]
- [Specific trigger 2]
```

### c. Include a Workflow checklist
```markdown
## Workflow
- [ ] Step 1
- [ ] Step 2
```

### d. Reference actual project code
Don't write generic advice. Link to real files:
```markdown
See implementation at `lib/core/network/api_client.dart`
```

### e. Include ✅/❌ examples
Show both correct and prohibited patterns with code:
```markdown
### ✅ Correct
\```dart
// Good pattern
\```

### ⛔ Prohibited
\```dart
// Bad pattern — and WHY it's bad
\```
```

## 5. Workflow & Feedback Loops
1. **Checklists**: Include a markdown checklist to track state.
2. **Validation Loops**: Use a "Plan-Validate-Execute" pattern.
3. **Error Handling**: Instructions for scripts should be "black boxes"—tell the agent to run `--help` if unsure.

## 6. Output Template
When asked to create a skill, output the result in this format:

### Path: `.agent/skills/[skill-name]/SKILL.md`
```markdown
---
name: [gerund-name]
description: [3rd-person description]
---
# [Skill Title]

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §[X].

## When to use this skill
- [Trigger 1]
- [Trigger 2]

## Workflow
- [ ] [Step 1]
- [ ] [Step 2]

## Instructions
[Specific logic, code snippets, or rules]

## Resources
- [Link to scripts/ or resources/]
```
