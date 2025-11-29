# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=2000
setopt autocd extendedglob nomatch
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/whulland/.zshrc'

autoload -Uz compinit
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
alias lg='lazygit'

# path+=('/Users/whulland/.local/bin/')
path+=('/home/whulland/.local/bin/')

bindkey -s '^f' "tmux-sessionizer\n"

# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(zoxide init zsh --cmd c)"
