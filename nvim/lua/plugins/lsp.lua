-- Code intelligence: LSP (go-to-definition, rename, errors), completion, syntax, formatting
return {
  -- Syntax highlighting (tree-sitter, `main` branch for nvim 0.12)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local langs = {
        "bash", "c", "cpp", "lua", "python", "json", "yaml", "toml", "markdown", "markdown_inline",
        "make", "cmake", "dockerfile", "diff", "git_config", "gitcommit", "devicetree", "kconfig",
        "bitbake", "rust", "go", "javascript", "typescript", "html", "css", "vim", "vimdoc", "regex",
      }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- LSP server installer (:Mason opens a UI to install more)
  { "mason-org/mason.nvim", cmd = "Mason", build = ":MasonUpdate", opts = { ui = { border = "rounded" } } },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
    opts = {
      ensure_installed = { "lua_ls", "clangd", "pyright", "bashls", "jsonls", "yamlls", "dockerls" },
      automatic_enable = true,
    },
    config = function(_, opts)
      require("mason").setup()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } }, workspace = { checkThirdParty = false } } },
      })
      require("mason-lspconfig").setup(opts)
    end,
  },

  -- VSCode-style LSP keymaps, set when a language server attaches
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    init = function()
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = { border = "rounded" },
        signs = { text = { [1] = " ", [2] = " ", [3] = " ", [4] = "󰌵 " } },
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local m = function(mode, l, r, d) vim.keymap.set(mode, l, r, { buffer = ev.buf, desc = d }) end
          m("n", "<F12>", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          m("n", "gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          m("n", "<S-F12>", function() Snacks.picker.lsp_references() end, "Find references")
          m("n", "gr", function() Snacks.picker.lsp_references() end, "Find references")
          m("n", "gi", function() Snacks.picker.lsp_implementations() end, "Go to implementation")
          m("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover docs")
          m("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          m("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          m({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Quick fix / code action")
          m({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Quick fix / code action")
          m("n", "<leader>ld", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          m("n", "<leader>lR", function() Snacks.picker.lsp_references() end, "Find references")
          m("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, "Symbols in file")
          m("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, "Toggle inlay hints")
          m("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", "LSP info")
          m("i", "<C-S-Space>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "Signature help")
        end,
      })
    end,
  },

  -- Autocomplete popup (Tab/Enter to accept, like VSCode)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "super-tab",          -- Tab accepts, Shift-Tab goes back
        ["<CR>"] = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300, window = { border = "rounded" } },
        menu = { border = "rounded" },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      cmdline = { completion = { menu = { auto_show = true } } },
    },
  },

  -- Format document (Shift+Alt+F like VSCode)
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
      { "<S-A-f>", function() require("conform").format({ lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format document" },
      { "<leader>lf", function() require("conform").format({ lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format document" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black", stop_after_first = true },
        sh = { "shfmt" },
      },
      -- format_on_save is off on purpose: kernel/Yocto trees have their own style. Enable per project if wanted.
    },
  },

  -- Problems panel (like VSCode's "Problems" tab)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<C-S-m>", "<cmd>Trouble diagnostics toggle<cr>", desc = "Problems panel" },
      { "<leader>lp", "<cmd>Trouble diagnostics toggle<cr>", desc = "Problems panel" },
      { "<leader>lo", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Outline (symbols)" },
    },
  },
}
