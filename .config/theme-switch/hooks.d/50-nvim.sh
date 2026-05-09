#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
	mocha|macchiato|frappe|latte)
		scheme="catppuccin-$variant"
		;;
	tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day)
		scheme="$variant"
		;;
	kanagawa-dragon|kanagawa-wave|kanagawa-lotus)
		# kanagawa.nvim provides single 'kanagawa' colorscheme; theme via setup
		scheme="kanagawa-${variant#kanagawa-}"
		;;
	*) echo "50-nvim: invalid variant '$variant'" >&2; exit 1 ;;
esac

if ! command -v nvim >/dev/null 2>&1; then
	exit 0
fi

sock_root="${TMPDIR:-/tmp}/nvim.${USER}"
[[ -d $sock_root ]] || exit 0

shopt -s nullglob
for sock in "$sock_root"/*/nvim.*.0; do
	[[ -S $sock ]] || continue
	# Derive PID from socket filename (nvim.<pid>.0). Skip kalau process dead
	# — nvim kadang gak cleanup socket file pas exit (macOS).
	pid=$(basename "$sock" | sed -E 's/^nvim\.([0-9]+)\..*/\1/')
	if [[ -n $pid ]] && ! kill -0 "$pid" 2>/dev/null; then
		# Orphan: cleanup socket dir, skip
		rm -rf "$(dirname "$sock")"
		continue
	fi
	nvim --server "$sock" --remote-expr "execute('colorscheme ${scheme}')" \
		>/dev/null 2>&1 || echo "50-nvim: failed to reload $sock" >&2
done
shopt -u nullglob
