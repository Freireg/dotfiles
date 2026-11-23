-- Look & feel: VSCode theme, tabs bar, status bar, start screen, notifications
return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode").setup({ style = "dark", italic_comments = true })
      vim.cmd.colorscheme("vscode")
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Utility belt: start screen, picker (Ctrl+P), notifications, terminal, etc.
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true, ui_select = true },
      indent = { enabled = true, animate = { enabled = false } },
      words = { enabled = true },
      terminal = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find file          Ctrl+P", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "g", desc = "Search in files    Space f g", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "e", desc = "File explorer      Ctrl+B", action = ":Neotree toggle" },
            { icon = "󰚩 ", key = "a", desc = "Claude Code        Space a a", action = ":ClaudeCode" },
            { icon = "󰘥 ", key = "?", desc = "Cheatsheet         Space ?", action = function() vim.api.nvim_feedkeys(vim.keycode("<leader>?"), "m", false) end },
            { icon = " ", key = "c", desc = "Edit config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
            { icon = "󰒲 ", key = "l", desc = "Plugins (Lazy)", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },

  -- Editor tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = { { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left" } },
      },
    },
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "vscode", globalstatus = true, section_separators = "", component_separators = "│" },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
      },
    },
  },

  -- KEY HINTS: press <Space> (or g, z, [, ], Ctrl-w...) and wait
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader>a", group = "AI (Claude / Codex)", icon = "󰚩 " },
        { "<leader>f", group = "Find / Search" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "Code (LSP)" },
        { "<leader>t", group = "Terminal" },
        { "<leader>b", group = "Buffers/Tabs" },
        { "<leader>u", group = "UI toggles" },
      },
    },
    keys = {
      { "<leader>k", function() require("which-key").show({ global = true }) end, desc = "Show ALL keymaps" },
    },
  },
}
