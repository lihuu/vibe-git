
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
            msg=$(claude -p "$prompt" 2>/dev/null)
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

# 3. 设置短别名（Alias）
alias gi='gitignore'
alias gc='gitcommit'
