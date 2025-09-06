#!/usr/bin/env bash

set -euo pipefail


out+="/lib/firmware"
install -d "$out"


for path in @blobs@; do
    install -d "$out/$(dirname "$path")"

    # `read` splits input by IFS: "Link: path/to/pretty.bin -> from/blob.bin"
    grep -E "^(File|RawFile|Link): $path" ./WHENCE | while read kind blob _ src; do
        case "$kind" in

            File:)
                echo "compressing $blob.zst"
                zstd --compress --stdout "$blob" > "$out/$blob.zst"
                ;; # --quiet?

            RawFile:)
                echo "compression will be skipped for $blob"
                mv "$blob" "$out/$blob"
                ;;

            Link:)
				# For the same example, the path will have
				# the directory structure prepended: "path/to/from/blob.bin"

				link="$blob"
                directory="$out/$(dirname "$link")"
                install -d "$directory"

                rel="$(cd "$directory" && realpath -m -s "$src")"

                if test -e "$rel"; then
                    echo "creating link $link -> $src"
                    ln -s "$src" "$out/$link"
                else
                    echo "creating link $link.zst -> $src.zst"
                    ln -s "$src.zst" "$out/$link.zst"
                fi
                ;;

            *) return 1 ;;
        esac
    done
done


# Verify no broken symlinks
if test "$(find "$out" -xtype l | wc -l)" -ne 0 ; then
    err "Broken symlinks found:\n$(find "$out" -xtype l)"
fi


echo "Finding duplicate files"
rdfind -makesymlinks true -makeresultsfile true "$out" >/dev/null

grep "DUPTYPE_WITHIN_SAME_TREE" results.txt | grep -o "$out.*" | while read -r l; do
	target="$(realpath "$l")"
	echo "Correcting path for $l"
	ln --force --symbolic --relative "$target" "$l"
done

rm results.txt
