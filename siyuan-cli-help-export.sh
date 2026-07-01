#!/usr/bin/env bash
set -Eeuo pipefail

# 递归执行 SiYuan CLI 各级命令的 --help，并汇总为 Markdown 文档。
# 默认输出：当前目录/siyuan-cli-help.md

SIYUAN_BIN="${SIYUAN_BIN:-}"
OUTPUT_FILE="$PWD/siyuan-cli-help.md"
MAX_DEPTH="${MAX_DEPTH:-20}"

usage() {
  cat <<'USAGE'
用法：
  siyuan-cli-help-export.sh [选项]

选项：
  -o, --output FILE       指定输出的 Markdown 文件
  -b, --bin PATH          指定 siyuan 可执行文件或命令名
      --max-depth NUMBER  最大递归层级，默认 20
  -h, --help              显示本帮助

环境变量：
  SIYUAN_BIN              与 --bin 相同
  MAX_DEPTH               与 --max-depth 相同

示例：
  ./siyuan-cli-help-export.sh
  ./siyuan-cli-help-export.sh -o "$HOME/Documents/思源CLI完整帮助.md"
  SIYUAN_BIN="$HOME/.local/bin/siyuan" ./siyuan-cli-help-export.sh
USAGE
}

while (($# > 0)); do
  case "$1" in
    -o|--output)
      [[ $# -ge 2 ]] || { echo "❌ $1 缺少文件路径" >&2; exit 2; }
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -b|--bin)
      [[ $# -ge 2 ]] || { echo "❌ $1 缺少命令或路径" >&2; exit 2; }
      SIYUAN_BIN="$2"
      shift 2
      ;;
    --max-depth)
      [[ $# -ge 2 ]] || { echo "❌ $1 缺少数字" >&2; exit 2; }
      MAX_DEPTH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "❌ 未知参数：$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]] || ((MAX_DEPTH < 1)); then
  echo "❌ --max-depth 必须是大于 0 的整数" >&2
  exit 2
fi

if [[ -z "$SIYUAN_BIN" ]]; then
  SIYUAN_BIN="$(command -v siyuan || command -v SiYuan-Kernel || true)"
fi

if [[ -z "$SIYUAN_BIN" ]]; then
  echo "❌ 找不到 siyuan 或 SiYuan-Kernel 命令" >&2
  echo "   请确认 CLI 已加入 PATH，或使用 --bin 指定完整路径。" >&2
  exit 1
fi

if ! SIYUAN_PATH=$(command -v -- "$SIYUAN_BIN" 2>/dev/null); then
  if [[ -x "$SIYUAN_BIN" ]]; then
    SIYUAN_PATH="$SIYUAN_BIN"
  else
    echo "❌ 找不到可执行命令：$SIYUAN_BIN" >&2
    echo "   请确认 CLI 已加入 PATH，或使用 --bin 指定完整路径。" >&2
    exit 1
  fi
fi

ROOT_NAME=$(basename -- "$SIYUAN_PATH")
OUTPUT_DIR=$(dirname -- "$OUTPUT_FILE")
mkdir -p -- "$OUTPUT_DIR"

TMP_DIR=$(mktemp -d)
BODY_FILE="$TMP_DIR/body.md"
INDEX_FILE="$TMP_DIR/index.md"
ERROR_FILE="$TMP_DIR/errors.log"
trap 'rm -rf -- "$TMP_DIR"' EXIT

: > "$BODY_FILE"
: > "$INDEX_FILE"
: > "$ERROR_FILE"

declare -A SEEN=()
TOTAL=0
FAILED=0

# 从 Cobra 风格帮助文本的命令列表中提取子命令名称。
extract_subcommands() {
  awk '
    /^(Available Commands|Additional help topics):[[:space:]]*$/ {
      in_commands = 1
      next
    }
    in_commands && /^[[:space:]]*$/ {
      in_commands = 0
      next
    }
    in_commands {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (line ~ /^[[:alnum:]_-]+[[:space:]]+/) {
        split(line, fields, /[[:space:]]+/)
        print fields[1]
      }
    }
  ' | awk '!seen[$0]++'
}

make_github_anchor() {
  local value="$1"
  value=${value,,}
  value=${value// /-}
  value=${value//\//-}
  value=${value//_/}
  value=${value//\`/}
  printf '%s' "$value"
}

collect_help() {
  local -a command_path=("$@")
  local depth=${#command_path[@]}

  if ((depth > MAX_DEPTH)); then
    printf '超过最大递归层级，跳过：%s %s\n' \
      "$ROOT_NAME" "${command_path[*]}" >> "$ERROR_FILE"
    return
  fi

  local key="__root__"
  local display="$ROOT_NAME"
  if ((depth > 0)); then
    key="${command_path[*]}"
    display+=" ${command_path[*]}"
  fi

  [[ ${SEEN[$key]+exists} ]] && return
  SEEN[$key]=1
  ((TOTAL += 1))

  echo "🔎 $display --help"

  local -a invocation=("$SIYUAN_PATH")
  invocation+=("${command_path[@]}")
  invocation+=(--help)

  local help_text status=0
  help_text=$(LC_ALL=C "${invocation[@]}" 2>&1) || status=$?

  local anchor
  anchor=$(make_github_anchor "$display")
  printf -- '- [`%s`](#%s)\n' "$display" "$anchor" >> "$INDEX_FILE"

  {
    printf '## `%s`\n\n' "$display"
    printf '执行命令：`%s --help`\n\n' "$display"
    printf '````text\n%s\n````\n\n' "$help_text"
  } >> "$BODY_FILE"

  if ((status != 0)); then
    ((FAILED += 1))
    printf '%s --help 返回状态码 %d\n' "$display" "$status" >> "$ERROR_FILE"
    return
  fi

  local -a children=()
  mapfile -t children < <(printf '%s\n' "$help_text" | extract_subcommands)

  local child
  for child in "${children[@]}"; do
    [[ -n "$child" ]] || continue
    collect_help "${command_path[@]}" "$child"
  done
}

VERSION=$(LC_ALL=C "$SIYUAN_PATH" --version 2>&1 || true)
GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S %z')

collect_help

FINAL_TMP="$TMP_DIR/final.md"
{
  printf '# 思源 CLI 完整帮助\n\n'
  printf '> 本文档由 `%s` 自动递归执行各级命令的 `--help` 生成。\n\n' "$ROOT_NAME"
  printf -- '- 生成时间：`%s`\n' "$GENERATED_AT"
  printf -- '- CLI 版本：`%s`\n' "${VERSION//$'\n'/ }"
  printf -- '- 可执行命令：`%s`\n' "$ROOT_NAME"
  printf -- '- 收录命令：`%d` 个\n' "$TOTAL"
  printf -- '- 帮助读取失败：`%d` 个\n\n' "$FAILED"
  printf '脚本只调用各级命令的 `--help`，不会执行文档修改、同步、导入或删除操作。\n\n'
  printf '## 命令目录\n\n'
  cat "$INDEX_FILE"
  printf '\n'
  cat "$BODY_FILE"

  if [[ -s "$ERROR_FILE" ]]; then
    printf '## 抓取提示\n\n'
    printf '````text\n'
    cat "$ERROR_FILE"
    printf '````\n'
  fi
} > "$FINAL_TMP"

mv -- "$FINAL_TMP" "$OUTPUT_FILE"

printf '\n✅ 已生成思源 CLI 帮助合集：%s\n' "$OUTPUT_FILE"
printf '   共收录 %d 个命令，失败 %d 个。\n' "$TOTAL" "$FAILED"
