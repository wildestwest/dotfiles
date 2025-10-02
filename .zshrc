# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/coder/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Enable git info in prompt
autoload -Uz vcs_info
precmd() { vcs_info }

# Configure git info format
zstyle ':vcs_info:git:*' formats ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'

# Enable prompt substitution
setopt prompt_subst

# Define the prompt
PROMPT='%F{cyan}%n%f in %F{yellow}%~%f%F{green}${vcs_info_msg_0_}%f
$ '

alias l='ls'
alias la='ls -la'
alias v='nvim'

bindkey -s '^f' "tmux-sessionizer\n"

eval "$(zoxide init zsh --cmd c)"
