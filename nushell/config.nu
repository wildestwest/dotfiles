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
$env.path ++= ["/Applications/WezTerm.app/Contents/MacOS"]
$env.EDITOR = "/opt/homebrew/bin/hx"
$env.config.buffer_editor = "hx"
$env.config.show_banner = false
$env.config.edit_mode = 'vi'

$env.config = {
  keybindings: [
    {
      name: completion_menu
      modifier: control
      keycode: char_t
      mode: vi_insert
      event: { send: menu name: completion_menu }
    }
  ]
}

alias y = yazi
alias l = ls
alias la = ls -la

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

source git-completions.nu
source aws-completions.nu
source pytest-completions.nu
source docker-completions.nu
source rustup-completions.nu
source zoxide.nu


