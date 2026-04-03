#!/usr/bin/env python3
"""Parse interception metrics from a JSONL file and summarize action_taken counts."""

import json
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path-to-jsonl-file>")
        sys.exit(1)

    jsonl_path = Path(sys.argv[1])
    if not jsonl_path.exists():
        print(f"Error: file not found: {jsonl_path}")
        sys.exit(1)

    true_count = 0
    false_count = 0
    parse_errors = 0

    with open(jsonl_path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
                if entry.get("action_taken") is True:
                    true_count += 1
                elif entry.get("action_taken") is False:
                    false_count += 1
            except json.JSONDecodeError:
                parse_errors += 1
                print(f"Warning: invalid JSON on line {line_num}", file=sys.stderr)

    total = true_count + false_count
    print(f"Total entries with action_taken: {total}")
    print(f"  action_taken=true:  {true_count}")
    print(f"  action_taken=false: {false_count}")
    if parse_errors:
        print(f"  parse errors:       {parse_errors}")


if __name__ == "__main__":
    main()
