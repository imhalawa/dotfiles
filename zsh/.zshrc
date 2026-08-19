# ~/.zshrc
# Productivity-focused Zsh profile for macOS/Linux:
# history, completions, fzf-tab, Powerlevel10k prompt, navigation, aliases.

# =====================================================================
# Powerlevel10k instant prompt (MUST stay at the top of the file)
# =====================================================================
# Speeds up shell startup by rendering the prompt before the rest of
# .zshrc finishes loading. Nothing except env vars/options should run
# before this block.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =====================================================================
# Shell behavior
# =====================================================================

export EDITOR="${EDITOR:-code --wait}"
export VISUAL="$EDITOR"
export PAGER="${PAGER:-less}"
export LESS="-R -F -X"

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt CORRECT
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NUMERIC_GLOB_SORT
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PROMPT_SUBST

# =====================================================================
# History
# =====================================================================

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# =====================================================================
# Homebrew
# =====================================================================

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# =====================================================================
# Completions (fpath setup, compinit, styles, native CLI completions,
# fzf-tab UI)
# =====================================================================

# --- fpath entries — must be set before compinit ---

# Manual zsh-completions install:
# git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
[[ -d "$HOME/.zsh/zsh-completions/src" ]] && fpath=("$HOME/.zsh/zsh-completions/src" $fpath)

# Homebrew completion paths
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
[[ -d /usr/local/share/zsh/site-functions ]] && fpath=(/usr/local/share/zsh/site-functions $fpath)

# Linux fallback
[[ -d /usr/local/share/zsh/site-functions ]] && fpath=(/usr/local/share/zsh/site-functions $fpath)

# Avoid broken Docker Desktop WSL completion symlink on WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
  fpath=(${fpath:#/usr/share/zsh/vendor-completions})
fi

# Docker Desktop CLI completions
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# --- compinit ---

autoload -Uz compinit
zmodload -i zsh/complist

ZSH_COMPDUMP="$HOME/.zcompdump-clean"
compinit -i -d "$ZSH_COMPDUMP"

# --- completion styles ---

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

if [[ -n "$LS_COLORS" ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

if bindkey -M menuselect >/dev/null 2>&1; then
  bindkey -M menuselect '^[[Z' reverse-menu-complete
fi

# --- native CLI completions ---

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

# Kubectl
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# .NET CLI
if command -v dotnet >/dev/null 2>&1; then
  _dotnet_zsh_complete() {
    local completions
    completions="$(dotnet complete "$words")"
    reply=("${(ps:\n:)completions}")
  }

  compctl -K _dotnet_zsh_complete dotnet
fi

# Docker completion intentionally not sourced.
# Docker itself still works through aliases below.

# --- fzf-tab interactive completion UI ---
# Install:
# git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
#
# Usage:
#   gh <TAB>
#   select item with arrows
#   Enter inserts selection
#   then Space + TAB for next-level completions

if [[ -r "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"

  zstyle ':fzf-tab:*' fzf-command fzf
  zstyle ':fzf-tab:*' switch-group ',' '.'
  zstyle ':fzf-tab:*' show-group full
fi

# =====================================================================
# Prompt — Powerlevel10k
# =====================================================================
# Checked in common install locations. If none found, falls back to
# plain zsh prompt so the shell still works.
#
# Install options:
#   Homebrew:    brew install powerlevel10k
#   git clone:   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
#   Linux pkg:   apt install zsh-theme-powerlevel10k (path varies by distro)

autoload -Uz colors && colors

_p10k_paths=(
  /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme   # Homebrew (Apple Silicon)
  /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme      # Homebrew (Intel)
  /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme  # Linux package (Debian/Ubuntu)
  "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme"          # Manual git clone
)

for _p10k_path in "${_p10k_paths[@]}"; do
  if [[ -r "$_p10k_path" ]]; then
    source "$_p10k_path"
    break
  fi
done
unset _p10k_paths _p10k_path

# Per-user p10k config (created by `p10k configure`)
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Fallback prompt if Powerlevel10k isn't installed anywhere above
if [[ -z "$POWERLEVEL9K_VERSION" ]]; then
  autoload -Uz vcs_info
  zstyle ':vcs_info:git:*' formats ' %F{cyan}(%b)%f'
  zstyle ':vcs_info:git:*' actionformats ' %F{cyan}(%b|%a)%f'
  precmd() { vcs_info }
  PROMPT='%F{green}%n%f@%F{blue}%m%f %F{yellow}%~%f${vcs_info_msg_0_}
%F{white}❯%f '
fi

# =====================================================================
# Windows / WSL drives
# =====================================================================

if [[ -d /mnt/r ]]; then
  alias r='cd /mnt/r'
fi

if [[ -d /mnt/c ]]; then
  alias cdrive='cd /mnt/c'
fi

if [[ -d /mnt/d ]]; then
  alias ddrive='cd /mnt/d'
fi

# =====================================================================
# Directory navigation
# =====================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias dirs='dirs -v'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'

mkcd() {
  mkdir -p "$1" && cd "$1"
}

take() {
  mkdir -p "$1" && cd "$1"
}

# =====================================================================
# Safer defaults
# =====================================================================

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# =====================================================================
# Listing
# =====================================================================

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias tree='eza --tree --icons'
else
  alias ls='ls -G'
  alias ll='ls -lah'
  alias la='ls -la'
fi

# =====================================================================
# Useful aliases
# =====================================================================

alias c='clear'
alias cls='clear'
alias h='history'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'
alias zshrc='$EDITOR ~/.zshrc'

alias ports='lsof -i -P -n'
alias myip='curl -s https://api.ipify.org && echo'

if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
else
  alias grep='grep --color=auto'
fi

# =====================================================================
# Git aliases
# =====================================================================

alias g='git'
alias gs='git status --short'
alias gst='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias grs='git restore'
alias grss='git restore --staged'

# =====================================================================
# Docker aliases
# =====================================================================

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dlogs='docker logs -f'

# =====================================================================
# .NET aliases
# =====================================================================

alias dn='dotnet'
alias dnb='dotnet build'
alias dnr='dotnet run'
alias dnt='dotnet test'
alias dnw='dotnet watch'
alias dnc='dotnet clean'
alias dnrestore='dotnet restore'

# =====================================================================
# Node aliases
# =====================================================================

alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nb='npm run build'
alias nt='npm test'

# =====================================================================
# Functions
# =====================================================================

extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Cannot extract: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
}

serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

weather() {
  curl "wttr.in/${1:-}"
}

tmpd() {
  local dir
  dir="$(mktemp -d)"
  cd "$dir" || return
  echo "$dir"
}

ff() {
  find . -iname "*$1*"
}

ft() {
  grep -RIn "$1" .
}

killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local pid
  pid="$(lsof -ti tcp:"$1")"

  if [[ -z "$pid" ]]; then
    echo "No process found on port $1"
    return 0
  fi

  echo "Killing process on port $1: $pid"
  kill -9 "$pid"
}

# =====================================================================
# FZF integration
# =====================================================================

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border
    --info=inline
  "

  # Homebrew fzf shell integration
  [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh

  [[ -r /usr/local/opt/fzf/shell/key-bindings.zsh ]] && source /usr/local/opt/fzf/shell/key-bindings.zsh
  [[ -r /usr/local/opt/fzf/shell/completion.zsh ]] && source /usr/local/opt/fzf/shell/completion.zsh

  # Linux/manual fallback
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# =====================================================================
# Zoxide integration
# =====================================================================

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# =====================================================================
# Direnv integration
# =====================================================================

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# =====================================================================
# PATH
# =====================================================================

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Docker Desktop (macOS) installs its CLI in ~/.docker/bin
[[ -d "$HOME/.docker/bin" ]] && export PATH="$HOME/.docker/bin:$PATH"

[[ -d "$HOME/.dotnet/tools" ]] && export PATH="$HOME/.dotnet/tools:$PATH"
[[ -d "$HOME/.npm-global/bin" ]] && export PATH="$HOME/.npm-global/bin:$PATH"

# =====================================================================
# SDK / version managers
# =====================================================================

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# SDKMAN
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Pyenv
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# =====================================================================
# Key bindings
# =====================================================================

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Prefix-based history search:
# type "make", press Up => previous commands starting with "make"
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

# Ctrl+R history search
bindkey '^R' history-incremental-search-backward

# Ctrl+Left / Ctrl+Right word movement
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Alt+Left / Alt+Right word movement, common on macOS terminals
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Ctrl+Backspace / Backspace behavior
bindkey '^H' backward-kill-word
bindkey '^?' backward-delete-char

# =====================================================================
# Atuin — SQLite-backed shell history (fuzzy search, per-dir/host context)
# Install:  brew install atuin   (or: curl ... | sh)
# Bound AFTER key bindings above so it owns Ctrl+R.
# --disable-up-arrow keeps your prefix history search on the Up key.
# =====================================================================

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# =====================================================================
# Autosuggestions / syntax highlighting
# Syntax highlighting should be loaded last.
# =====================================================================

for plugin in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -r "$plugin" ]] && source "$plugin"
done

for plugin in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r "$plugin" ]] && source "$plugin"
done

# =====================================================================
# Local overrides
# =====================================================================

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# bun completions
[ -s "/Users/mohamed.halawa/.bun/_bun" ] && source "/Users/mohamed.halawa/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Rust toolchain installed by Homebrew (keg-only).
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =====================================================================
# bat / fd / eza — icons, git state, syntax colors
# =====================================================================

if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="GitHub"
  alias cat='bat --style=plain --paging=never'
  alias catn='bat --style=numbers,changes --paging=never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v fd >/dev/null 2>&1; then
  # replaces the find-based ff() defined earlier
  ff() { fd --hidden --follow "$1"; }
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if command -v eza >/dev/null 2>&1; then
  alias lg='eza -lah --icons --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons --git-ignore'
  alias ltt='eza --tree --level=3 --icons --git-ignore'
fi

if command -v fzf >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}'"
fi

# Flip the current pane between the high-contrast black palette and the cream
# paper palette: `paper` / `paper off`
paper() {
  case "${1:-on}" in
    off|black|dark) bash "$HOME/.claude/hooks/paper-theme.sh" black ;;
    reset)          bash "$HOME/.claude/hooks/paper-theme.sh" reset ;;
    *)              bash "$HOME/.claude/hooks/paper-theme.sh" set ;;
  esac
}
