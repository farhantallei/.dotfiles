#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
    mocha|macchiato|frappe|latte) ;;
    tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day) ;;
    kanagawa-dragon|kanagawa-wave|kanagawa-lotus) ;;
    *) echo "30-fish: invalid variant '$variant'" >&2; exit 1 ;;
esac

if ! command -v fish >/dev/null 2>&1; then
    exit 0
fi

fish -c "set -U __theme_variant $variant"
