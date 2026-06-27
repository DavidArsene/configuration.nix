# Delete word with CTRL + Backspace
bind \cH backward-kill-path-component

# Clear completely with CTRL + L
bind \cL 'clear; commandline -f repaint'

# Disable pager use in all systemd commands
set -x SYSTEMD_PAGER cat

function fish_greeting
    fastfetch
    echo
    fortune

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
    dolphin (dirname (readlink (which $argv[1])) | tee /dev/stderr)
end

function nrb
    test -n "$HOST" # NB: use-substitutes included in nix config
    and set -l host_args --target-host $HOST --build-host $HOST # --flake /etc/nixos#$HOST

    # override child flakes for local development
    # TODO: find another way that works with the eval cache
    set -l dev --override-input mypkgs ~/.nix/nur.nix
    set -a dev --override-input minimal ~/.nix/minimal.nix

    if test "$argv[1]" = dry
        nixos-rebuild dry-build $argv[2..-1] $dev $host_args --print-build-logs
    else
        set -x NIXOS_MINIFY_REPLACE_DEPS 1
        nixos-rebuild $argv $dev $host_args --keep-going --sudo --no-reexec --diff --log-format internal-json &| nom --json
    end
end

function pkgs-branches
    for branch in master nixpkgs-unstable nixos-unstable

        set -l api (
      curl -s "https://api.github.com/repos/NixOS/nixpkgs/commits/$branch" |
        jq -r '.commit.committer.date'
    )
        echo -e $branch (date -d $api +"%d %b %Y - %H:%M")
    end | column -t -R 1 -S 1
end
# notify-send --expire-time 20000 --print-id nixpkgs "(pkgs-branches)"

# TODO: programs atuin enable
atuin init fish | source
zoxide init fish | source
