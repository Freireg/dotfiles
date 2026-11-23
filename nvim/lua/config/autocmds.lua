local au = vim.api.nvim_create_autocmd

-- Flash yanked text
au("TextYankPost", { callback = function() vim.hl.on_yank({ timeout = 150 }) end })

-- Reload files changed outside nvim (e.g. by Claude/Codex)
au({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then vim.cmd("checktime") end
  end,
})

-- Return to last cursor position when reopening a file
au("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Embedded/Yocto: real tabs for Makefiles and BitBake-ish files
au("FileType", {
  pattern = { "make", "go" },
  callback = function() vim.opt_local.expandtab = false end,
})
vim.filetype.add({
  extension = { bb = "bitbake", bbappend = "bitbake", bbclass = "bitbake" },
  pattern = { [".*/meta[^/]*/.*%.inc"] = "bitbake", [".*/meta[^/]*/conf/.*%.conf"] = "bitbake", [".*/build[^/]*/conf/.*%.conf"] = "bitbake" },
})

-- Close helper windows with q
au("FileType", {
  pattern = { "help", "qf", "lspinfo", "checkhealth", "man" },
  callback = function(ev) vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true }) end,
})
