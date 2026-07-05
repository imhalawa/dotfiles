# ============================================================
# POWERLEVEL10K - Instant prompt (must be at the very top)
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ============================================================
# ZINIT - Auto-install if missing
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"


# ============================================================
# THEME
# ============================================================
zinit ice depth=1
zinit light romkatv/powerlevel10k


# ============================================================
# PLUGINS
# ============================================================
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Useful OMZ snippets (no need to install OMZ itself)
zinit snippet OMZP::git
zinit snippet OMZP::docker
zinit snippet OMZP::sudo


# ============================================================
# COMPLETIONS
# ============================================================
autoload -Uz compinit
compinit
zinit cdreplay -q

command -v dircolors >/dev/null && eval "$(dircolors -b)"

zstyle ':completion:*' menu select
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Arrow key navigation within the completion menu
zmodload zsh/complist
bindkey -M menuselect '^[[D' vi-backward-char
bindkey -M menuselect '^[[C' vi-forward-char
bindkey -M menuselect '^[[B' vi-down-line-or-history
bindkey -M menuselect '^[[A' vi-up-line-or-history
bindkey -M menuselect '^[[Z' reverse-menu-complete

# fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'


# ============================================================
# HISTORY
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history
setopt extended_history
setopt inc_append_history


# ============================================================
# KEY BINDINGS
# ============================================================
bindkey -e


# ============================================================
# SYNTAX HIGHLIGHTING + HISTORY SUBSTRING SEARCH
# ============================================================
# Important:
# - Do NOT load these with zinit `wait`.
# - The history-substring widgets must exist before binding keys to them.
# - Keep the bindkey lines after zsh-history-substring-search is loaded.

zinit ice depth=1
zinit light zdharma-continuum/fast-syntax-highlighting

zinit light zsh-users/zsh-history-substring-search

zmodload zsh/terminfo

# Up/down arrows for history substring search
bindkey -M emacs "$terminfo[kcuu1]" history-substring-search-up
bindkey -M emacs "$terminfo[kcud1]" history-substring-search-down

# Fallbacks for terminals that report raw escape sequences
bindkey -M emacs '^[[A' history-substring-search-up
bindkey -M emacs '^[[B' history-substring-search-down
bindkey -M emacs '^[OA' history-substring-search-up
bindkey -M emacs '^[OB' history-substring-search-down

# Also bind in vi insert mode in case vi mode is enabled later
bindkey -M viins "$terminfo[kcuu1]" history-substring-search-up
bindkey -M viins "$terminfo[kcud1]" history-substring-search-down
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M viins '^[OA' history-substring-search-up
bindkey -M viins '^[OB' history-substring-search-down


# ============================================================
# PATH
# ============================================================
# .NET
if [[ -d "$HOME/.dotnet" ]]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
fi


# ============================================================
# NVM (Node.js / npm / npx)
# ============================================================

# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"

# Load nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Enable bash-style completions in zsh, then load nvm completions
autoload -Uz bashcompinit
bashcompinit
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"



# ============================================================
# SDKMAN (Java / Kotlin / Gradle / Maven) — lazy loaded
# ============================================================
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"

  sdk() {
    unfunction sdk
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
  }
fi


# ============================================================
# NVM (Node) — lazy loaded for fast startup
# ============================================================
export NVM_DIR="$HOME/.nvm"

nvm() {
  unfunction nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

node() {
  nvm
  node "$@"
}

npm() {
  nvm
  npm "$@"
}

npx() {
  nvm
  npx "$@"
}


# ============================================================
# ALIASES
# ============================================================
alias r='cd /mnt/r'
alias ll='ls -lah --color=auto'
alias la='ls -a'
alias gs='git status'
alias gp='git pull'
alias gc='git checkout'
alias d='docker'
alias dc='docker compose'

# ============================================================
# POWERLEVEL10K CONFIG
# ============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
