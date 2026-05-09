#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
	mocha|macchiato|frappe|latte) ;;
	tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day) ;;
	kanagawa-dragon|kanagawa-wave|kanagawa-lotus) ;;
	*) echo "70-tmux: invalid variant '$variant'" >&2; exit 1 ;;
esac

if ! command -v tmux >/dev/null 2>&1; then
	exit 0
fi

# Skip kalau gak ada server tmux jalan
tmux info >/dev/null 2>&1 || exit 0

tmux source-file ~/.tmux.conf >/dev/null 2>&1 || \
	echo "70-tmux: source-file failed" >&2
