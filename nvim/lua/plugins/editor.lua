-- File explorer, fuzzy finder, git, terminal
return {
  -- Sidebar explorer (Ctrl+B like VSCode)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-b>", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle file explorer" },
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle file explorer" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
      window = {
        width = 32,
        mappings = { ["<space>"] = "none", ["l"] = "open", ["h"] = "close_node" },
      },
    },
    init = function()
      -- `nvim .` opens the explorer
      if vim.fn.argc() == 1 then
        local stat = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then require("neo-tree") end
      end
    end,
  },

  -- Picker keymaps (Ctrl+P, Ctrl+Shift+F...) — picker comes from snacks.nvim
  {
    "folke/snacks.nvim",
    keys = {
      { "<C-p>", function() Snacks.picker.files() end, desc = "Find file (Ctrl+P)" },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find file" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find file" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Search text in project" },
      { "<C-S-f>", function() Snacks.picker.grep() end, desc = "Search text in project" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Search word under cursor", mode = { "n", "x" } },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Open tabs/buffers" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<C-S-o>", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols in project" },
      { "<leader>fc", function() Snacks.picker.commands() end, desc = "Command palette" },
      { "<C-S-p>", function() Snacks.picker.commands() end, desc = "Command palette" },
      { "<F1>", function() Snacks.picker.commands() end, desc = "Command palette" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Search keymaps" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Search help" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Problems (all files)" },
      { "<leader>f/", function() Snacks.picker.lines() end, desc = "Search in current file" },
      { "<leader>fR", function() Snacks.picker.resume() end, desc = "Resume last search" },
      { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo history" },
      -- Git
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit (if installed)" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Changed files" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git log of this file" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Open in GitHub/GitLab" },
      -- Terminal (Ctrl+` like VSCode; many terminals send Ctrl+` as <C-\> or <C-@>)
      { "<C-`>", function() Snacks.terminal.toggle() end, desc = "Toggle terminal", mode = { "n", "t" } },
      { "<C-\\>", function() Snacks.terminal.toggle() end, desc = "Toggle terminal", mode = { "n", "t" } },
      { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle terminal" },
      -- UI toggles
      { "<leader>uw", function() Snacks.toggle.option("wrap"):toggle() end, desc = "Toggle line wrap" },
      { "<leader>ur", function() Snacks.toggle.option("relativenumber"):toggle() end, desc = "Toggle relative numbers" },
      { "<leader>ud", function() Snacks.toggle.diagnostics():toggle() end, desc = "Toggle diagnostics" },
      { "<leader>un", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    },
  },

  -- Git signs in gutter + blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(buf)
        local gs = require("gitsigns")
        local m = function(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
        m("]h", function() gs.nav_hunk("next") end, "Next git change")
        m("[h", function() gs.nav_hunk("prev") end, "Previous git change")
        m("<leader>gp", gs.preview_hunk, "Preview change")
        m("<leader>gr", gs.reset_hunk, "Revert change")
        m("<leader>gS", gs.stage_hunk, "Stage change")
        m("<leader>gb", gs.blame_line, "Blame line")
        m("<leader>gt", gs.toggle_current_line_blame, "Toggle inline blame")
        m("<leader>gd", gs.diffthis, "Diff this file")
      end,
    },
  },

  -- Auto pairs, surround
  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
  { "echasnovski/mini.surround", event = "VeryLazy", opts = {} },

  -- Multi-cursor-ish: Ctrl+D selects next occurrence (like VSCode)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = { ["Find Under"] = "<C-d>", ["Find Subword Under"] = "<C-d>" }
    end,
  },
}
