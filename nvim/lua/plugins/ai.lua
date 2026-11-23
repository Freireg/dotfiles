-- AI agents inside Neovim
--   Claude Code: full IDE integration via coder/claudecode.nvim (same protocol as the VSCode extension):
--     Claude sees your open file + selection, and proposes edits as side-by-side diffs you accept/reject.
--   Codex CLI: runs in a side terminal; <leader>as sends the current file/selection as context.
local function codex_term()
  return Snacks.terminal.get("codex", {
    cwd = vim.fn.getcwd(),
    win = { position = "right", width = 0.4, wo = { winbar = " Codex" } },
  })
end

local function send_to_codex(text)
  local term = codex_term()
  if not term then return end
  term:show()
  local chan = vim.bo[term.buf].channel
  vim.defer_fn(function() vim.api.nvim_chan_send(chan, text) end, 100)
  term:focus()
  vim.cmd("startinsert")
end

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
    opts = {
      terminal = { split_side = "right", split_width_percentage = 0.40, provider = "snacks" },
      diff_opts = { open_in_new_tab = false, keep_terminal_focus = false },
    },
    keys = {
      { "<C-S-a>", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: toggle/focus", mode = { "n", "t" } },
      { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle chat" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus chat" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add this file to context" },
      { "<leader>aa", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>ab", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Claude: add file from explorer", ft = { "neo-tree" } },
      { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: ACCEPT proposed diff" },
      { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: REJECT proposed diff" },
    },
  },

  -- Codex CLI in a side terminal
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ac", function() local t = codex_term(); if t then t:toggle() end end, desc = "Codex: toggle chat" },
      {
        "<leader>as",
        function() send_to_codex("@" .. vim.fn.expand("%:.") .. " ") end,
        desc = "Codex: mention this file",
      },
      {
        "<leader>as",
        function()
          local s, e = vim.fn.line("v"), vim.fn.line(".")
          if s > e then s, e = e, s end
          vim.cmd("normal! \27")
          send_to_codex(string.format("@%s (lines %d-%d) ", vim.fn.expand("%:."), s, e))
        end,
        mode = "v",
        desc = "Codex: mention selection",
      },
    },
  },
}
