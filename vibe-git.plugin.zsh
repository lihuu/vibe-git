# vibe-git — A Zsh plugin with smart git utilities and i18n support.
#
# Environment variables:
#   VG_LANG   Force language override. Set to "zh" or "en".
#             If unset, falls back to $LANG system locale.
#
# Functions:
#
#   gitignore (alias: gi)
#     Manage .gitignore entries with optional index cleanup.
#     Usage:
#       gi <pattern>            Add pattern to .gitignore in current repo
#       gi -g <pattern>         Add pattern to global .gitignore
#       gi -f <pattern>         Add pattern and remove matching files from Git index
#       gi -g -f <pattern>      Combine global + force-untrack
#
#   gitcommit (alias: gc)
#     Stage all changes and commit. When no message is provided,
#     calls an AI client to generate one following the Conventional
#     Commits specification.
#     Supported backends: claude, copilot, qwen, codex, gemini,
#                         opencode, aichat, acpx.
#     Default auto-detect order: claude > codex > gemini > qwen >
#                                copilot > opencode > aichat > acpx.
#     Usage:
#       gc                          Auto-stage, AI-generate, and commit
#       gc "fix: my message"        Auto-stage and commit with the message
#       gc -a qwen                  Force backend (also: --agent qwen)
#       gc -a gemini "fix: foo"     Backend ignored when message is given
#
#   gh-unlock
#     Unlock the macOS login keychain over a remote SSH session.
#     Prompts for the login password; unlocks for 30 minutes.
#     No-op on local sessions or non-macOS systems.
#
#   gh-lock
#     Lock the macOS login keychain in a remote SSH session.
#     No-op on local sessions or non-macOS systems.
#
# ----------------------------------------------------------------
# Internationalization (i18n)
# ----------------------------------------------------------------
_vg_detect_lang() {
    local lang="${VG_LANG:-${LANG:-en_US}}"
    case "$lang" in
        zh_*) echo "zh" ;;
        *)    echo "en" ;;
    esac
}

_vg_msg() {
    local key="$1"; shift
    local lang=$(_vg_detect_lang)
    case "$key:$lang" in
        # gitignore
        "unknown_option:zh")     echo "未知选项: $1" ;;
        "unknown_option:en")     echo "Unknown option: $1" ;;
        "no_repo:zh")            echo "❌ 错误：未检测到 Git 仓库。修改全局配置请用 -g。" ;;
        "no_repo:en")            echo "❌ Error: No Git repository detected. Use -g for global config." ;;
        "usage_gi:zh")           echo "用法: gitignore [-g] [-f] [内容...]" ;;
        "usage_gi:en")           echo "Usage: gitignore [-g] [-f] [content...]" ;;
        "already_exists:zh")     echo "提示：'$1' 已存在。" ;;
        "already_exists:en")     echo "Note: '$1' already exists." ;;
        "added:zh")              echo "✅ 已添加 '$1' 至 $2" ;;
        "added:en")              echo "✅ Added '$1' to $2" ;;
        "removed_from_index:zh") echo "🗑️  已从 Git 索引中移除: $1" ;;
        "removed_from_index:en") echo "🗑️  Removed from Git index: $1" ;;
        # gitcommit
        "no_repo_commit:zh")     echo "❌ 错误：未检测到 Git 仓库。" ;;
        "no_repo_commit:en")     echo "❌ Error: No Git repository detected." ;;
        "calling_ai:zh")         echo "🤖 正在调用 AI tools 生成提交信息..." ;;
        "calling_ai:en")         echo "🤖 Calling AI tools to generate commit message..." ;;
        "no_changes:zh")         echo "⚠️  提示：没有检测到已暂存的变更。" ;;
        "no_changes:en")         echo "⚠️  Note: No staged changes detected." ;;
        "no_ai_client:zh")       echo "❌ 错误：未找到任何受支持的 AI 客户端 (claude/codex/gemini/qwen/copilot/opencode/aichat/acpx)。" ;;
        "no_ai_client:en")       echo "❌ Error: No supported AI client found (claude/codex/gemini/qwen/copilot/opencode/aichat/acpx)." ;;
        "unknown_agent:zh")      echo "❌ 错误：未知后端 '$1'。支持: claude, copilot, qwen, codex, gemini, opencode, aichat, acpx。" ;;
        "unknown_agent:en")      echo "❌ Error: Unknown agent '$1'. Supported: claude, copilot, qwen, codex, gemini, opencode, aichat, acpx." ;;
        "agent_not_installed:zh") echo "❌ 错误：后端 '$1' 未安装或不在 PATH 中。" ;;
        "agent_not_installed:en") echo "❌ Error: Agent '$1' is not installed or not in PATH." ;;
        "missing_agent_value:zh") echo "❌ 错误：-a/--agent 需要一个后端名作为参数。" ;;
        "missing_agent_value:en") echo "❌ Error: -a/--agent requires a backend name." ;;
        "ai_failed:zh")          echo "❌ 错误：AI 生成失败。" ;;
        "ai_failed:en")          echo "❌ Error: AI generation failed." ;;
        "suggested_msg:zh")      echo "--- 推荐信息 ---" ;;
        "suggested_msg:en")      echo "--- Suggested message ---" ;;
        # gh-unlock / gh-lock
        "macos_only:zh")         echo "ℹ️  此脚本仅适用于 macOS 系统。" ;;
        "macos_only:en")         echo "ℹ️  This script is for macOS only." ;;
        "local_session:zh")      echo "💡 当前为本地会话，钥匙串通常已随登录解锁，无需执行此命令。" ;;
        "local_session:en")      echo "💡 Local session: keychain is usually unlocked at login. No action needed." ;;
        "enter_password:zh")     echo -n "🔑 [Remote] 正在通过 SSH 解锁钥匙串，请输入登录密码: " ;;
        "enter_password:en")     echo -n "🔑 [Remote] Unlocking keychain via SSH, enter login password: " ;;
        "unlock_ok:zh")          echo "✅ 解锁成功！30 分钟内有效。" ;;
        "unlock_ok:en")          echo "✅ Unlocked! Valid for 30 minutes." ;;
        "unlock_fail:zh")        echo "❌ 密码错误或解锁失败。" ;;
        "unlock_fail:en")        echo "❌ Wrong password or unlock failed." ;;
        "locked:zh")             echo "🔒 远程会话钥匙串已锁定。" ;;
        "locked:en")             echo "🔒 Remote session keychain locked." ;;
        "no_need_lock:zh")       echo "ℹ️  非远程会话或非 macOS，无需锁定。" ;;
        "no_need_lock:en")       echo "ℹ️  Not a remote session or not macOS. No need to lock." ;;
        *)                       echo "$key" ;;
    esac
}

# 1. Smart gitignore function
gitignore() {
    local use_global=false
    local force_untrack=false
    local items=()
    local target_file=""
    local repo_root=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g) use_global=true; shift ;;
            -f) force_untrack=true; shift ;;
            -*) echo "$(_vg_msg unknown_option "$1")"; return 1 ;;
            *) items+=("$1"); shift ;;
        esac
    done

    if [ "$use_global" = true ]; then
        target_file=$(git config --get core.excludesfile)
        target_file="${target_file/#\~/$HOME}"
        if [ -z "$target_file" ]; then
            target_file="$HOME/.gitignore_global"
            git config --global core.excludesfile "$target_file"
        fi
    else
        repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "$(_vg_msg no_repo)"
            return 1
        fi
        target_file="$repo_root/.gitignore"
    fi

    if [ ${#items[@]} -eq 0 ]; then
        echo "$(_vg_msg usage_gi)"
        return 0
    fi

    for item in "${items[@]}"; do
        touch "$target_file"
        if grep -Fxq "$item" "$target_file"; then
            echo "$(_vg_msg already_exists "$item")"
        else
            echo "$item" >> "$target_file"
            echo "$(_vg_msg added "$item" "$target_file")"
        fi

        if [ "$force_untrack" = true ] && [ "$use_global" = false ]; then
            if git ls-files --error-unmatch "$item" > /dev/null 2>&1; then
                git rm -r --cached "$item" > /dev/null 2>&1
                echo "$(_vg_msg removed_from_index "$item")"
            fi
        fi
    done
}

# Dispatch a prompt to a specific AI backend.
# Args: $1 = backend name, $2 = prompt
# Echoes the model's response on stdout. Returns non-zero on failure.
_vg_ai_call() {
    local backend="$1"
    local prompt="$2"
    case "$backend" in
        claude)   claude -p "$prompt" --model "haiku" 2>/dev/null ;;
        copilot)  copilot -p "$prompt" --allow-all-tools 2>/dev/null ;;
        qwen)     qwen -p "$prompt" 2>/dev/null ;;
        codex)    codex exec --skip-git-repo-check "$prompt" 2>/dev/null ;;
        gemini)   gemini -p "$prompt" 2>/dev/null ;;
        opencode) opencode run "$prompt" 2>/dev/null ;;
        aichat)   aichat "$prompt" 2>/dev/null ;;
        acpx)     acpx claude "$prompt" 2>/dev/null ;;
        *)        return 127 ;;
    esac
}

# 2. AI-powered gitcommit function
gitcommit() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "$(_vg_msg no_repo_commit)"
        return 1
    fi

    local agent=""
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--agent)
                if [ -z "$2" ]; then
                    echo "$(_vg_msg missing_agent_value)"
                    return 1
                fi
                agent="$2"; shift 2 ;;
            *)
                args+=("$1"); shift ;;
        esac
    done

    if [ -n "$agent" ]; then
        case "$agent" in
            claude|copilot|qwen|codex|gemini|opencode|aichat|acpx) ;;
            *) echo "$(_vg_msg unknown_agent "$agent")"; return 1 ;;
        esac
    fi

    git add .

    local msg="${args[*]}"

    if [ -z "$msg" ]; then
        echo "$(_vg_msg calling_ai)"

        local diff_summary=$(git diff --cached --stat)
        local diff_content=$(git diff --cached | head -c 8000)

        if [ -z "$diff_content" ]; then
            echo "$(_vg_msg no_changes)"
            return 0
        fi

        local prompt="You are a senior software engineer. Generate a commit message following the Conventional Commits specification based on the provided git diff.
Requirements:
1. Format: <type>(<scope>): <subject>\n\n<body>
2. Type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
3. Language: English.
4. Output: raw text only, no Markdown.

Change summary:
$diff_summary

Code diff:
$diff_content"

        if [ -n "$agent" ]; then
            if ! command -v "$agent" >/dev/null 2>&1; then
                echo "$(_vg_msg agent_not_installed "$agent")"
                return 1
            fi
            msg=$(_vg_ai_call "$agent" "$prompt")
        else
            local b
            for b in claude codex gemini qwen copilot opencode aichat acpx; do
                if command -v "$b" >/dev/null 2>&1; then
                    msg=$(_vg_ai_call "$b" "$prompt")
                    [ -n "$msg" ] && break
                fi
            done
            if [ -z "$msg" ]; then
                echo "$(_vg_msg no_ai_client)"
                return 1
            fi
        fi

        if [ -z "$msg" ]; then echo "$(_vg_msg ai_failed)"; return 1; fi
        echo -e "\n$(_vg_msg suggested_msg)\n$msg\n----------------\n"
    fi

    git commit -m "$msg"
}


# ----------------------------------------------------------------
# GitHub Keychain Remote Helper (Smart Context Version)
# ----------------------------------------------------------------

# Internal environment detection (not exported, for logic only)
function _is_remote_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 1
    fi
    if [[ -z "$SSH_TTY" && -z "$SSH_CLIENT" && -z "$SSH_CONNECTION" ]]; then
        return 2
    fi
    return 0
}

# Unlock function
function gh-unlock() {
    _is_remote_macos
    local env_status=$?

    if [[ $env_status -eq 1 ]]; then
        echo "$(_vg_msg macos_only)"
        return 0
    elif [[ $env_status -eq 2 ]]; then
        echo "$(_vg_msg local_session)"
        return 0
    fi

    local kc="${MAC_KEYCHAIN_DB:-$HOME/Library/Keychains/login.keychain-db}"
    local timeout=1800

    echo "$(_vg_msg enter_password)"
    read -s password
    echo ""

    if security unlock-keychain -p "$password" "$kc" 2>/dev/null; then
        security set-keychain-settings -t "$timeout" -l "$kc"
        echo "$(_vg_msg unlock_ok)"
        command -v gh >/dev/null 2>&1 && gh auth status
    else
        echo "$(_vg_msg unlock_fail)"
        return 1
    fi
}

# Lock function
function gh-lock() {
    _is_remote_macos
    if [[ $? -eq 0 ]]; then
        local kc="${MAC_KEYCHAIN_DB:-$HOME/Library/Keychains/login.keychain-db}"
        security lock-keychain "$kc" && echo "$(_vg_msg locked)"
    else
        echo "$(_vg_msg no_need_lock)"
    fi
}

gitlog () {
        if ! command -v fzf &>/dev/null; then
            echo "❌ fzf 未安装 / fzf not found"
            echo ""
            echo "📦 安装方法 / Installation:"
            echo "  macOS (Homebrew):   brew install fzf"
            echo "  Ubuntu/Debian:      sudo apt install fzf"
            echo "  Fedora:             sudo dnf install fzf"
            echo "  Arch Linux:         sudo pacman -S fzf"
            echo "  或访问 / Or visit:  https://github.com/junegunn/fzf#installation"
            return 1
        fi

        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# 3. Short aliases
alias gi='gitignore'
alias gc='gitcommit'
