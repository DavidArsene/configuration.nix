# Delete word with CTRL + Backspace
bind \cH backward-kill-path-component

# Clear completely with CTRL + L
bind \cL 'clear; commandline -f repaint'

function fish_greeting
  fastfetch

  cat /run/motd.d/* 2>/dev/null
end

function toggle-tailscale
  if tailscale status
    sudo systemctl start -v systemd-resolved
    sudo tailscale down
  else
    sudo tailscale up
    sudo systemctl stop -v systemd-resolved
  end
end

function nixpkgs-latest
  for branch in master nixpkgs-unstable nixos-unstable

    set -l api (
      curl -s "https://api.github.com/repos/NixOS/nixpkgs/commits/$branch" |
        jq -r '.commit.committer.date'
    )
    echo -e $branch (date -d $api +"%d %b %Y - %H:%M")
  end | column -t -R 1 -S 1
end

function notify-pkgs
  set -l result (nixpkgs-latest)
  notify-send --expire-time 20000 --print-id nixpkgs "$result"
end

atuin  init fish | source
zoxide init fish | source
