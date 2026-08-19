# dotfiles

macOS (Apple Silicon) setup: **cmux** terminal tuned for paper-like reading, and a **zsh** profile built around fzf, atuin, zoxide and Powerlevel10k.

```
cmux/config.ghostty   terminal typography (cmux's live Ghostty config)
claude/hooks/         Claude Code hooks — paper palette, per pane
cmux/cmux.json        cmux app chrome (appearance, sidebar)
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

## Claude-only paper palette

The terminal itself keeps cmux's default theme, which follows the system light/dark mode. The paper palette is applied **only to panes running Claude Code**, by `claude/hooks/paper-theme.sh` writing OSC escapes (`4;N` palette, `10` fg, `11` bg, `12` cursor) straight to the pane's tty — and undone with `104`/`110`/`111`/`112` when the session ends.

Register it in `~/.claude/settings.json`:

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

Light mode gives creamy-white `#FDFCF8` with `#2E3E44` ink; dark mode gives Selenized Dark deepened to `#0F3841`. The script also writes `theme: light-ansi` / `dark-ansi` into `~/.claude/settings.json` so Claude's own colors match — that part lands on the next session, since Claude reads its theme at startup.

Font, cell height and padding stay global in `cmux/config.ghostty`: no escape sequence can scope those to one pane.

## Terminal appearance

Colors live in the Claude hook (above), not in `cmux/config.ghostty`. Alternates worth trying for the light background: `#FBF9F3` warmer, `#F9F9F8` neutral grey.

Three gotchas worth remembering:

- **`cmux themes set` rewrites `config.ghostty` wholesale**, dropping every hand-written setting. Re-apply this repo's copy afterwards.

- Ghostty rejects a line with a trailing `# comment` after the value — the whole setting is silently dropped and the theme default wins. Comments go on their own line.
- `faint-opacity = 1` and `unfocused-split-opacity = 1` stop dim/washed-out text on a light background.

## Obsidian

![image](https://github.com/user-attachments/assets/02712a67-245e-4eb3-a885-f0b02543b393)

- IBM Plex font (Sans, Serif & Mono) is required.
- Stacked tabs might not be enabled by default — press `ctrl+p` and select `Toggle Stacked Tabs`.
- Further colorscheme adjustments are derived from the Goodreads color scheme.
