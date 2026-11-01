#!/usr/bin/env bash
# Eval: does the design-system MCP improve agent output?
set -uo pipefail
cd "$(dirname "$0")/.."

OUT=app/lib/eval_out
RESULTS=evals/results.csv
rm -rf "$OUT" evals/logs && mkdir -p "$OUT" evals/logs
echo "condition,task,design_ok,uses_knowbutton,analyze_ok" > "$RESULTS"

TASKS=(
  "streak_badge|A small badge showing a study streak like '5 day streak' with a rounded background."
  "flashcard|A flashcard showing a question and a 'Show answer' button that reveals the answer."
  "subject_tile|A tile for a school subject (e.g. Biology) with a title, a progress text and a 'Continue' button."
  "empty_state|An empty state for 'No notes yet' with a short explanation and a 'Create note' button."
)

run_task() {
  local cond=$1 name=$2 desc=$3
  local file="$OUT/${cond}_${name}.dart"
  local prompt="Create a Flutter widget in $file. $desc Write only that one file. Do not modify any other file."

  echo "▶ $cond / $name"
  if [ "$cond" = "mcp" ]; then
    claude -p "$prompt" --mcp-config .mcp.json --strict-mcp-config \
      --allowedTools "Read,Write,Edit,Glob,Grep,mcp__design-system" \
      > "evals/logs/${cond}_${name}.log" 2>&1
  else
    claude -p "$prompt" --strict-mcp-config \
      --allowedTools "Read,Write,Edit,Glob,Grep" \
      > "evals/logs/${cond}_${name}.log" 2>&1
  fi

  # --- scoring ---
  local design=0 button=0 analyze=0
  ./mcp/bin/ds-mcp --root . --check "$file" > /dev/null 2>&1 && design=1
  grep -q "KnowButton" "$file" 2> /dev/null && button=1
  (cd app && flutter analyze "lib/eval_out/${cond}_${name}.dart" > /dev/null 2>&1) && analyze=1

  echo "$cond,$name,$design,$button,$analyze" >> "$RESULTS"
}

for cond in baseline mcp; do
  for t in "${TASKS[@]}"; do
    run_task "$cond" "${t%%|*}" "${t#*|}"
  done
done

echo
echo "=== results ==="
column -s, -t "$RESULTS"
echo
awk -F, 'NR>1 { d[$1]+=$3; b[$1]+=$4; a[$1]+=$5; n[$1]++ }
  END { for (c in n) printf "%-9s design %d/%d   knowbutton %d/%d   analyze %d/%d\n", c, d[c], n[c], b[c], n[c], a[c], n[c] }' "$RESULTS"