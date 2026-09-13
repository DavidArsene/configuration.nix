# My configuration.nix

This is my take on the whole NixOS thing. Many configs are half-done, but some packages or modules could be used
directly.

### Usage

`./justfile -l` (or `just` if installed)

### Setup for new machine (mostly for me since I always forget):

First, boot the NixOS live installer via [netboot.xyz](https://netboot.xyz)

```bash
nix-shell -p gitMinimal
git clone https://github.com/DavidArsene/configuration.nix

mkdir configuration.nix/hosts/$NEW_HOSTNAME && cd $_
echo '{ ... }: { system.stateVersion = "26.11"; }' > default.nix
nixos-generate-config --show-hardware-config | tee hardware.nix

# Add new host to flake.nix
cd ../..
nano flake.nix

NIX_CONFIG="experimental-features = pipe-operators" nixos-install ...
```

**No warranties or support provided.**
