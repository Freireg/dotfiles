# Neovim Cheatsheet  (Leader = Space)

**Lost? Press `Space` and wait — a hint menu shows every shortcut.**
`Space k` shows ALL keymaps · `Ctrl+Shift+P` / `F1` command palette · `Space f k` search keymaps

## The 3 modes (the only "vim" thing you must know)
| Key | Does |
|---|---|
| `i` | start typing (Insert mode) |
| `Esc` | stop typing (back to Normal mode) |
| `v` / `V` | select characters / whole lines (Visual mode) |
| `:w` `:q` | save / quit (or just `Ctrl+S`, `Space q`) |

## VSCode-style shortcuts
| Key | Action |
|---|---|
| `Ctrl+S` | Save |
| `Ctrl+Z` / `Ctrl+Y` | Undo / Redo (or `u` / `Ctrl+R` in normal mode) |
| `Ctrl+P` | Find file |
| `Ctrl+Shift+F` / `Space f g` | Search text in project |
| `Ctrl+Shift+P` / `F1` | Command palette |
| `Ctrl+B` / `Space e` | File explorer (`a` new, `d` delete, `r` rename, `?` help) |
| `Ctrl+\` / `Ctrl+`` | Toggle terminal (`Esc Esc` to leave terminal typing) |
| `Ctrl+/` | Toggle comment |
| `Ctrl+D` | Select next occurrence (multi-cursor) |
| `Alt+↑/↓` | Move line(s) |
| `Tab` / `Shift+Tab` | Next / previous editor tab (indent in visual mode) |
| `Space x` | Close tab |
| `Ctrl+A` | Select all |
| `Ctrl+H/J/K/L` | Move between split windows |
| `Space \` / `Space -` | Split right / below |

## Code (when a language server is active)
| Key | Action |
|---|---|
| `F12` / `gd` | Go to definition |
| `Shift+F12` / `gr` | Find references |
| `K` | Hover docs |
| `F2` | Rename symbol |
| `Ctrl+.` / `Space l a` | Quick fix / code action |
| `Shift+Alt+F` | Format document |
| `F8` / `Shift+F8` | Next / previous problem |
| `Ctrl+Shift+M` | Problems panel |
| `Ctrl+Shift+O` | Symbols in file |
| `Ctrl+O` / `Ctrl+I` | Jump back / forward |
| Completion | `Tab` or `Enter` accept · `Ctrl+Space` open · `Ctrl+E` close |

`:Mason` installs more language servers / formatters.

## AI agents (`Space a`)
| Key | Action |
|---|---|
| `Space a a` / `Ctrl+Shift+A` | Open Claude Code chat (side panel) |
| select text + `Space a a` | Send selection to Claude |
| `Space a b` | Add current file to Claude's context |
| `Space a y` / `Space a n` | Accept / reject Claude's proposed diff |
| `Space a r` / `Space a C` | Resume / continue a Claude session |
| `Space a c` | Open Codex chat (side panel) |
| `Space a s` | Mention file (or selection) in Codex |

Claude edits show up as a diff split: review, then `Space a y` (or `:w`) to accept.
Files changed by agents are auto-reloaded.

## Git (`Space g`)
`]h` / `[h` next/prev change · `Space g p` preview · `Space g r` revert · `Space g b` blame
`Space g s` changed files · `Space g l` log · `Space g g` lazygit (if installed)

## Handy vim moves (optional, faster than the mouse)
`w`/`b` next/prev word · `0`/`$` line start/end · `gg`/`G` top/bottom · `/text` search, `n` next
`dd` delete line · `yy` copy line · `p` paste · `ciw` change word · `.` repeat last edit

Learn vim properly any time: `:Tutor`
