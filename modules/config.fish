# Delete word with CTRL + Backspace
bind \cH backward-kill-path-component

# Clear completely with CTRL + L
bind \cL 'clear; commandline -f repaint'

function fish_greeting
  fastfetch
end

atuin  init fish | source
zoxide init fish | source
