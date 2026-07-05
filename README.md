# My configuration.nix

This is my take on the whole NixOS thing.
Many configs are half-done, but some packages or modules could be used directly.

### Setup for new machine (mostly for me since I always forget):

First, boot the NixOS live installer via [netboot.xyz](https://netboot.xyz)

```bash
nix --extra-experimental-commands "nix-command flakes" profile add github:NixOS/nixpkgs#gitMinimal
git clone https://github.com/DavidArsene/configuration.nix
cd configuration.nix
# Create new host: add in flake.nix and create a subdir in hosts/
nix-generate-config --show-hardware-config | tee hosts/MY_NEW_HOSTNAME/hardware.nix
NIX_CONFIG="experimental-features = pipe-operators" nixos-install
```

**No warranties or support provided.**

Pull requests are welcome.
