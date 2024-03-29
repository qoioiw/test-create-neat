#!/bin/bash

# 参数验证
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <start_sha> <end_sha>"
    exit 1
fi

# 获取两个参数：起始SHA和结束SHA
start_sha=$1
end_sha=$2

# 从commitlint.config.js导入rules变量
rules=$(node -p "require('./commitlint.config.js').rules['type-enum'][2]")

# 检查规则是否成功获取
if [ -z "$rules" ]; then
    echo "Failed to load rules from commitlint.config.js"
    exit 1
fi

# 将规则转换为 Bash 能够理解的格式
values=$(echo "$rules" | tr -d '[],' | sed 's/\"//g' | tr '\n' '|')
values="${values%|}"  # 移除最后一个管道符号

# 输出规则
echo "Rules: $values"

# 设置颜色变量
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义提交信息规范函数
check_commit_message() {
    commit_msg="$1"
    # 检查提交信息是否以指定的前缀开头
    # 使用外部文件的规则进行匹配检查
    if ! echo "$commit_msg" | grep -qE "^($values):"; then
        echo -e "${RED}Error:${NC} Commit message format is incorrect. It should start with one of '${BLUE}$values:${NC}'." >&2
        exit 1
    fi
}

# 遍历从start_sha到end_sha的所有提交
for sha in $(git rev-list $start_sha..$end_sha); do
    commit_msg=$(git show --format=%B -s $sha)
    check_commit_message "$commit_msg"
done

echo -e "${BLUE}Commit message check passed.${NC}\n"
