# Environment Context

## Shell Environment

macOS, zsh via z4h (zsh4humans). Dotfiles managed with chezmoi (`~/.local/share/chezmoi/`).

### Modern Tool Replacements

The following classic Unix tools are aliased to modern replacements. When running
commands on my behalf, **always prefer the modern tool directly** — do not use the
classic tool name, as the output format will differ from what you expect.

| Classic | Replacement | Notes |
|---------|-------------|-------|
| `find`  | `fd`        | Different flag syntax; no `-name`, uses regex by default |
| `grep`  | `rg`        | Ripgrep; different flags, no `-r` needed |
| `ls`    | `lsd -lA`   | Also: `l`, `ll` (lsd), `el` (eza) |
| `du`    | `dust`      | Visual tree output, not tabular |
| `df`    | `duf`       | Table output, not classic df format |
| `diff`  | `delta`     | Syntax-highlighted, git-aware |
| `cd`    | `z` (zoxide)| Smart directory jumping |
| `cat`   | `bat`       | Syntax-highlighted pager (available, not aliased) |

When using Claude Code tools (Read, Grep, Glob, etc.), these don't apply — those
tools use their own implementations. This matters when running shell commands via
the Bash tool or when interpreting output I paste from my terminal.

### Key Aliases

- `k` = `kubectl`, `kw` = Koddi kubectl safety wrapper
- `h` = `hatch`, `hr` = `hatch run`
- `db` = `databricks`
- `c` = `chezmoi` (and `ca`, `cr`, `ce`, `cea`, `cap`, `cdf`, `cst`, etc.)
- `rga` = search aliases (ripgrep), `rge` = search env vars (ripgrep)

### Non-Interactive Shell Note

The z4h framework's `.zshenv` exits early for non-interactive shells, so aliases
and functions from `.zshrc` are not available in non-interactive contexts (e.g.,
Claude Code's `!` escape or the Bash tool). When I run `! zsh -ic '...'`, that
forces an interactive shell with full alias support.

## Development Stack

- **Languages**: Python (uv, hatch), Go, Rust, Java (17 default), SQL
- **Cloud**: AWS (Granted/assume for creds), GCP, Azure (Databricks)
- **Infra**: Kubernetes (kubectl + krew), Docker
- **Python tooling**: uv (package manager), hatch (build/env), ruff (lint/format)
- **Editor**: VS Code (default), Sublime Text (quick edits)
- **Git**: 1Password SSH agent, GPG signing, oh-my-zsh git aliases

## Preferences

- I like clean, modern tooling and well-organized configurations.
- When suggesting shell commands, prefer the modern tool over the classic equivalent.
- Don't over-explain things I already know — I'm comfortable with my tools.

## Koddi Context

@~/.claude/koddi-context.md
