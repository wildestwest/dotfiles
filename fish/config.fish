if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias l="ls"
alias la="ls -la"
alias v="nvim"
alias lg="lazygit"
set fish_greeting
export AWS_USERNAME='CWP\Hullander.Weston.161'
bind \cf 'tmux-sessionizer'
bind -M insert \cf 'tmux-sessionizer'

set -g fish_key_bindings fish_vi_key_bindings

# Set up fzf key bindings
fzf --fish | source

export EDITOR="nvim"

zoxide init fish --cmd c | source
