# Nix{,OS,pkgs} Cheatsheet

So I don't have to open the Nixpkgs manual all the time.

## Phases

|||
|---|---|
| 1. **unpackPhase** | `extract source.tar.gz -> /nix/store/...-source`
| 2. **patchPhase** | `apply .patch'es to source`
| 3. **configurePhase** | `run ./configure`
| 4. **buildPhase** | `custom build script required, builds in $TMPDIR`
| 5. **checkPhase** | `run tests, disabled by default (set doCheck = true;)`
| 6. **installPhase** | `move built content to $out`
| 7. **fixupPhase** | `does many fixes by default to make package Nix-compatible`
| 8. **installCheckPhase** | `tests for compiled / final content`
| 9. **distPhase** | `create tarball from $out`
|

## tmpfiles.d

| Type  | Path                               | Argument            | Mode | User | Group | Age         |
|---|---|---|---|---|---|---|
| f±    | /file/to/create{,-or-truncate}     | content             | mode | user | group | -           |
| w±    | /file/to/{write,append}-to         | content             | -    | -    | -     | -           |
| d     | /directory/to/create-and-clean-up  | -                   | mode | user | group | cleanup-age |
| D     | /directory/to/create-and-remove    | -                   | mode | user | group | cleanup-age |
| e     | /directory/to/clean-up             | -                   | mode | user | group | cleanup-age |
| v     | /subvolume-or-directory/to-create  | -                   | mode | user | group | cleanup-age |
| L±    | /symlink/to/{,re}create            | symlink/target/path | -    | -    | -     | -           |
| C±    | /target/to/create                  | /source/to/copy     | -    | -    | -     | cleanup-age |
| Xx    | /path/or/glob/to/ignore            | -                   | -    | -    | -     | cleanup-age |
| rR    | /path/or/glob/to/remove            | -                   | -    | -    | -     | -           |
| zZ    | /path/or/glob/to/adjust/mode       | -                   | mode | user | group | -           |
| tT    | /path/or/glob/to/set/xattrs        | xattrs              | -    | -    | -     | -           |
| hH    | /path/or/glob/to/set/attrs         | file attrs          | -    | -    | -     | -           |
| aA±   | /path/or/glob/to/{set,append}/acls | POSIX ACLs          | -    | -    | -     | -           |


###


- capital letter for recursive. Yes Xx is reversed.
- ± means use plus for second variant in {}.
- ! after letter means only run on boot.
