#! /usr/bin/env nix-shell
#! nix-shell -i "just --justfile" -p just nix-output-monitor

set unstable
set lists

overrides := "--override-input " + [
    if path_exists("../nur.nix") { "mypkgs ../nur.nix" },
    if path_exists("../minimal.nix") { "minimal ../minimal.nix" },
]
# if path_exists("../private.nix") { "private ../private.nix" },

dry *args:
    nixos-rebuild dry-build --print-build-logs {{ overrides ++ args }}

export NIXOS_MINIFY_REPLACE_DEPS := "1"
nom_suffix := " --log-format internal-json |& nom --json"
build_args := overrides ++ " --impure --keep-going --sudo --no-reexec --diff"
# host_args := [ "--target-host ", "--build-host ", "--flake .#"]

# [arg("host", long)]
[arg("cmd", pattern="boot|test|switch")]
build cmd *args: # host=[]:
    nixos-rebuild {{ cmd ++ build_args ++ args ++ nom_suffix }}
# {{ if host { host_args + host } }}

alias d := dry
alias r := repl
alias up := update
b *args: (build "boot" args)
t *args: (build "test" args)
s *args: (build "switch" args)

update:
    nix flake update --verbose

repl:
    nixos-rebuild repl
