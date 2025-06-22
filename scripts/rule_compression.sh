#!/bin/sh

set -e

[ $# -eq 2 ] || {
    echo "Usage: $0 <filter> <target>" >&2
    exit 1
}

[ -f "$1" ] && [ -f "$2" ] || {
    echo "Error: Input files missing" >&2
    exit 1
}

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

grep -ivF -f "$1" "$2" > "$WORKDIR/output" || true
mv "$WORKDIR/output" "$2"

echo "OK"