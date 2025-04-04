if status is-interactive
    # Commands to run in interactive sessions can go here
end

export AWS_USERNAME='CWP\Hullander.Weston.161'
alias em 'emacsclient -nw -a ""'
set EDITOR /usr/bin/hx
set fish_greeting
set TERM xterm-256color
set TMUX_TMPDIR /var/tmp

# direnv hook fish | source
set -g fish_key_bindings fish_vi_key_bindings
source /home/whulland/.config/fish/functions/fish_prompt.fish

zoxide init fish --cmd c | source
