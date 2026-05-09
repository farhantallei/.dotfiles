#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
	mocha|macchiato|frappe|latte) ;;
	tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day) ;;
	kanagawa-dragon|kanagawa-wave|kanagawa-lotus) ;;
	*) echo "60-wezterm: invalid variant '$variant'" >&2; exit 1 ;;
esac

config="$HOME/.config/wezterm/wezterm.lua"
[[ -f $config ]] || exit 0

touch "$config"
