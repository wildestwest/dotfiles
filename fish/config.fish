if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias l="lsd"
alias la="lsd -la"
alias py="uv run python"
export AWS_USERNAME='CWP\Hullander.Weston.161'
alias em 'emacsclient -nw -a ""'
set EDITOR /usr/bin/hx
set fish_greeting
set TERM xterm-256color
set TMUX_TMPDIR /var/tmp

# direnv hook fish | source
set -g fish_key_bindings fish_vi_key_bindings

# --- setup fzf theme ---
set fg "#CBE0F0"
set bg "#011628"
set bg_highlight "#143652"
set purple "#B388FF"
set blue "#06BCE4"
set cyan "#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan"

# Set up fzf key bindings
fzf --fish | source

thefuck --alias | source

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export EDITOR="nvim"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
function _fzf_compgen_path
    fd --hidden --exclude .git . "$1"
end

# Use fd to generate the list for directory completion
function _fzf_compgen_dir
    fd --type=d --hidden --exclude .git . "$1"
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

zoxide init fish --cmd c | source
