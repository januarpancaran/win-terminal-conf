# ~/.bashrc

# History Settings
HISTSIZE=10000
HISTFILE=~/.bash_history
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Keybindings
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# Fastfetch
if command -v fastfetch &>/dev/null; then
    fastfetch
fi

# Aliases
alias ls='ls -a --color=auto'
alias ll='ls -la --color=auto'
alias vi='nvim'
alias vim='nvim'
alias svim='sudo nvim'
alias nfzf='nvim $(fzf -m --preview=bat --color=always {}")'
alias cat='batcat'
alias grep='grep --color=auto'
alias rm='trash'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

export PATH="$HOME/go/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="/opt/mssql-tools18/bin:$PATH"

# Autostarts
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
eval "$(starship init bash)"
eval "$(zoxide init bash)"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env)"
fi

# mise
eval "$(mise activate bash)"
