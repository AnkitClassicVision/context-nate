#!/usr/bin/env bash

set -euo pipefail

: "${UPDATE_ONLY:=0}"
: "${REPOS_ROOT:=/mnt/d_drive/repos}"
: "${UNIVERSAL_SOURCE:=/mnt/d_drive/repos/context_nate/outputs/CLAUDE-UNIVERSAL.md}"
: "${WOM_DIR:=/mnt/d_drive/repos/OB_mybcat/exports/operating-model}"
: "${CLAUDE_PARENT_FILE:=/mnt/d_drive/repos/.claude/CLAUDE.md}"
: "${DRY_RUN:=0}"

readonly REPOS_ROOT UNIVERSAL_SOURCE WOM_DIR CLAUDE_PARENT_FILE DRY_RUN

readonly START_MARKER="<!-- MYBCAT-GUIDELINES-START -->"
readonly NOTICE_MARKER="<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines -->"
readonly END_MARKER="<!-- MYBCAT-GUIDELINES-END -->"

readonly WOM_START_MARKER="<!-- MYBCAT-WOM-START -->"
readonly WOM_NOTICE_MARKER="<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines (WOM section) -->"
readonly WOM_END_MARKER="<!-- MYBCAT-WOM-END -->"

created_count=0
updated_count=0
replaced_count=0
skipped_count=0
skipped_absent_count=0
universal_synced_count=0
wom_synced_count=0
wom_stripped_count=0

# Claude Code walks up the directory tree, so the parent CLAUDE.md covers all child repos.
# Sync AGENTS.md (Codex) and GEMINI.md (Gemini CLI) per-repo.
# Universal-rules block: AGENTS.md and GEMINI.md per-repo, plus the parent CLAUDE.md.
# Legacy WOM blocks are stripped from all three surfaces; the WOM injection code is retired.
readonly SYNC_AGENTS_ONLY=true

if [[ "${DRY_RUN}" != "0" && "${DRY_RUN}" != "1" ]]; then
  echo "DRY_RUN must be 0 or 1 (received: ${DRY_RUN})" >&2
  exit 1
fi

if [[ ! -f "${UNIVERSAL_SOURCE}" ]]; then
  echo "Universal guidelines file not found: ${UNIVERSAL_SOURCE}" >&2
  exit 1
fi

# --- Universal rules block ---

render_managed_block() {
  local synced_at="$1"

  printf '%s\n' "${START_MARKER}"
  printf '%s\n' "${NOTICE_MARKER}"
  printf '<!-- Last synced: %s -->\n' "${synced_at}"
  python3 - "${UNIVERSAL_SOURCE}" <<'PY'
from pathlib import Path
import sys

sys.stdout.write(Path(sys.argv[1]).read_text().rstrip())
PY
  printf '\n%s\n' "${END_MARKER}"
}

managed_block_is_current() {
  local target_file="$1"

  python3 - "${target_file}" "${UNIVERSAL_SOURCE}" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
guidelines = Path(sys.argv[2]).read_text().rstrip()

start = "<!-- MYBCAT-GUIDELINES-START -->"
notice = "<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines -->"
end = "<!-- MYBCAT-GUIDELINES-END -->"

text = target.read_text()
pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.DOTALL)
match = pattern.search(text)
if match is None:
    raise SystemExit(1)

current_pattern = re.compile(
    re.escape(start)
    + r"\n"
    + re.escape(notice)
    + r"\n<!-- Last synced: [^\n]* -->\n"
    + re.escape(guidelines)
    + r"\n"
    + re.escape(end)
)
raise SystemExit(0 if current_pattern.fullmatch(match.group(0)) else 1)
PY
}

replace_managed_block() {
  local target_file="$1"
  local synced_at="$2"

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "WOULD-WRITE ${target_file} (replace universal block)"
    return
  fi

  python3 - "${target_file}" "${UNIVERSAL_SOURCE}" "${synced_at}" <<'PY'
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
updated, matches = pattern.subn(lambda _match: block, text, count=1)
if matches != 1:
    raise SystemExit(f"Expected one managed block in {target}")
target.write_text(updated)
PY
}

prepend_managed_block() {
  local target_file="$1"
  local synced_at="$2"
  local tmp_file

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "WOULD-WRITE ${target_file} (prepend universal block)"
    return
  fi

  tmp_file="$(mktemp)"
  render_managed_block "${synced_at}" > "${tmp_file}"
  printf '\n' >> "${tmp_file}"
  cat "${target_file}" >> "${tmp_file}"
  mv "${tmp_file}" "${target_file}"
}

create_managed_file() {
  local target_file="$1"
  local synced_at="$2"

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "WOULD-WRITE ${target_file} (create managed file)"
    return
  fi

  render_managed_block "${synced_at}" > "${target_file}"
}

process_target_file() {
  local target_file="$1"
  local synced_at="$2"

  if [[ -L "${target_file}" ]]; then
    if [[ "${DRY_RUN}" == "1" ]]; then
      echo "WOULD-WRITE ${target_file} (replace symlink with managed file)"
    else
      rm "${target_file}"
      create_managed_file "${target_file}" "${synced_at}"
    fi
    replaced_count=$((replaced_count + 1))
    universal_synced_count=$((universal_synced_count + 1))
    return
  fi

  if [[ -f "${target_file}" ]]; then
    if grep -qF "${START_MARKER}" "${target_file}" && grep -qF "${END_MARKER}" "${target_file}"; then
      if managed_block_is_current "${target_file}"; then
        return
      fi
      replace_managed_block "${target_file}" "${synced_at}"
    else
      prepend_managed_block "${target_file}" "${synced_at}"
    fi
    updated_count=$((updated_count + 1))
    universal_synced_count=$((universal_synced_count + 1))
    return
  fi

  if [[ ! -e "${target_file}" ]]; then
    if [[ "${UPDATE_ONLY}" == "1" ]]; then
      skipped_absent_count=$((skipped_absent_count + 1))
      return
    fi
    create_managed_file "${target_file}" "${synced_at}"
    created_count=$((created_count + 1))
    universal_synced_count=$((universal_synced_count + 1))
    return
  fi

  echo "Skipping non-file path: ${target_file}" >&2
}

# --- Legacy WOM block ---
#
# Injection is retained below only for source-history continuity. It is uncalled.
# Active sync behavior removes old always-loaded WOM blocks; the load-later source
# remains at context_nate/outputs/operating-model-reference.md.

wom_artifacts_exist() {
  [[ -f "${WOM_DIR}/USER.md" && -f "${WOM_DIR}/SOUL.md" && -f "${WOM_DIR}/HEARTBEAT.md" ]]
}

wom_source_timestamp() {
  if wom_artifacts_exist; then
    stat -c '%y' "${WOM_DIR}/USER.md" 2>/dev/null | cut -d. -f1
  fi
}

process_wom_target() {
  # Retired: this function intentionally has no callers.
  local target_file="$1"
  local synced_at="$2"

  if ! wom_artifacts_exist; then
    return
  fi

  if [[ ! -e "${target_file}" ]]; then
    if [[ "${DRY_RUN}" == "1" ]]; then
      echo "WOULD-WRITE ${target_file} (create WOM target)"
      return
    fi
    : > "${target_file}"
  fi

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "WOULD-WRITE ${target_file} (sync WOM block)"
    return
  fi

  python3 - "${target_file}" "${WOM_DIR}" "${synced_at}" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
wom_dir = Path(sys.argv[2])
synced_at = sys.argv[3]

start = "<!-- MYBCAT-WOM-START -->"
notice = "<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines (WOM section) -->"
end = "<!-- MYBCAT-WOM-END -->"

user = (wom_dir / "USER.md").read_text().rstrip()
soul = (wom_dir / "SOUL.md").read_text().rstrip()
heartbeat = (wom_dir / "HEARTBEAT.md").read_text().rstrip()

import datetime
mtime = datetime.datetime.fromtimestamp((wom_dir / "USER.md").stat().st_mtime)
wom_as_of = mtime.strftime("%Y-%m-%d %H:%M:%S")

intro = (
    "## Operating Model (Ankit's WOM)\n\n"
    "These three layers describe how Ankit's work actually runs. Use them to:\n"
    "- Tailor recommendations to his rhythms and constraints (HEARTBEAT)\n"
    "- Reflect his identity and values when scoping work (SOUL)\n"
    "- Match his preferred working style and patterns (USER)\n\n"
    "Source: `OB_mybcat/exports/operating-model/` — regenerate via the "
    "`work-operating-model` skill or `mcp__ob-mybcat-wom__generate_operating_model_exports`.\n"
)

block = (
    f"{start}\n"
    f"{notice}\n"
    f"<!-- WOM source as of: {wom_as_of} | sync ran: {synced_at} -->\n\n"
    f"{intro}\n"
    "### USER.md\n\n"
    f"{user}\n\n"
    "### SOUL.md\n\n"
    f"{soul}\n\n"
    "### HEARTBEAT.md\n\n"
    f"{heartbeat}\n\n"
    f"{end}\n"
)

text = target.read_text() if target.exists() else ""
pattern = re.compile(re.escape(start) + r".*?" + re.escape(end) + r"\n?", re.DOTALL)

if pattern.search(text):
    updated, _ = pattern.subn(lambda _match: block, text, count=1)
else:
    sep = "" if text.endswith("\n") or text == "" else "\n"
    updated = text + sep + "\n" + block

target.write_text(updated)
PY

  wom_synced_count=$((wom_synced_count + 1))
}

strip_wom_block() {
  local target_file="$1"

  if [[ ! -f "${target_file}" ]]; then
    return
  fi

  if ! grep -qF "${WOM_START_MARKER}" "${target_file}" || ! grep -qF "${WOM_END_MARKER}" "${target_file}"; then
    return
  fi

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "WOULD-WRITE ${target_file} (strip WOM block)"
    wom_stripped_count=$((wom_stripped_count + 1))
    return
  fi

  python3 - "${target_file}" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
text = target.read_text()

start = "<!-- MYBCAT-WOM-START -->"
end = "<!-- MYBCAT-WOM-END -->"

# Capture a preceding blank line, when present, and replace it with one newline.
# This removes the spacing inserted by the old append behavior without joining
# unrelated content on either side of the managed block.
pattern = re.compile(
    r"(?P<leading_blank>\n[ \t]*\n)?"
    + re.escape(start)
    + r".*?"
    + re.escape(end)
    + r"\n?",
    re.DOTALL,
)
updated, matches = pattern.subn(
    lambda match: "\n" if match.group("leading_blank") else "",
    text,
    count=1,
)
if matches != 1:
    raise SystemExit(f"Expected one WOM block in {target}")
target.write_text(updated)
PY

  wom_stripped_count=$((wom_stripped_count + 1))
}

# --- Main sync loop ---

while IFS= read -r -d '' repo_dir; do
  repo_name="$(basename "${repo_dir}")"

  # Always skip .claude; its parent CLAUDE.md is managed in the post-loop step.
  [[ "${repo_name}" == ".claude" ]] && { skipped_count=$((skipped_count + 1)); continue; }

  synced_at="$(date '+%Y-%m-%d %H:%M:%S')"

  if [[ "${SYNC_AGENTS_ONLY}" == "true" ]]; then
    process_target_file "${repo_dir}/AGENTS.md" "${synced_at}"
    process_target_file "${repo_dir}/GEMINI.md" "${synced_at}"
  else
    for filename in CLAUDE.md AGENTS.md GEMINI.md; do
      process_target_file "${repo_dir}/${filename}" "${synced_at}"
    done
  fi

  strip_wom_block "${repo_dir}/AGENTS.md"
  strip_wom_block "${repo_dir}/GEMINI.md"
done < <(find "${REPOS_ROOT}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

# Claude Code inherits this lean universal block via directory walk-up. Preserve
# all content outside the managed markers, then remove the old WOM narrative.
parent_synced_at="$(date '+%Y-%m-%d %H:%M:%S')"
process_target_file "${CLAUDE_PARENT_FILE}" "${parent_synced_at}"
strip_wom_block "${CLAUDE_PARENT_FILE}"

if [[ "${DRY_RUN}" == "1" ]]; then
  echo "MyBCAT guidelines sync dry run complete"
  echo "WOULD create: ${created_count}"
  echo "WOULD update: ${updated_count}"
  echo "WOULD replace symlinks: ${replaced_count}"
  echo "WOULD universal-sync: ${universal_synced_count} target(s)"
  echo "WOULD WOM-strip: ${wom_stripped_count} target(s)"
else
  echo "MyBCAT guidelines sync complete"
  echo "Created: ${created_count}"
  echo "Updated: ${updated_count}"
  echo "Replaced symlinks: ${replaced_count}"
  echo "Universal synced: ${universal_synced_count} target(s)"
  echo "WOM stripped: ${wom_stripped_count} target(s)"
fi
echo "Skipped (inherit from parent): ${skipped_count}"
