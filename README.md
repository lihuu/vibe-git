# vibe-git

A zsh plugin with smart git utilities, AI-powered commit messages, and macOS keychain helpers. Supports English and Chinese (i18n).

## Features

### `gi` / `gitignore`

Quickly add entries to `.gitignore` (local or global), with optional force-untrack of already-indexed files.

```zsh
# Add to local .gitignore
gi node_modules .env

# Add to global .gitignore
gi -g .DS_Store

# Add and remove from git index if already tracked
gi -f build/

# Combine: add to global + force-untrack from current repo
gi -g -f secrets.json
```

| Flag | Description |
|------|-------------|
| `-g` | Use global gitignore (`core.excludesfile`) |
| `-f` | Force untrack: run `git rm -r --cached` for already-tracked items |

### `gc` / `gitcommit`

Stage all changes and commit with a message. When no message is provided, it calls an AI CLI to auto-generate a [Conventional Commits](https://www.conventionalcommits.org/) message based on the staged diff.

```zsh
# AI generates the commit message (auto-detect backend)
gc

# Provide your own message
gc "fix: resolve null pointer in user service"

# Force a specific AI backend
gc -a qwen
gc --agent gemini

# Backend flag is ignored when a message is provided
gc -a gemini "chore: bump deps"
```

**Supported AI backends:** `claude`, `copilot`, `qwen`, `codex`, `gemini`, `opencode`, `aichat`, `acpx`

**Auto-detect order:** `claude` → `codex` → `gemini` → `qwen` → `copilot` → `opencode` → `aichat` → `acpx`

The first installed backend in PATH is used. The generated message follows Conventional Commits format in English.

| Flag | Description |
|------|-------------|
| `-a`, `--agent <name>` | Force a specific AI backend instead of auto-detect |

### `gh-unlock` / `gh-lock`

macOS login keychain helpers for remote SSH sessions. On a local session or non-macOS systems, these are no-ops with an informational message.

```zsh
# Unlock the login keychain over SSH (valid for 30 minutes)
gh-unlock

# Lock it again
gh-lock
```

`gh-unlock` prompts for your login password, unlocks `~/Library/Keychains/login.keychain-db`, and runs `gh auth status` if the GitHub CLI is installed. Override the keychain path with the `MAC_KEYCHAIN_DB` environment variable.

## Configuration

| Variable | Description |
|----------|-------------|
| `VG_LANG` | Force UI language. Set to `zh` or `en`. Falls back to `$LANG` if unset. |
| `MAC_KEYCHAIN_DB` | Override the macOS keychain path used by `gh-unlock` / `gh-lock`. |

## Installation

### Oh My Zsh

```zsh
git clone https://github.com/lihuu/vibe-git.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/vibe-git
```

Then add `vibe-git` to your plugin list in `~/.zshrc`:

```zsh
plugins=(... vibe-git)
```

### Manual

```zsh
git clone https://github.com/lihuu/vibe-git.git ~/.zsh/vibe-git
echo 'source ~/.zsh/vibe-git/vibe-git.plugin.zsh' >> ~/.zshrc
```

## Requirements

- zsh
- git
- (Optional) Any one of `claude`, `copilot`, `qwen`, `codex`, `gemini`, `opencode`, `aichat`, `acpx` — only needed for AI-powered commit message generation
- (Optional) macOS + `gh` CLI — only for `gh-unlock` / `gh-lock`
