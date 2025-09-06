# Alternative to fetchzip that uses 7z to unpack archives
# and allows easy customization of the unpacking process.

{
  lib,
  fetchurl,
  repoRevToNameMaybe,
  p7zip,
}:

{
  urls ? [ ],
  url ? builtins.head urls,
  name ? repoRevToNameMaybe url null "unpacked",
  postFetch ? "",

  # Optionally move the contents of the unpacked tree up one level.
  stripRoot ? true,

  include ? [ ],
  exclude ? [ ],

  recurse ? false,
  recurseWildcardsOnly ? false,

  listWhatTemp ? "",

  # the rest are given to fetchurl as is
  ...
}@args:

let 
  recurse' = "-r" + (if recurse then (if recurseWildcardsOnly then "0" else "") else "-");
  include' = lib.concatMapStrings (s: " -i!" + s) include;
  exclude' = lib.concatMapStrings (s: " -x!" + s) exclude;
in

fetchurl (
  {
    inherit name;
    recursiveHash = true;

    downloadToTemp = true;

    postFetch = ''
      unpackDir="$TMPDIR/unpack"
      mkdir "$unpackDir"
      cd "$unpackDir"

      renamed="$TMPDIR/${baseNameOf url}"
      mv "$downloadedFile" "$renamed"
      
      ${p7zip}/bin/7z x "$renamed" -o"$unpackDir" \
        ${recurse'} \
        ${listWhatTemp} \
        ${include'} \
        ${exclude'} \
        -y # TODO: right?

      chmod -R +w "$unpackDir"
    ''
    + (
      if stripRoot then
        ''
          if [ $(ls -A "$unpackDir" | wc -l) != 1 ]; then
            echo "error: zip file must contain a single file or directory."
            echo "hint: Pass stripRoot=false; to assume flat list of files."
            exit 1
          fi
          fn=$(cd "$unpackDir" && ls -A)
          if [ -f "$unpackDir/$fn" ]; then
            mkdir $out
          fi
          mv "$unpackDir/$fn" "$out"
        ''
      else
        ''
          mv "$unpackDir" "$out"
        ''
    )
    + ''
      ${postFetch}
      chmod 755 "$out"
    '';
    # ^ Remove non-owner write permissions
    # Fixes https://github.com/NixOS/nixpkgs/issues/38649
  }
  // removeAttrs args [
    "include"
    "exclude"
    "recurse"
    "recurseWildcardsOnly"
    "listWhatTemp"
    "stripRoot"
    "postFetch"
  ]
)
