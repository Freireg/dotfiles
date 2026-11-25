# Herdr

Config for [herdr](https://herdr.dev) (terminal workspace manager for AI coding agents), tested with herdr 0.9.5.

What's in here:
- `config.toml`: theme (vesper), keys, the Agents sidebar layout (the block between the `herdr-usage managed block` markers is rewritten by the herdr-usage plugin), and toasts.
- `scripts/gh-prs.py`: GitHub PR watchlist. It covers every open PR you're involved in (author, requested reviewer, assignee, mentioned, or commented).
  - **Tab bar (right side):** `⎇ PR 32 · mine 10 ✓6 ✗1 · review 14 · CI✗ 1`, refreshed every 120 s and cached for 90 s in `~/.cache/herdr-gh-prs.json`.
  - **`prefix+shift+g`:** opens a popup listing PRs grouped as *waiting for your review* / *yours* / *involved*, with CI and review state. Type a number to open the PR in the browser, `r` to refresh, `q` to quit.
- `plugins-config/herdr-usage/config.toml`: settings for the herdr-usage gauges.

## Dependencies
- herdr ≥ 0.9.5: `curl -fsSL https://herdr.dev/install.sh | sh`
- `python3` ≥ 3.9 (stdlib only)
- [GitHub CLI](https://cli.github.com/) `gh`, logged in: `gh auth login`
- `xdg-open` (to open PRs from the popup)
- A Nerd Font / terminal with Unicode support for the status glyphs
- Plugins used by the config:
  - [herdr-usage](https://github.com/EdTheBearded/herdr-usage): agent usage gauges in the sidebar (`prefix+u`)
  - [herdbake](https://github.com/Freireg/herdbake) (branch `feat/build-monitor`): BitBake build popups/monitor (`prefix+shift+b`)

## Install on a new PC
```sh
git clone git@github.com:Freireg/dotfiles.git ~/.config/dotfiles

# 1. herdr + gh
curl -fsSL https://herdr.dev/install.sh | sh
gh auth login

# 2. link config and scripts
mkdir -p ~/.config/herdr
ln -s ~/.config/dotfiles/herdr/config.toml ~/.config/herdr/config.toml
ln -s ~/.config/dotfiles/herdr/scripts     ~/.config/herdr/scripts

# 3. plugins
herdr plugin install EdTheBearded/herdr-usage
git clone -b feat/build-monitor git@github.com:Freireg/herdbake.git ~/Projects/herdbake
herdr plugin link ~/Projects/herdbake
cp ~/.config/dotfiles/herdr/plugins-config/herdr-usage/config.toml "$(herdr plugin config-dir herdr-usage)/config.toml"

# 4. verify and apply
herdr config check && herdr server reload-config
~/.config/herdr/scripts/gh-prs.py status   # should print the PR summary line
```

## Notes
- `config.toml` is a symlink, so edits from herdr's settings UI and from herdr-usage land in this repo. Review `git diff` before committing.
- Skip the herdbake steps if you don't build Yocto on that machine. In that case, also delete the `herdbake.monitor` `[[keys.command]]` entry and the `$hb_build` sidebar row.
- To change what counts as "involved", edit the GraphQL `search` queries at the top of `scripts/gh-prs.py`.
