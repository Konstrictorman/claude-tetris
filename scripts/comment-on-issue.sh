#!/usr/bin/env bash
#
# Posts a comment to the GitHub issue that triggered the workflow.
# Usage:
#   ./scripts/comment-on-issue.sh <<'EOF'
#   comment body here
#   EOF
#
# The issue number is read from the workflow event payload; the comment body
# is read from stdin so arbitrary text never has to be shell-escaped as an
# argument. Only ever posts to the triggering issue, never a caller-supplied
# issue number.

set -euo pipefail

ISSUE=$(jq -r '.issue.number // empty' "${GITHUB_EVENT_PATH:?GITHUB_EVENT_PATH not set}")
if ! [[ "$ISSUE" =~ ^[0-9]+$ ]]; then
  echo "Error: no issue number in event payload" >&2
  exit 1
fi

BODY="$(cat)"
if [[ -z "$BODY" ]]; then
  echo "Error: comment body (stdin) is empty" >&2
  exit 1
fi

gh issue comment "$ISSUE" --body "$BODY"
