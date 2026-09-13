# Delete word with CTRL + Backspace
bind \cH backward-kill-path-component

# Clear completely with CTRL + L
bind \cL 'clear; commandline -f repaint'

# Disable pager use in all systemd commands
set -x SYSTEMD_PAGER cat

function fish_greeting
    fastfetch
    echo

    # manually installed
    command -q fortune
    and fortune

    # wildcard always acts like failglob, unless in a for, set etc.
    for motd in /run/motd.d/*
        cat $motd
    end
end

function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

function whrl
    dirname (readlink (which $argv[1]))
end
