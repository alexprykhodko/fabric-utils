# CLAUDE.md

## Project Overview

Shell utility library for [Fabric](https://github.com/danielmiessler/fabric) — a CLI AI orchestration tool. Provides Zsh functions/aliases for chaining LLM requests via Unix pipes, managing context documents, persisting sessions, and formatting output.

## Languages & Dependencies

- **Zsh** — primary shell scripting language (all shell functions and aliases)
- **Python 3.x** — utility scripts for text processing and terminal formatting
- Python deps in `scripts/requirements.txt`: `mdformat==0.7.22`, `rich==13.9.2`

## Project Structure

```
patterns/           # LLM system prompts (each pattern is a directory with system.md)
  _examples/        # Reference pattern implementations
  _python/          # Shared identity files (prefixed with _ to exclude from alias generation)
  python_class/     # Pattern: generate Python classes
  python_expert/    # Pattern: code review/improvements
  python_summary/   # Pattern: summarize Python code
scripts/
  shell-utils.sh    # Main shell functions and aliases (sourced in user's shell)
  config.sh         # Model preset aliases (p-claude, p-flash, etc.)
  output-format.py  # Rich-formatted LLM output with <think> tag extraction
  sess-format.py    # Session JSON formatter
  md-format.py      # Markdown formatting wrapper (mdformat)
  md-remove-links.py # Strip markdown links
  requirements.txt  # Python dependencies
  tests/            # Integration tests
```

## Setup

```bash
pip3 install -r scripts/requirements.txt
source scripts/shell-utils.sh
```

Fabric must be installed separately. LLM API keys are configured via `fabric -S`.

## Running Tests

```bash
bash scripts/tests/test-python-class.sh
```

Tests require configured Claude and Gemini API keys in Fabric config. Tests are integration-level — they invoke real LLM APIs.

## Key Conventions

### Shell (Zsh)

- Public commands use `ai-` prefix: `ai-format`, `ai-ctx-set`, `ai-sess`
- Context commands: `ai-ctx-*` (add, set, clear, save, load, list, describe)
- Session commands: `ai-sess-*` (new, format)
- Private/internal functions use `_f_` prefix: `_f_init`, `_f_load_pattern_aliases`
- Global aliases (`alias -g`) for model presets (`p-claude`, `p-flash`) and parameters (`p-ctx`, `p-sess`)
- Environment variables: `FABRIC_SCRIPTS`, `FABRIC_CONTEXTS`, `FABRIC_SESSIONS`
- All paths reference `$HOME/.config/fabric/` as the base directory

### Python

- Scripts are Unix filters: read from stdin, write to stdout
- When stdout is a TTY, render rich output; when piped, pass through raw text
- Use `rich` library for styled console output
- Use `re` for text extraction (e.g., `<think>` tags)

### Patterns

- Each pattern lives in `patterns/<name>/system.md`
- Directories prefixed with `_` are excluded from auto-alias generation
- Shared identities use the Fabric plugin syntax: `{{plugin:file:read:<path>}}`
- Pattern aliases are auto-generated at shell init: `patterns/python_class/` becomes `ai-python-class`
- Underscores in pattern names become hyphens in aliases

### Gitignored paths

`.env`, `/contexts`, `/sessions`, `/patterns/loaded` — these are local runtime data.
