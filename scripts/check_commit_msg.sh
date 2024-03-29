#!/bin/sh

# 获取两个参数：起始SHA和结束SHA
start_sha=$1
end_sha=$2

# 从commitlint.config.js导入rules变量
rules=$(node -e "console.log(require('./commitlint.config.js').rules['type-enum'][2].join('|'))")

# 解析 JSON 数据并获取规则
if [ "$rules" ]; then
    level=$(echo "$rules" | jq -r '.[0]')
    applicable=$(echo "$rules" | jq -r '.[1]')
    values=$(echo "$rules" | jq -r '.[2] | join("|")')

    # 检查规则是否满足条件
    if [ "$applicable" = "always" ] && [ "$values" ]; then
        formatted_values="$values"
    fi
fi

echo "Formatted Values: $formatted_values"

# 输出规则
echo "Rules: $rules"

# 设置颜色变量
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义提交信息规范函数
check_commit_message() {
    commit_msg="$1"
    # 检查提交信息是否以指定的前缀开头
    # 使用外部文件的规则进行匹配检查
    if ! echo "$commit_msg" | grep -qE "^($formatted_values):"; then
        echo -e "${RED}Error:${NC} Commit message format is incorrect. It should start with one of '${BLUE}$rules:${NC}'." >&2
        exit 1
    fi
}

# 遍历从start_sha到end_sha的所有提交
for sha in $(git rev-list $start_sha..$end_sha); do
    commit_msg=$(git show --format=%B -s $sha)
    check_commit_message "$commit_msg"
done

echo -e "${BLUE}Commit message check passed.${NC}\n"
