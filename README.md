# dotfiles

macOS (Apple Silicon). **cmux runs stock** — no theme, font, padding or chrome overrides. All terminal customization is scoped to Claude Code panes and applied at runtime. Plus a zsh profile built around fzf, atuin, zoxide and Powerlevel10k, and an Obsidian vault config.

```
claude/hooks/         Claude Code hooks — per-pane palette
cmux/config.ghostty   intentionally empty — cmux runs on its defaults
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

# claude
mkdir -p ~/.claude/hooks
ln -sf ~/dotfiles/claude/hooks/paper-theme.sh ~/.claude/hooks/paper-theme.sh
```

Machine-local secrets and overrides go in `~/.zshrc.local` — sourced last, never committed (gitignored). `~/.claude/settings.json` is deliberately not in this repo; only the hook wiring below is.

## Claude pane palettes

`claude/hooks/paper-theme.sh` paints **one pane** with OSC escapes (`4;N` palette, `10` fg, `11` bg, `12` cursor; `104`/`110`/`111`/`112` to undo). Other panes, and the terminal itself, are untouched.

| Command | Result |
|---|---|
| `paper` | cream `#FDFCF8`, `#2E3E44` ink, Selenized Light palette — for reading long output |
| `paper off` | high-contrast black: `#F2F2F2` on `#000000`, bright ANSI palette |
| `paper reset` | drop the override, inherit the terminal's own colors |

Claude Code runs `set` (black) on `SessionStart` and `reset` on `SessionEnd`. Wire it in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/paper-theme.sh\" set", "timeout": 5 }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/paper-theme.sh\" reset", "timeout": 5 }] }
    ]
  }
}
```

The script resolves the pane's tty through `/dev/tty`, falling back to the parent process's tty — needed because Claude spawns hooks without a controlling terminal.

Claude's own theme is `dark-ansi`. In paper mode the bright ANSI slots (8-15) hold dark ink colors, so `dark-ansi` output stays readable on cream without restarting the session.

**Colors only.** Font family, font size, cell height and padding have no escape sequence, and cmux exposes no per-pane font setting — a Claude pane uses whatever font cmux is running. Per-workspace font *size* can be nudged by hand with cmux's `increaseWorkspaceTerminalFontSize` / `decreaseWorkspaceTerminalFontSize` shortcuts.

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
