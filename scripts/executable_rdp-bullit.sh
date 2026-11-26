#!/usr/bin/env bash
set -euo pipefail

entry="$(pass show rdp/bullit)"
password="$(printf '%s\n' "$entry" | sed -n '1p')"
username="$(printf '%s\n' "$entry" | sed -n 's/^user:[[:space:]]*//p')"

if [[ -z "$password" || -z "$username" ]]; then
  echo "Missing password or user in pass entry rdp/molasses" >&2
  exit 1
fi

printf '%s\n' "$password" |
  exec xfreerdp3 /v:10.229.10.10 /u:"$username" /d:MicrosoftAccount /from-stdin +dynamic-resolution "$@"
