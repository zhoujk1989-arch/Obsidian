#!/usr/bin/env bash
set -u

repo="/Users/zhoujingkun/Documents/GitHub/Obsidian/my-dev-brain"
table_dir="/Users/zhoujingkun/Downloads/一表通报表填报说明Markdown_结构化"
state_dir="$repo/.codex-batch/ybt-hermes-ingest"
done_dir="$state_dir/done"
failed_dir="$state_dir/failed"
log_dir="$state_dir/logs"
model="qwen/qwen3.6-35b-a3b"

mkdir -p "$done_dir" "$failed_dir" "$log_dir"

run_id="$(date +%Y%m%d%H%M%S)"
main_log="$log_dir/batch-$run_id.log"
latest_file="$state_dir/latest"
pid_file="$state_dir/pid"

echo "$$" > "$pid_file"
echo "$main_log" > "$latest_file"

prompt_prefix='按本仓库 AGENTS.md 执行监管类 ingest。

硬约束：
- 只处理下面指定的这一个 Markdown 文件。
- 这个文件属于一表通系统中的报表。
- 不要读取或遍历 /Users/zhoujingkun/Downloads/一表通报表填报说明Markdown_结构化 目录。
- 不要处理任何其它报表文件。
- 不要创建子 agent，不要并行拆分，不要继续处理后续文件。
- 不需要检查质量；完成必要页面更新和日志记录后立刻结束。
- 按监管明细原文模板 ingest 这个填报说明。

本次唯一指定文件：'

file_list="$state_dir/files-$run_id.txt"
find "$table_dir" -maxdepth 1 -type f -name "*.md" | sort > "$file_list"
total="$(wc -l < "$file_list" | tr -d ' ')"

printf '[%s] batch start total=%s model=%s\n' "$(date '+%F %T')" "$total" "$model" | tee -a "$main_log"

index=0
while IFS= read -r file; do
  index=$((index + 1))
  base="$(basename "$file")"
  marker="$(printf '%s' "$base" | shasum -a 256 | awk '{print $1}')"
  done_marker="$done_dir/$marker"
  failed_marker="$failed_dir/$marker"
  item_log="$log_dir/$run_id-$marker.log"

  if [ -f "$done_marker" ]; then
    printf '[%s] skip done [%s/%s] %s\n' "$(date '+%F %T')" "$index" "$total" "$base" | tee -a "$main_log"
    continue
  fi

  rm -f "$failed_marker"
  printf '[%s] start [%s/%s] %s\n' "$(date '+%F %T')" "$index" "$total" "$base" | tee -a "$main_log"

  item_prompt="$prompt_prefix $file"

  (
    cd "$repo" || exit 1
    HERMES_ACCEPT_HOOKS=1 hermes \
      --yolo \
      --accept-hooks \
      --model "$model" \
      --oneshot "$item_prompt"
  ) < /dev/null >> "$item_log" 2>&1
  status="$?"

  if [ "$status" -eq 0 ]; then
    printf '%s\n' "$file" > "$done_marker"
    printf '[%s] done  [%s/%s] %s\n' "$(date '+%F %T')" "$index" "$total" "$base" | tee -a "$main_log"
  else
    printf '%s\nexit=%s\n' "$file" "$status" > "$failed_marker"
    printf '[%s] fail  [%s/%s] %s exit=%s\n' "$(date '+%F %T')" "$index" "$total" "$base" "$status" | tee -a "$main_log"
  fi
done < "$file_list"

printf '[%s] batch end\n' "$(date '+%F %T')" | tee -a "$main_log"
rm -f "$pid_file"
