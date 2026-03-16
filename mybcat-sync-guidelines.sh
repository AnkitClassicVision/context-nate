#!/usr/bin/env bash

set -euo pipefail

readonly REPOS_ROOT="/mnt/d_drive/repos"
readonly CANONICAL_GUIDELINES="/mnt/d_drive/repos/context_nate/outputs/CLAUDE-UNIVERSAL.md"
readonly START_MARKER="<!-- MYBCAT-GUIDELINES-START -->"
readonly NOTICE_MARKER="<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines -->"
readonly END_MARKER="<!-- MYBCAT-GUIDELINES-END -->"

created_count=0
updated_count=0
replaced_count=0

if [[ ! -f "${CANONICAL_GUIDELINES}" ]]; then
  echo "Canonical guidelines file not found: ${CANONICAL_GUIDELINES}" >&2
  exit 1
fi

render_managed_block() {
  local synced_at="$1"

  printf '%s\n' "${START_MARKER}"
  printf '%s\n' "${NOTICE_MARKER}"
  printf '<!-- Last synced: %s -->\n' "${synced_at}"
  cat "${CANONICAL_GUIDELINES}"
  printf '\n%s\n' "${END_MARKER}"
}

replace_managed_block() {
  local target_file="$1"
  local synced_at="$2"

  python3 - "${target_file}" "${CANONICAL_GUIDELINES}" "${synced_at}" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
guidelines = Path(sys.argv[2]).read_text()
synced_at = sys.argv[3]

start = "<!-- MYBCAT-GUIDELINES-START -->"
notice = "<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines -->"
end = "<!-- MYBCAT-GUIDELINES-END -->"

block = (
    f"{start}\n"
    f"{notice}\n"
    f"<!-- Last synced: {synced_at} -->\n"
    f"{guidelines.rstrip()}\n"
    f"{end}\n"
)

text = target.read_text()
pattern = re.compile(re.escape(start) + r".*?" + re.escape(end) + r"\n?", re.DOTALL)
updated, matches = pattern.subn(block, text, count=1)
if matches != 1:
    raise SystemExit(f"Expected one managed block in {target}")
target.write_text(updated)
PY
}

prepend_managed_block() {
  local target_file="$1"
  local synced_at="$2"
  local tmp_file

  tmp_file="$(mktemp)"
  render_managed_block "${synced_at}" > "${tmp_file}"
  printf '\n' >> "${tmp_file}"
  cat "${target_file}" >> "${tmp_file}"
  mv "${tmp_file}" "${target_file}"
}

create_managed_file() {
  local target_file="$1"
  local synced_at="$2"

  render_managed_block "${synced_at}" > "${target_file}"
}

process_target_file() {
  local target_file="$1"
  local synced_at="$2"

  if [[ -L "${target_file}" ]]; then
    rm "${target_file}"
    create_managed_file "${target_file}" "${synced_at}"
    replaced_count=$((replaced_count + 1))
    return
  fi

  if [[ -f "${target_file}" ]]; then
    if grep -qF "${START_MARKER}" "${target_file}" && grep -qF "${END_MARKER}" "${target_file}"; then
      replace_managed_block "${target_file}" "${synced_at}"
    else
      prepend_managed_block "${target_file}" "${synced_at}"
    fi
    updated_count=$((updated_count + 1))
    return
  fi

  if [[ ! -e "${target_file}" ]]; then
    create_managed_file "${target_file}" "${synced_at}"
    created_count=$((created_count + 1))
    return
  fi

  echo "Skipping non-file path: ${target_file}" >&2
}

while IFS= read -r -d '' repo_dir; do
  synced_at="$(date '+%Y-%m-%d %H:%M:%S')"

  for filename in CLAUDE.md AGENTS.md; do
    process_target_file "${repo_dir}/${filename}" "${synced_at}"
  done
done < <(find "${REPOS_ROOT}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo "MyBCAT guidelines sync complete"
echo "Created: ${created_count}"
echo "Updated: ${updated_count}"
echo "Replaced symlinks: ${replaced_count}"
