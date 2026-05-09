-- Colorscheme dispatch, variant driven by ~/.config/theme-current
-- Single source of truth for the dotfiles ecosystem theme.
-- Valid variants:
--   Catppuccin: latte, frappe, macchiato, mocha (fallback: mocha)
--   Tokyonight: tokyonight-night, tokyonight-storm, tokyonight-moon, tokyonight-day
--   Kanagawa:   kanagawa-dragon, kanagawa-wave, kanagawa-lotus
--
-- LazyVim spec uses flavor-specific colorscheme name supaya cold-start gak
-- nyangkut di mocha (lihat ~/.config/theme-switch/README.md "Bug 2").

local function read_theme()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.config/theme-current"))
  if not ok or not lines or not lines[1] then
    return "mocha"
  end
  local variant = vim.trim(lines[1])
  local valid = {
    latte = true, frappe = true, macchiato = true, mocha = true,
    ["tokyonight-night"] = true, ["tokyonight-storm"] = true,
    ["tokyonight-moon"] = true, ["tokyonight-day"] = true,
    ["kanagawa-dragon"] = true, ["kanagawa-wave"] = true, ["kanagawa-lotus"] = true,
  }
  return valid[variant] and variant or "mocha"
end

local function colorscheme_for(v)
  if v:match("^tokyonight%-") or v:match("^kanagawa%-") then
    return v
  end
  return "catppuccin-" .. v
end

local variant = read_theme()
local is_catppuccin = not (variant:match("^tokyonight%-") or variant:match("^kanagawa%-"))

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = is_catppuccin and { flavour = variant } or {},
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {},
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {},
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorscheme_for(variant),
    },
  },
}
