# Neovim (VSCode-like)

Neovim config with VSCode-style keybindings, key hints (which-key), file explorer,
LSP/completion, and Claude Code + Codex integration.

## Requirements
- Neovim >= 0.11 (tested 0.12.x). Ubuntu's apt package is too old; install the release tarball:
  ```sh
  mkdir -p ~/.local/opt && cd ~/.local/opt
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
  tar xzf nvim-linux-x86_64.tar.gz && ln -sf ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
  ```
- git, gcc/make, ripgrep, fd, node/npm, `tree-sitter` CLI (`npm i -g tree-sitter-cli`), a Nerd Font
- Optional: `claude` (Claude Code CLI), `codex` (Codex CLI), `lazygit`

## Install
```sh
ln -s ~/.config/dotfiles/nvim ~/.config/nvim
nvim   # plugins, parsers and LSP servers install on first start
```

## Usage
Leader is `Space`: press it and wait for hints. `Space ?` opens the cheatsheet ([CHEATSHEET.md](CHEATSHEET.md)).
