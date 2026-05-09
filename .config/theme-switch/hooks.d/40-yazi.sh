#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
	mocha|macchiato|frappe|latte)
		flavor="catppuccin-$variant"
		;;
	tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day)
		flavor="$variant"
		;;
	kanagawa-dragon|kanagawa-wave|kanagawa-lotus)
		flavor="$variant"
		;;
	*) echo "40-yazi: invalid variant '$variant'" >&2; exit 1 ;;
esac

theme_file="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/theme.toml"

if [[ ! -d $(dirname "$theme_file") ]]; then
	exit 0
fi

tmp=$(mktemp "${theme_file}.XXXXXX")
cat > "$tmp" <<EOF
[flavor]
dark  = "$flavor"
light = "$flavor"
EOF
mv -f "$tmp" "$theme_file"
