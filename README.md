# vibe-git

A zsh plugin for smart gitignore management and AI-powered git commit messages.

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
```

| Flag | Description |
|------|-------------|
| `-g` | Use global gitignore (`core.excludesfile`) |
| `-f` | Force untrack: run `git rm -r --cached` for already-tracked items |

### `gc` / `gitcommit`

Stage all changes and commit with a message. When no message is provided, it calls an AI CLI (Claude, OpenCode, or ACPX) to auto-generate a Conventional Commits message based on the staged diff.

```zsh
# AI generates the commit message
gc

# Provide your own message
gc "fix: resolve null pointer in user service"
```

AI generation order: `claude` → `opencode` → `acpx`. The prompt asks for Chinese, Conventional Commits format.

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
- One of: `claude` (Claude Code CLI), `opencode`, or `acpx` — only needed for AI-powered commit message generation
