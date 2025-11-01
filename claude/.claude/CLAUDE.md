# System-Wide Claude Code Instructions

This file provides global guidance to Claude Code across all projects.

## Tool Aliases

This environment has shell aliases that replace standard UNIX tools with modern alternatives:
- **`grep`** → `rg` (ripgrep)
- **`find`** → `fd`
- **`cd`** → `z` (zoxide)

**Important:** These tools have **different APIs** than their UNIX counterparts. When suggesting shell commands:
- Use `rg` syntax (not `grep` syntax) - e.g., `rg "pattern" path` instead of `grep -r "pattern" path`
- Use `fd` syntax (not `find` syntax) - e.g., `fd pattern` instead of `find . -name "pattern"`
- Use `z` behavior - fuzzy matching directory jumps, not standard `cd`

Don't assume standard UNIX flags will work just because the alias exists.

## Working with Claude - Critical Evaluation

**IMPORTANT:** Always critically evaluate requests. Don't just agree because something was asked.

Challenge ideas that:
- Add unnecessary complexity
- Violate KISS (Keep It Simple, Stupid) principles
- Contradict established patterns in the codebase
- Introduce features that aren't actually needed (YAGNI)
- Could be accomplished more simply

Push back with better alternatives. Good collaboration requires thoughtful disagreement.

## Research Guidelines

When exploring codebases or researching solutions:

1. **Use semantic search first** - If chunkhound MCP or similar is available, use it for initial codebase exploration
2. **Run searches in subagents** - Use Task tool with subagent_type=Explore for open-ended queries to save context tokens
3. **Read relevant files** - Use Read tool instead of cat/grep when you know what you're looking for
4. **Glob for patterns** - Use Glob for finding files by name patterns

---

**Note:** Project-specific instructions should be placed in each project's own `CLAUDE.md` file in the project root. This file contains only system-wide preferences.
- don't mention Claude Code in commit messages or PRs