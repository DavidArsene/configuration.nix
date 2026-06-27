function alienate
    if test (count $argv) -eq 0
        echo "Usage: alienate <executable> [args...]" >&2
        return 1
    end

    set -l target $argv[1]

    set -l notfounds (ldd $target | rg 'not found' | command sd '=> not found|\s+' '')
    echo "Missing libraries: $notfounds"
    # not reliable
    # set -l unuseds (ldd -u $target | rg '\.so' | command sd '\s' '')

    set -a notfounds "libGL.so"

    set -l packages
    for lib in $notfounds

        set -l pkg (
          nix-locate --whole-name --minimal lib/$lib |
          rg -v 'python\d+Packages' |
          , fzf -1 --style=minimal --prompt="Select package for $lib: "
        )
        # TODO: no comma

        if contains -- $pkg $packages
            continue
        end

        set -a packages $pkg
        echo "Using $pkg for $lib"
    end

    echo "Found packages: $packages"
    echo "Building derivations..."

    set -l padthes (nix build --no-link --print-out-paths nixpkgs#{$packages})

    echo "Running $target with updated library paths"
    NIX_LD_LIBRARY_PATH=(echo {$padthes}/lib | tr ' ' ':') $argv
end
