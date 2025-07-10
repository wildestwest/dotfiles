# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.path ++= ["~/.local/bin"]
$env.path ++= ["~/.local/scripts"]
$env.path ++= ["~/.cargo/bin"]
$env.EDITOR = "~/.cargo/bin/hx"
$env.config.buffer_editor = "~/.cargo/bin/hx"
$env.config.show_banner = false
$env.config.edit_mode = 'vi'

$env.config = {
  keybindings: [
    {
      name: tmux_sessionizer
      modifier: control
      keycode: char_f
      mode: [vi_insert vi_normal]
      event: [
		{ send: executehostcommand cmd: 'bash tmux-sessionizer' }
		]
    },
    {
      name: completion_menu
      modifier: control
      keycode: char_t
      mode: [vi_insert vi_normal]
      event: { send: menu name: completion_menu }
    }
  ]
}

alias y = yazi
alias l = ls
alias la = ls -la
alias z = zellij
alias lg = lazygit
alias v = nvim

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

source aws-completions.nu
source pytest-completions.nu
source rustup-completions.nu
source zoxide.nu


