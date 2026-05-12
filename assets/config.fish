# Delete word with CTRL + Backspace
bind \cH backward-kill-path-component

# Clear completely with CTRL + L
bind \cL 'clear; commandline -f repaint'

function fish_greeting
  fastfetch
  echo; fortune

  # wildcard always acts like failglob, unless in a for, set etc.
  for motd in /run/motd.d/*
    cat $motd
  end
end

function mkcd
  mkdir -p $argv[1]
  cd $argv[1]
end


function nrb
  # fix the annoying "Path /tmp is world-writable" error
  # https://github.com/NixOS/nix/issues/13701
  sudo chmod -v o-w /tmp
  sudo chown -v root:users /tmp

  test -n "$HOST" # NB: use-substitutes included in nix config
  and set host_args --target-host $HOST --build-host $HOST # --flake /etc/nixos#$HOST

  # override child flakes for local development
  # TODO: find another way that works with the eval cache
  set dev --override-input mypkgs ~/.nix/nur.nix

  if test "$argv[1]" = "dry"
    nixos-rebuild dry-build $dev $host_args --print-build-logs
  else
    nixos-rebuild $argv $dev $host_args --sudo --no-reexec --log-format internal-json &| nom --json
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

function alienate
  set notfounds (ldd    $argv[1] | rg 'not found' | sd '=> not found|\s+' '')
  set unuseds   (ldd -u $argv[1] | rg '\.so'      | sd               '\s' '')

  set useds (for lib in $notfounds
    contains -- $lib $unuseds; or echo $lib
  end)

end

atuin  init fish | source
zoxide init fish | source
