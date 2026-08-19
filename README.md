# dotfiles

macOS (Apple Silicon) setup: **cmux** terminal tuned for paper-like reading, and a **zsh** profile built around fzf, atuin, zoxide and Powerlevel10k.

```
cmux/config.ghostty   intentionally empty — cmux runs stock
claude/hooks/         Claude Code hooks — paper palette, per pane
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

# cmux — its live Ghostty config lives in the app support dir
ln -sf ~/dotfiles/cmux/config.ghostty \
  "$HOME/Library/Application Support/com.cmuxterm.app/config.ghostty"
# plain-Ghostty path points at the same file, so the two can't drift
ln -sf ~/dotfiles/cmux/config.ghostty \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

mkdir -p ~/.config/cmux
ln -sf ~/dotfiles/cmux/cmux.json ~/.config/cmux/cmux.json

cmux reload-config
```

Machine-local secrets and overrides go in `~/.zshrc.local` — sourced last, never committed (gitignored).

## Dependencies

### Terminal

| Dependency | Install | Notes |
|---|---|---|
| cmux | https://cmux.com | bundles Ghostty 1.3.x; verified on 0.64.22 |
| RecMonoSmCasual Nerd Font | `brew install --cask font-recursive-mono-nerd-font` | active terminal font |
| AtkynsonMono Nerd Font | `brew install --cask font-atkynson-mono-nerd-font` | alternative, Atkinson Hyperlegible shapes |

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
| eza | `brew install eza` — `ls`/`ll`/`la`/`tree`/`lg`/`lt` fall back to plain `ls` if absent |
| bat | `brew install bat` — `cat`/`catn`, man pages, fzf preview; theme `GitHub` |
| fd | `brew install fd` — backs `ff` and fzf's file search |

Every block above is guarded by a `command -v` / readable-path check, so the shell still starts with any of them missing.

### Shell — optional, only powers matching aliases and completions

`gh`, `kubectl`, `dotnet`, `node` + `npm`, `bun`, `pyenv`, `jq`, `rg`, `docker`, `nvm`, `sdkman`.

## Dependencies

### Terminal

| Dependency | Install | Notes |
|---|---|---|
| cmux | https://cmux.com | bundles Ghostty 1.3.x; verified on 0.64.22 |
| RecMonoSmCasual Nerd Font | `brew install --cask font-recursive-mono-nerd-font` | active terminal font |
| AtkynsonMono Nerd Font | `brew install --cask font-atkynson-mono-nerd-font` | alternative, Atkinson Hyperlegible shapes |

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
| eza | `brew install eza` — `ls`/`ll`/`la`/`tree`/`lg`/`lt` fall back to plain `ls` if absent |
| bat | `brew install bat` — `cat`/`catn`, man pages, fzf preview; theme `GitHub` |
| fd | `brew install fd` — backs `ff` and fzf's file search |

Every block above is guarded by a `command -v` / readable-path check, so the shell still starts with any of them missing.

### Shell — optional, only powers matching aliases and completions

`gh`, `kubectl`, `dotnet`, `node` + `npm`, `bun`, `pyenv`, `jq`, `rg`, `docker`, `nvm`, `sdkman`.

## Pane palettes

The terminal runs **high-contrast black** — `#F2F2F2` on `#000000`, a hand-set bright ANSI palette, and `minimum-contrast = 4.5` as a floor so no app can print unreadably dim text. Selenized Dark's own colors are tuned for `#103C48` and go muddy on pure black, hence the hand-set palette.

`claude/hooks/paper-theme.sh` paints **one pane** with OSC escapes (`4;N` palette, `10` fg, `11` bg, `12` cursor; `104`/`110`/`111`/`112` to undo):

| Command | Result |
|---|---|
| `paper` | cream `#FDFCF8` with `#2E3E44` ink, Selenized Light palette — for reading long output |
| `paper off` | back to high-contrast black |
| `paper reset` | drop the override, inherit the terminal theme |

Claude Code runs `set` (black) on `SessionStart` and `reset` on `SessionEnd`, via `~/.claude/settings.json`:

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

Claude's own theme is `dark-ansi`. In paper mode the bright ANSI slots (8-15) are dark ink colors, so `dark-ansi` output stays readable on cream without a restart.

Font, cell height and padding stay global in `cmux/config.ghostty`: no escape sequence can scope those to one pane.

## Gotchas

- **`cmux themes set` rewrites `config.ghostty` wholesale**, dropping every hand-written key.
- Ghostty rejects a line with a trailing `# comment` after the value — the whole setting is silently dropped and the theme default wins. Comments go on their own line.
- `faint-opacity = 1` and `unfocused-split-opacity = 1` stop dim/washed-out text on a light background, if you ever do set global config.

## Obsidian

![image](https://github.com/user-attachments/assets/02712a67-245e-4eb3-a885-f0b02543b393)

- IBM Plex font (Sans, Serif & Mono) is required.
- Stacked tabs might not be enabled by default — press `ctrl+p` and select `Toggle Stacked Tabs`.
- Further colorscheme adjustments are derived from the Goodreads color scheme.
