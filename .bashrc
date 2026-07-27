#
# ~/.bashrc
#

# ─────────────────────────────────────────────
# 1. Only run in interactive shells
# ─────────────────────────────────────────────
[[ $- != *i* ]] && return

# ─────────────────────────────────────────────
# 2. Basic environment
# ─────────────────────────────────────────────
export EDITOR=nvim
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
shopt -s histverify

# Better history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Expand !! on space press
bind 'Space:magic-space'

# Vi keybindings (like fish_vi_key_bindings)
set -o vi

# ─────────────────────────────────────────────
# 3. Startup banner
# ─────────────────────────────────────────────
if [[ -f "$HOME/.termux/ascii_art.txt" ]]; then
  echo ""
  printf '\033[1;36m'
  cat "$HOME/.termux/ascii_art.txt"
  printf '\033[0m'
  echo ""
fi

# ─────────────────────────────────────────────
# 4. Safer defaults
# ─────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ─────────────────────────────────────────────
# 5. Core aliases (eza, grep, navigation)
# ─────────────────────────────────────────────
alias ls='eza --color=auto --group-directories-first --icons=auto'
alias ll='eza -l --color=auto --group-directories-first --icons=auto --header --git'
alias la='eza -a --color=auto --group-directories-first --icons=auto'
alias lla='eza -la --color=auto --group-directories-first --icons=auto --header --git'
alias lt='eza -T --color=auto --group-directories-first --icons=auto'
alias lta='eza -Ta --color=auto --group-directories-first --icons=auto'

alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias home='cd ~'

# Quick network + system checks
alias ports='ss -tulnp'
alias mem='free -h'
alias dfh='df -h'

# ─────────────────────────────────────────────
# 6. Tmux
# ─────────────────────────────────────────────
alias t='tmux'
alias ta='tmux attach'
alias ts='tmux new-session -s'

# ─────────────────────────────────────────────
# 7. Application shortcuts
# ─────────────────────────────────────────────
alias v='nvim'
alias vz='fzf --multi --bind "enter:become(nvim {+})" --preview="bat --color=always {}"'

# ─────────────────────────────────────────────
# 8. Prompt helpers
# ─────────────────────────────────────────────
RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"

prompt_status() {
  if [[ $? -eq 0 ]]; then
    echo -ne "${GREEN}✔${RESET}"
  else
    echo -ne "${RED}✘${RESET}"
  fi
}

# Prompt: status · user@host : path $
export PS1='$(prompt_status) \[\e[34m\]\u@\h\[\e[0m\]:\[\e[36m\]\w\[\e[0m\]\$ '

# ─────────────────────────────────────────────
# 9. Ctrl+O clear screen
# ─────────────────────────────────────────────
bind '"\C-o": clear-screen'

# Initialize zoxide
eval "$(zoxide init bash)"
