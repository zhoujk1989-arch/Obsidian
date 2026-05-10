#!/usr/bin/env bash
set -u
repo="/Users/zhoujingkun/Documents/GitHub/Obsidian/WisdomLedger"
table_dir="/Users/zhoujingkun/Downloads/east_mysql_sp_requirements_md_processed"
state_dir="$repo/.codex-batch/east-opencode-sql-requirements"
done_dir="$state_dir/done"
failed_dir="$state_dir/failed"
log_dir="$state_dir/logs"
model="lmstudio/qwen/qwen3.6-35b-a3b"

mkdir -p "$done_dir" "$failed_dir" "$log_dir"

run_id="$(date +%Y%m%d%H%M%S)"
main_log="$log_dir/batch-$run_id.log"
latest_file="$state_dir/latest"
pid_file="$state_dir/pid"

echo "$$" > "$pid_file"
echo "$main_log" > "$latest_file"

prompt='按本仓库 AGENTS.md  严格参考markdown中的每一个开发细节和需求逻辑开发SQL/存储过程开发工作流。'

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

  opencode run \
    --dangerously-skip-permissions \
    --model "$model" \
    --dir "$repo" \
    --file "$file" \
    --title "ybt-ingest-$base" \
    "$prompt" < /dev/null >> "$item_log" 2>&1
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
