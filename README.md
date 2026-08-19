# dotfiles

macOS (Apple Silicon). **cmux runs stock apart from the font** — no theme, padding or chrome overrides; font family and size are global because no mechanism scopes them to one pane. Claude Code colors live in [claude-themes](https://github.com/imhalawa/claude-themes). Plus a zsh profile built around fzf, atuin, zoxide and Powerlevel10k, and an Obsidian vault config.

```
cmux/config.ghostty   font family and size only — everything else stock
cmux/cmux.json        cmux defaults, untouched
zsh/.zshrc            shell config
zsh/.zprofile         login-shell PATH entries
zsh/.p10k.zsh         Powerlevel10k prompt config
.obsidian/            Obsidian vault config (see below)
tmux.conf             tmux config
```

## Install

```sh
git clone git@github.com:imhalawa/dotfiles.git ~/dotfiles

# zsh
ln -sf ~/dotfiles/zsh/.zshrc    ~/.zshrc
ln -sf ~/dotfiles/zsh/.zprofile ~/.zprofile
ln -sf ~/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
```

Machine-local secrets and overrides go in `~/.zshrc.local` — sourced last, never committed (gitignored).

## Claude theme

Extracted to **[imhalawa/claude-themes](https://github.com/imhalawa/claude-themes)** — the
paper-mode theme, its OSC pane painter, its hook wiring and its shell wrapper now
live there as one installable folder.

```sh
git clone git@github.com:imhalawa/claude-themes.git ~/claude-themes
~/claude-themes/install.sh install paper-mode
```

That copies the theme and hook into `~/.claude`, merges the hook entries into
`settings.json` and selects the theme. `~/.claude/settings.json` is deliberately
not in this repo — the installer is what wires it.

The `paper` / `paper off` / `paper reset` shell function is in `zsh/.zshrc` here,
and mirrored as `themes/paper-mode/shell.zsh` there.

**Font is separate.** Font family, size, cell height and padding have no escape
sequence, Claude Code has no font setting, and cmux exposes no per-pane font — so
the font is global in `cmux/config.ghostty` (`RecMonoSmCasual Nerd Font Mono`,
16pt). Per-workspace font *size* can be nudged with cmux's
`increaseWorkspaceTerminalFontSize` / `decreaseWorkspaceTerminalFontSize`.
## Dependencies

### Shell — required

| Dependency | Install |
|---|---|
| Homebrew | https://brew.sh |
| powerlevel10k | `brew install powerlevel10k` |
| zsh-autosuggestions | `brew install zsh-autosuggestions` |
| zsh-syntax-highlighting | `brew install zsh-syntax-highlighting` |
| zsh-completions | `brew install zsh-completions` |
| fzf | `brew install fzf` |
| fzf-tab | `git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab` |
| atuin | `brew install atuin` — owns `Ctrl+R`; Up arrow stays prefix history search |
| zoxide | `brew install zoxide` — aliases `cd` to `z` |
| direnv | `brew install direnv` |
| eza | `brew install eza` — backs `ls`/`ll`/`la`/`lg`/`lt`, falls back to plain `ls` if absent |
| bat | `brew install bat` — backs `cat`/`catn`, man pages, fzf preview; theme `GitHub` |
| fd | `brew install fd` — backs `ff` and fzf's file search |

Every block is guarded by a `command -v` / readable-path check, so the shell still starts with any of them missing.

### Shell — optional, only powers matching aliases and completions

`gh`, `kubectl`, `dotnet`, `node` + `npm`, `bun`, `pyenv`, `jq`, `rg`, `docker`, `nvm`, `sdkman`.

### Terminal

| Dependency | Install |
|---|---|
| cmux | https://cmux.com — verified on 0.64.22, bundles Ghostty 1.3.x |
| a Nerd Font | e.g. `brew install --cask font-recursive-mono-nerd-font` — the p10k prompt and `eza --icons` need one |

## Gotchas

- **`cmux themes set` rewrites `config.ghostty` wholesale**, dropping every hand-written key. It is what emptied an earlier hand-tuned config.
- Ghostty silently drops a setting whose line ends in a trailing `# comment` after the value, falling back to the theme default. Comments go on their own line.
- cmux's live Ghostty config is `~/Library/Application Support/com.cmuxterm.app/config.ghostty`, not `~/.config/ghostty/config`. Check with `cmux themes` (`Source:`) and `cmux config doctor`; apply with `cmux reload-config`.

## Obsidian

![image](https://github.com/user-attachments/assets/02712a67-245e-4eb3-a885-f0b02543b393)

- IBM Plex font (Sans, Serif & Mono) is required.
- Stacked tabs might not be enabled by default — press `ctrl+p` and select `Toggle Stacked Tabs`.
- Further colorscheme adjustments are derived from the Goodreads color scheme.
