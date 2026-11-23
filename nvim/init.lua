-- ~/.config/nvim/init.lua
-- VSCode-like Neovim setup. Press <Space> and wait for hints, or <Space>? for the cheatsheet.

local v = vim.version()
if vim.fn.has("nvim-0.11") == 0 then
  vim.api.nvim_echo({ {
    ("This config needs Neovim >= 0.11 (running %d.%d.%d from %s).\n"):format(v.major, v.minor, v.patch, vim.v.progpath)
      .. "Use ~/.local/bin/nvim — run `hash -r` or open a new terminal. Loading plain Neovim instead.",
    "ErrorMsg" } }, true, {})
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "plugins" } }, {
  install = { colorscheme = { "vscode" } },
  checker = { enabled = false },
  rocks = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})

require("config.keymaps")
require("config.autocmds")
