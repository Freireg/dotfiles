-- VSCode-style shortcuts. Plugin-specific keys live in lua/plugins/*.lua.
local map = function(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { silent = true, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Save / quit
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", "Save file")
map("n", "<leader>w", "<cmd>w<cr>", "Save file")
map("n", "<leader>q", "<cmd>confirm qa<cr>", "Quit Neovim")

-- Undo / redo / select all (insert + normal)
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", "Undo")
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>", "Redo")
map("n", "<C-a>", "ggVG", "Select all")

-- Copy / cut / paste in visual mode like an IDE (system clipboard)
map("v", "<C-c>", '"+y', "Copy")
map("v", "<C-x>", '"+d', "Cut")
map("i", "<C-v>", "<C-r>+", "Paste")

-- Comment toggle: Ctrl+/ (terminals send <C-_> for it)
map("n", "<C-/>", "gcc", "Toggle comment", { remap = true })
map("n", "<C-_>", "gcc", "Toggle comment", { remap = true })
map("v", "<C-/>", "gc", "Toggle comment", { remap = true })
map("v", "<C-_>", "gc", "Toggle comment", { remap = true })

-- Move lines with Alt+Up/Down (and Alt+j/k)
map("n", "<A-Down>", "<cmd>m .+1<cr>==", "Move line down")
map("n", "<A-Up>", "<cmd>m .-2<cr>==", "Move line up")
map("n", "<A-j>", "<cmd>m .+1<cr>==", "Move line down")
map("n", "<A-k>", "<cmd>m .-2<cr>==", "Move line up")
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", "Move selection down")
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", "Move selection up")
map("v", "<A-j>", ":m '>+1<cr>gv=gv", "Move selection down")
map("v", "<A-k>", ":m '<-2<cr>gv=gv", "Move selection up")

-- Indent with Tab in visual mode, keep selection
map("v", "<Tab>", ">gv", "Indent")
map("v", "<S-Tab>", "<gv", "Unindent")
map("v", ">", ">gv", "Indent")
map("v", "<", "<gv", "Unindent")

-- Tabs (buffers) like editor tabs
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", "Next tab")
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", "Previous tab")
map("n", "<A-Right>", "<cmd>BufferLineCycleNext<cr>", "Next tab")
map("n", "<A-Left>", "<cmd>BufferLineCyclePrev<cr>", "Previous tab")
map("n", "<leader>x", function() Snacks.bufdelete() end, "Close tab")
map("n", "<leader>X", function() Snacks.bufdelete.other() end, "Close other tabs")

-- Window navigation with Ctrl+h/j/k/l
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")
map("n", "<leader>\\", "<cmd>vsplit<cr>", "Split right")
map("n", "<leader>-", "<cmd>split<cr>", "Split below")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear highlight")

-- Leave terminal mode easily
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("t", "<C-h>", "<C-\\><C-n><C-w>h", "Window left")
map("t", "<C-l>", "<C-\\><C-n><C-w>l", "Window right")
map("t", "<C-k>", "<C-\\><C-n><C-w>k", "Window up")

-- Diagnostics (errors/warnings)
map("n", "<F8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next problem")
map("n", "<S-F8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous problem")
map("n", "<leader>le", vim.diagnostic.open_float, "Show line error")

-- Cheatsheet
map("n", "<leader>?", function()
  Snacks.win({
    file = vim.fn.stdpath("config") .. "/CHEATSHEET.md",
    width = 0.7, height = 0.85, border = "rounded", title = " Cheatsheet (q to close) ",
    wo = { wrap = true, conceallevel = 2, spell = false },
    bo = { modifiable = false, filetype = "markdown" },
  })
end, "Cheatsheet")
