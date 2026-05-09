# theme-switch

Cross-tool theme switcher. State file `~/.config/theme-current` adalah single source of truth — semua tool baca dari sana, baik saat cold-start (tool baru jalan) maupun live-switch (tool yang udah jalan).

## Quick reference

```bash
theme-switch              # print variant aktif
theme-switch <variant>    # switch ke variant
theme-switch -l           # list valid variants
theme-switch -h           # help
```

Variant valid sekarang (11 total, 3 family):

- **Catppuccin**: `mocha`, `macchiato`, `frappe`, `latte`
- **Tokyonight**: `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon`, `tokyonight-day`
- **Kanagawa**: `kanagawa-dragon` (near-black `#181616`), `kanagawa-wave` (default), `kanagawa-lotus` (light)

## File layout

```
~/.local/bin/theme-switch          # executable (bash)
~/.config/theme-current             # state file: "<variant>\n"
~/.config/theme-switch/
├── README.md                       # this file
└── hooks.d/                        # post-switch event handlers (alphanumeric order)
    ├── 30-fish.sh
    ├── 40-yazi.sh
    ├── 50-nvim.sh
    ├── 60-wezterm.sh
    └── 70-tmux.sh
~/.config/tmux/palettes/            # tmux palette files (manual @thm_* injection)
├── mocha.conf                      # 4 Catppuccin
├── macchiato.conf
├── frappe.conf
├── latte.conf
├── tokyonight-night.conf           # 4 Tokyonight
├── tokyonight-storm.conf
├── tokyonight-moon.conf
├── tokyonight-day.conf
├── kanagawa-dragon.conf            # 3 Kanagawa
├── kanagawa-wave.conf
└── kanagawa-lotus.conf
~/.config/yazi/flavors/             # yazi flavor folders
├── catppuccin-{mocha,macchiato,frappe,latte}.yazi/   # via ya pkg
├── tokyonight-{night,storm,moon,day}.yazi/           # custom (sed-substituted from catppuccin-mocha)
└── kanagawa-{dragon,wave,lotus}.yazi/                 # custom (sed-substituted from catppuccin-mocha)
```

## Architecture

### Single source of truth

`~/.config/theme-current` ditulis atomically (mktemp + rename) oleh `theme-switch <variant>`. Semua reader (cold-start path tiap tool) baca file ini saat startup.

### Event flow saat switch

```
theme-switch latte
  ├─ validate variant
  ├─ atomic write ~/.config/theme-current
  └─ run hooks.d/*.sh in alphanumeric order
       ├─ 30-fish.sh    → set fish universal var
       ├─ 40-yazi.sh    → rewrite yazi theme.toml
       ├─ 50-nvim.sh    → broadcast :colorscheme ke nvim instance jalan
       ├─ 60-wezterm.sh → touch wezterm.lua → trigger auto-reload
       └─ 70-tmux.sh    → tmux source-file (skip kalau gak ada server)
```

Hook gagal tidak fatal — script print error ke stderr, lanjut ke hook berikutnya.

### Cold-start vs live-switch

Tiap tool punya **dua jalur**:

1. **Cold-start**: tool baru jalan, baca `theme-current` dari config-nya sendiri.
2. **Live-switch**: tool udah jalan saat `theme-switch <variant>` dipanggil. Hook trigger reload via mekanisme native tool.

Hook tanggung jawab live-switch saja. Cold-start tergantung config tool.

## Per-tool theming layer

### Fish — `30-fish.sh`

- **Cold-start**: `~/.config/fish/conf.d/theme.fish` baca `theme-current` saat shell init, set `$__theme_variant`.
- **Live-switch**: hook `fish -c "set -U __theme_variant <variant>"`. Universal var auto-propagate ke semua fish instance.

### Yazi — `40-yazi.sh`

- **Cold-start**: yazi load `~/.config/yazi/theme.toml` (yang berisi `[flavor] dark/light = "<flavor-folder-name>"`) saat startup.
- **Live-switch**: hook rewrite `theme.toml` dengan flavor folder name. Yazi tidak auto-reload — instance yang udah jalan baru kena saat keystroke selanjutnya.

Flavor folder source:
- **Catppuccin**: di-install via `ya pkg add yazi-rs/flavors:catppuccin-<v>` (registry resmi).
- **Tokyonight & Kanagawa**: gak ada di registry — custom build, sed-substituted dari `catppuccin-mocha.yazi/flavor.toml` ke palette family (script historis: `/tmp/yazi-{tn,kana}-build.sh`). `tmtheme.xml` symlink ke catppuccin-mocha sebagai fallback (sufficient untuk syntax preview).

### Nvim — `50-nvim.sh`

- **Cold-start**: `~/.config/nvim/lua/plugins/colorscheme.lua` baca `theme-current` saat lazy plugin spec evaluate. Family dispatch via prefix:
  - Variant ∈ Catppuccin → `LazyVim.opts.colorscheme = "catppuccin-" .. variant`, `catppuccin.opts.flavour = variant`.
  - Variant `tokyonight-*` → `LazyVim.opts.colorscheme = variant` (e.g., `tokyonight-storm`), tokyonight.nvim plugin load.
- **Live-switch**: hook scan `$TMPDIR/nvim.$USER/*/nvim.*.0` socket, kirim `:colorscheme <derived>` ke tiap instance via `nvim --server <sock> --remote-expr`. Scheme name derive sama logic seperti cold-start.

**Penting**: pakai colorscheme name flavor-specific (`catppuccin-latte`), **bukan** `catppuccin`. Lihat [bug history](#bug-2-nvim-cold-start-mocha-lock).

### Wezterm — `60-wezterm.sh`

- **Cold-start**: `~/.config/wezterm/lua/theme.lua` baca `theme-current` saat config evaluate, lookup `SCHEMES` table (Catppuccin → `"Catppuccin <Name>"`, Tokyonight → `"tokyonight_<variant>"`, Kanagawa → `"Kanagawa <Variant>"` dari `CUSTOM_SCHEMES` inline).
- **Live-switch**: hook `touch ~/.config/wezterm/wezterm.lua`. Wezterm `automatically_reload_config = true` detect mtime change → reload config → re-run `theme.lua` → apply new scheme. Tab bar dan ANSI palette ikut update.

### Tmux — `70-tmux.sh`

- **Cold-start**: `~/.tmux.conf`:
  - `run-shell` baca `theme-current`. Variant ∈ Catppuccin → `@catppuccin_flavor=<variant>`. Variant `tokyonight-*` → `@catppuccin_flavor=mocha` (placeholder, palette di-override manual setelah plugin load).
  - `set -g @catppuccin_reset "true"` — force unset palette `@thm_*` tiap re-source ([lihat bug 1](#bug-1-tmux-palette-stale)).
  - Plugin load via `run tpm` → set palette via `@catppuccin_flavor`.
  - **Manual palette override**: `run-shell 'tmux source-file ~/.config/tmux/palettes/$(cat ~/.config/theme-current).conf'` — load palette file untuk variant, override semua `@thm_*`. Ini single source of truth — Catppuccin maupun Tokyonight pakai mekanisme sama.
  - Style lines (`status-style`, `window-status-format`) **after** plugin + override — palette `@thm_*` final saat di-render.
  - Pakai `set -g` + `#{E:@thm_bg}` (lazy expand), bukan `-gF` (eager).
- **Live-switch**: hook `tmux source-file ~/.tmux.conf` — skip kalau gak ada tmux server.

#### Tmux palette files (`~/.config/tmux/palettes/<variant>.conf`)

26 token per palette: `bg`, `fg`, semua warna (rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender), graded surface ladder (mantle/crust + surface_0/1/2 + overlay_0/1/2 + subtext_0/1).

Untuk variant non-Catppuccin, mapping semantic Catppuccin slot:

**Tokyonight:**

| Catppuccin | Tokyonight |
|------------|------------|
| `bg`/`fg`  | `bg`/`fg`  |
| `pink`     | `magenta`  |
| `mauve`    | `purple`   |
| `peach`    | `orange`   |
| `sky`      | `blue1` (cyan light) |
| `sapphire` | `blue2`    |
| `lavender` | `blue5`    |
| `crust`/`mantle` | `bg_dark1`/`bg_dark` |
| `surface_*` | `bg_highlight` → `fg_gutter` → `terminal_black` |
| `overlay_*` | `dark3` → `comment` → `dark5` |

**Kanagawa** (palette via `kanagawa.nvim` `theme.ui` + `theme.syn`):

| Catppuccin | Kanagawa |
|------------|----------|
| `bg`/`fg`  | `ui.bg`/`ui.fg` |
| `pink`     | `syn.number` (sakuraPink/dragonPink/lotusPink) |
| `mauve`    | `syn.keyword` (oniViolet/dragonViolet/lotusViolet) |
| `peach`    | `syn.constant` (surimiOrange/dragonOrange/lotusOrange) |
| `green`    | `syn.string` (springGreen/dragonGreen/lotusGreen) |
| `teal`     | `syn.type` (waveAqua/dragonAqua/lotusTeal) |
| `blue`     | `syn.fun` (crystalBlue/dragonBlue/lotusBlue) |
| `crust`/`mantle` | `ui.bg_m3`/`ui.bg_m2` |
| `surface_*` | `ui.bg_m1` → `ui.bg_p1` → `ui.bg_p2` |
| `overlay_*` | `ui.nontext` / `syn.comment` / `ui.special` |

Mapping inexact — beberapa slot collision atau perlu pendekatan terdekat. Akseptabel karena tmux statusline jarang pakai semua slot.

### Starship — no hook

ANSI named color (`style = "cyan"` dst) auto-follow palette terminal yang udah di-swap oleh wezterm `color_scheme`. Selama prompt config gak pake hex literal atau Catppuccin palette name (`"mauve"`, `"sapphire"`), gak butuh hook.

Kalau prompt di-extend ke catppuccin powerline preset atau pakai hex, baru perlu bikin `80-starship.sh`.

## Family dispatch

Sistem support 3 colorscheme family (Catppuccin + Tokyonight + Kanagawa). Variant prefix menentukan family:

- `<variant>` (no prefix) → Catppuccin family. Valid: `mocha`, `macchiato`, `frappe`, `latte`.
- `tokyonight-<variant>` → Tokyonight family. Valid: `tokyonight-{night,storm,moon,day}`.
- `kanagawa-<variant>` → Kanagawa family. Valid: `kanagawa-{dragon,wave,lotus}`. Wezterm gak punya built-in scheme per-variant — define custom inline di `theme.lua` (`config.color_schemes`).

Per-tool dispatch:
- **Nvim**: `colorscheme.lua` cek prefix `^tokyonight%-` / `^kanagawa%-`, route ke plugin yang sesuai (`folke/tokyonight.nvim`, `rebelot/kanagawa.nvim`).
- **Wezterm**: lookup table `SCHEMES` map variant key ke wezterm scheme name.
- **Tmux**: variant menentukan palette file di-source. `@catppuccin_flavor` set ke `mocha` (placeholder) untuk tokyonight — plugin tetep load mocha palette, lalu palette manual override.
- **Yazi**: hook map variant ke flavor folder (Catppuccin: `catppuccin-<v>`, Tokyonight: `<variant>` literal).
- **Fish**: hanya set universal var, gak ada per-family logic.

Validator di tiap hook + theme-switch script enumerate semua 8 variant.

## How to add a theme

Tergantung scope. Tiga jenis:

### Scope A — Catppuccin variant custom override

Misal: `mocha-warm` dengan accent peach lebih kuat. Tetap dalam keluarga Catppuccin tapi tweak palette.

Steps:

1. **theme-switch script** (`~/.local/bin/theme-switch`): tambah ke `VARIANTS` array.
2. **Tiap hook** (`30-*.sh` s/d `70-*.sh`): tambah ke `case ... in` validator.
3. **Per-tool palette override**:
   - **Yazi**: clone existing `~/.config/yazi/flavors/catppuccin-mocha.yazi/`, edit hex, register di `package.toml`.
   - **Nvim**: catppuccin plugin support `color_overrides.<variant>` — tambah override di `colorscheme.lua` opts.
   - **Wezterm**: bikin custom scheme di `~/.config/wezterm/colors/<name>.toml` (atau inline di `theme.lua`).
   - **Tmux**: catppuccin/tmux plugin **gak support** custom flavor. Workaround: edit `tmux.conf` `set -g @thm_*` manual setelah plugin load (override palette tertentu).

Effort: medium. Trade-off: maintenance cost di 4-5 tempat tiap variant baru.

### Scope B — Tambah non-Catppuccin family

Misal: `tokyonight-night`, `gruvbox-dark`. Theme dari ekosistem lain.

Steps:

1. **theme-switch & hook validators**: tambah variant.
2. **Tool-by-tool**:
   - **Yazi**: install flavor package `ya pkg add yazi-rs/flavors:tokyonight` (kalau ada) atau bikin custom flavor folder.
   - **Nvim**: `:Lazy install folke/tokyonight.nvim`, ubah `colorscheme.lua` jadi conditional — kalau variant ∈ Catppuccin pakai `catppuccin-<v>`, kalau bukan pakai colorscheme nama lain.
   - **Wezterm**: built-in scheme list udah cover banyak (`Tokyo Night`, `Gruvbox Dark`). Map di `theme.lua`.
   - **Tmux**: catppuccin/tmux plugin Catppuccin-only. Pakai plugin lain (e.g., `omerxx/catppuccin-tmux` fork yang support palette swap, atau tmux statusline custom non-plugin).
3. **Hook adjustments**: hook 50-nvim sekarang send `:colorscheme catppuccin-<v>` — hardcoded prefix. Refactor: derive scheme name dari variant via mapping (config eksternal atau if-else inline).

Effort: high. Trade-off: hook script jadi family-aware (lookup table).

### Scope C — Multi-family abstraction

Sistem yang bisa Catppuccin OR Tokyonight OR Gruvbox di satu state file. Beda banget dari sekarang.

Refactor yang dibutuhkan:

1. **State file ganti format**: `theme-current` jadi `family=catppuccin\nvariant=mocha\n` atau YAML/TOML.
2. **theme-switch script**: parsing family + variant.
3. **Hook receive 2 args** (`<family> <variant>`) atau parse state file langsung.
4. **Per-tool config**: lookup table family → tool-specific scheme name.
5. **Custom flavor manager**: bikin `~/.config/theme-switch/families.toml` — registry mapping `<family>:<variant>` ke per-tool ID.

Effort: very high. Trade-off: rewrite arsitektur. Pertimbangkan hanya kalau kebutuhan sering ganti family.

## Bug history & gotchas

### Bug 1: Tmux palette stale

**Symptom**: setelah `theme-switch latte`, statusbar bg masih dark (mocha) walau modules update ke palette latte.

**Cause**: catppuccin/tmux plugin set `@thm_*` dengan flag `-o` (`set -ogq @thm_bg "#1e1e2e"`) — "set if not already set". Re-source via `source-file` tidak overwrite palette yang udah ada.

**Fix**: `set -g @catppuccin_reset "true"` di `tmux.conf` sebelum `run tpm`. Plugin v2.2.0+ baca option ini, unset semua `@thm_*` (`set -Ugq`) sebelum re-apply.

### Bug 2: Nvim cold-start mocha lock

**Symptom**: nvim baru kebuka pakai mocha walau `theme-current = latte`.

**Cause**: LazyVim plugin priority `10000` > catppuccin priority `1000`. LazyVim's setup execute `:colorscheme catppuccin` **sebelum** catppuccin plugin's `setup({flavour="latte"})` apply. Saat itu `M.options.flavour` masih default `"auto"` → fallback ke `M.options.background[vim.o.background]` = `"mocha"` (default `vim.o.background = "dark"`).

**Fix**: di `colorscheme.lua`, set `LazyVim.opts.colorscheme = "catppuccin-" .. flavour` (flavor-specific). `:colorscheme catppuccin-latte` invoke `M.load("latte")` dengan arg eksplisit → bypass auto-fallback.

### Gotcha: Wezterm tab bar

Wezterm `color_scheme` reload **harusnya** update tab bar bg/fg. Kalau gak update, cek:

- `automatically_reload_config = true` di `appearance.lua`.
- `use_fancy_tab_bar` (macOS): kalau `true`, tab bar bisa pakai window frame color terpisah. Set di `window_frame.active_titlebar_bg` kalau perlu.

### Gotcha: Yazi flavor package format

Yazi v26+ flavor format strict: file `flavor.toml` di dalam `<flavor-name>.yazi/` directory. `~/.config/yazi/theme.toml` di root yazi config cuma reference (`[flavor] dark/light = "<flavor-name>"`) — yang sebenernya pake adalah `flavors/<name>.yazi/flavor.toml`.

### Gotcha: Tmux palette plugin reset

`@catppuccin_reset = "true"` unset palette tiap re-source supaya re-apply work. Tapi untuk tokyonight, plugin set palette ke mocha (placeholder), terus manual palette file kita override. Order penting: palette file source HARUS setelah `run tpm`, sebelum style lines yang reference `#{E:@thm_*}`.

## Testing checklist

Setelah perubahan apa pun di sistem, verify:

### Cold-start (tool baru jalan)

```bash
# Catppuccin
echo "latte" > ~/.config/theme-current
fish; yazi; nvim; wezterm; tmux new   # semua light cream

# Tokyonight
echo "tokyonight-storm" > ~/.config/theme-current
fish; yazi; nvim; wezterm; tmux new   # nvim bg #24283b, wezterm tokyonight_storm

# Kanagawa
echo "kanagawa-dragon" > ~/.config/theme-current
fish; yazi; nvim; wezterm; tmux new   # nvim bg #181616 (near-black)
```

### Live-switch (tool udah jalan)

```bash
# buka semua tool dulu, terus:
theme-switch mocha
# verify semua tool ke-update tanpa restart
theme-switch latte
# balik
```

### Per-bug regression

- Switch berkali-kali (`mocha → latte → mocha → latte`): tmux statusbar harus konsisten ikut variant (regression test bug 1).
- Buka nvim baru di tmux pane setelah `theme-switch latte`: bg harus `#eff1f5`, bukan `#1e1e2e` (regression test bug 2).

## Troubleshooting

### Tool gak ikut switch

1. Cek hook executable: `ls -la ~/.config/theme-switch/hooks.d/`.
2. Run hook manual: `bash ~/.config/theme-switch/hooks.d/<NN>-<tool>.sh <variant>`. Lihat stderr.
3. Cek tool config baca `~/.config/theme-current` benar.

### Variant invalid

`theme-switch: invalid variant: foo`. Cek `VARIANTS` di `~/.local/bin/theme-switch` dan `case` validator di tiap hook — harus konsisten.

### Tmux gak source-file

Hook 70-tmux skip kalau `tmux info` gagal. Pastikan tmux server jalan: `tmux ls`.

### Nvim instance gak ke-switch live

Cek socket discovery: `ls $TMPDIR/nvim.$USER/*/nvim.*.0`. Kalau kosong, nvim instance jalan tapi gak listening. Default nvim listen — kemungkinan instance lama atau env var override.

## Adding a new hook

Template hook (taruh di `hooks.d/<NN>-<tool>.sh`, urutan NN menentukan eksekusi):

```bash
#!/usr/bin/env bash
set -euo pipefail

variant="${1:-mocha}"

case "$variant" in
    mocha|macchiato|frappe|latte) ;;
    tokyonight-night|tokyonight-storm|tokyonight-moon|tokyonight-day) ;;
    kanagawa-dragon|kanagawa-wave|kanagawa-lotus) ;;
    *) echo "<NN>-<tool>: invalid variant '$variant'" >&2; exit 1 ;;
esac

if ! command -v <tool> >/dev/null 2>&1; then
    exit 0
fi

# live-switch logic here
```

`chmod +x` setelah bikin.
