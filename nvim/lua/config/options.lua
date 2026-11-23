local o = vim.opt

o.number = true
o.relativenumber = false     -- VSCode-style absolute numbers
o.mouse = "a"                -- full mouse support (click, scroll, drag splits)
o.clipboard = "unnamedplus"  -- yank/paste uses the system clipboard
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.undofile = true            -- persistent undo
o.updatetime = 250
o.timeoutlen = 400           -- which-key popup delay
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.showmode = false           -- statusline shows mode
o.laststatus = 3             -- single global statusline
o.confirm = true             -- ask to save instead of erroring
o.list = true
o.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " " }
o.autoread = true            -- pick up edits made by AI agents on disk
