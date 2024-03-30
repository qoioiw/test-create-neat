#!/bin/bash
 
# 获取两个参数：起始SHA和结束SHA
start_sha=$1
end_sha=$2

# 设置颜色变量
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 使用相对路径指定文件位置
file_path="./commitlint.config.js"

# 检查文件是否存在
if [ -f "$file_path" ]; then
    echo "文件已找到：$file_path"
    # 在这里执行文件相关的操作
else
    echo "文件未找到：$file_path"
fi

# 从commitlint.config.js导入rules变量
rules=$(node -e "console.log(require('./commitlint.config.js').rules['type-enum'][2].join('|'))")

echo "Rules: $rules"

# 定义提交信息规范函数
check_commit_message() {
    commit_msg="$1"
    # 检查提交信息是否以指定的前缀开头
    if ! echo "$commit_msg" | grep -qE "$rules"; then
        echo -e "${RED}Error:${NC} Commit message format is incorrect. It should start with one of '${BLUE}feat|fix|docs|style|refactor|test|chore|ci:${NC}'." >&2
        exit 1
    fi
}

# 遍历从start_sha到end_sha的所有提交
for sha in $(git rev-list $start_sha..$end_sha); do
    commit_msg=$(git show --format=%B -s $sha)
    check_commit_message "$commit_msg"
done

echo -e "${BLUE}Commit message check passed.${NC}\n"
