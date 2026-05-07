
# 1. 智能 gitignore 函数
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
            -*) echo "未知选项: $1"; return 1 ;;
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
            echo "❌ 错误：未检测到 Git 仓库。修改全局配置请用 -g。"
            return 1
        fi
        target_file="$repo_root/.gitignore"
    fi

    if [ ${#items[@]} -eq 0 ]; then
        echo "用法: gitignore [-g] [-f] [内容...]"
        return 0
    fi

    for item in "${items[@]}"; do
        touch "$target_file"
        if grep -Fxq "$item" "$target_file"; then
            echo "提示：'$item' 已存在。"
        else
            echo "$item" >> "$target_file"
            echo "✅ 已添加 '$item' 至 $target_file"
        fi

        if [ "$force_untrack" = true ] && [ "$use_global" = false ]; then
            if git ls-files --error-unmatch "$item" > /dev/null 2>&1; then
                git rm -r --cached "$item" > /dev/null 2>&1
                echo "🗑️  已从 Git 索引中移除: $item"
            fi
        fi
    done
}

# 2. AI 驱动的 gitcommit 函数
gitcommit() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "❌ 错误：未检测到 Git 仓库。"
        return 1
    fi

    git add .

    local msg="$*"

    if [ -z "$msg" ]; then
        echo "🤖 正在调用 AI tools 生成提交信息..."

        local diff_summary=$(git diff --cached --stat)
        local diff_content=$(git diff --cached | head -c 8000)

        if [ -z "$diff_content" ]; then
            echo "⚠️  提示：没有检测到已暂存的变更。"
            return 0
        fi

        local prompt="你是一个资深的软件工程师。请根据提供的 git diff 生成一个遵循 Conventional Commits 规范的提交信息。
要求：
1. 格式：<type>(<scope>): <subject>\n\n<body>
2. Type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert。
3. 语言：英文。
4. 输出：只输出原始文本，无 Markdown。

变更统计：
$diff_summary

代码 Diff：
$diff_content"

        if command -v claude >/dev/null 2>&1; then
            msg=$(claude -p "$prompt" --model "haiku" 2>/dev/null)
        elif command -v opencode >/dev/null 2>&1; then
            msg=$(opencode run "$prompt" 2>/dev/null)
        elif command -v acpx >/dev/null 2>&1; then
            msg=$(acpx claude "$prompt" 2>/dev/null)
        else
            echo "❌ 错误：未找到 claude 或 ACP 客户端。"
            return 1
        fi

        if [ -z "$msg" ]; then echo "❌ 错误：AI 生成失败。"; return 1; fi
        echo -e "\n--- 推荐信息 ---\n$msg\n----------------\n"
    fi

    git commit -m "$msg"
}


# ----------------------------------------------------------------
# GitHub Keychain 远程助手 (Smart Context Version)
# ----------------------------------------------------------------

# 内部环境检测函数（不对外暴露，仅供逻辑判断）
function _is_remote_macos() {
    # 1. 检查是否为 macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 1
    fi
    # 2. 检查是否处于 SSH 会话 (检查 SSH_TTY 或 SSH_CLIENT)
    if [[ -z "$SSH_TTY" && -z "$SSH_CLIENT" && -z "$SSH_CONNECTION" ]]; then
        return 2
    fi
    return 0
}

# 解锁函数
function gh-unlock() {
    _is_remote_macos
    local env_status=$?

    if [[ $env_status -eq 1 ]]; then
        echo "ℹ️  此脚本仅适用于 macOS 系统。"
        return 0
    elif [[ $env_status -eq 2 ]]; then
        echo "💡 当前为本地会话，钥匙串通常已随登录解锁，无需执行此命令。"
        return 0
    fi

    # 只有远程 macOS 才会走到这里
    local kc="${MAC_KEYCHAIN_DB:-$HOME/Library/Keychains/login.keychain-db}"
    local timeout=1800 

    echo -n "🔑 [Remote] 正在通过 SSH 解锁钥匙串，请输入登录密码: "
    read -s password
    echo ""

    if security unlock-keychain -p "$password" "$kc" 2>/dev/null; then
        security set-keychain-settings -t "$timeout" -l "$kc"
        echo "✅ 解锁成功！30 分钟内有效。"
        command -v gh >/dev/null 2>&1 && gh auth status
    else
        echo "❌ 密码错误或解锁失败。"
        return 1
    fi
}

# 加锁函数
function gh-lock() {
    _is_remote_macos
    if [[ $? -eq 0 ]]; then
        local kc="${MAC_KEYCHAIN_DB:-$HOME/Library/Keychains/login.keychain-db}"
        security lock-keychain "$kc" && echo "🔒 远程会话钥匙串已锁定。"
    else
        echo "ℹ️  非远程会话或非 macOS，无需锁定。"
    fi
}

# 3. 设置短别名（Alias）
alias gi='gitignore'
alias gc='gitcommit'
