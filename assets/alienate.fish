function __alienate_pkg_for_lib
    set -l lib $argv[1]

    # Check cache first
    for entry in $__alienate_cache
        if string match -q "$lib=*" -- $entry
            set -l cached_pkg (string split '=' $entry)[2]

            echo "Using cached package for $lib: $cached_pkg"
            return $cached_pkg
        end
    end

    set -l pkg (
          nix-locate --whole-name --minimal lib/$lib |
          rg -v 'python\d+Packages' |
          fzf -1 --style=minimal --prompt="Choose package for $lib: "
        )

    # update cache
    # @fish-lsp-disable-next-line 2003
    set --universal --append __alienate_cache "$lib=$pkg"

    echo "Using $pkg for $lib"
    return $pkg

end

# @fish-lsp-disable-next-line 4004
function alienate
    if test (count $argv) -eq 0
        echo "Usage: alienate <executable> [args...]" >&2
        return 1
    end

    set -l target $argv[1]

    set -l notfounds (ldd $target | rg 'not found' | sd '=> not found|\s+' '')
    echo "Missing libraries: $notfounds"
    # not reliable
    # set -l unuseds (ldd -u $target | rg '\.so' | sd '\s' '')

    # usually not found by ldd
    set --append notfounds "libGL.so"

    for lib in $notfounds

        set -l pkg (__alienate_pkg_for_lib $lib)

        if contains -- $pkg $packages
            continue
        end

        set --function --append packages $pkg
    end

    echo "Found needed packages: $packages"
    echo "Building derivations..."

    set -l padthes (nix build --no-link --print-out-paths nixpkgs\#{$packages})

    echo "Running $target with updated library paths"
    NIX_LD_LIBRARY_PATH=(echo {$padthes}/lib | tr ' ' ':') $argv
end
