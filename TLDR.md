# Nix{,OS,pkgs} et al. Cheatsheet

For things I need to look up every time.

## stdenv

> Overlays are Nix functions which accept two arguments,
> conventionally called either `final` and `prev` in newer code or
`self` and `super` in older code, and return a set of packages.

### Phases

| № | Phase        | Summary                                                |
|---|--------------|--------------------------------------------------------|
| 1 | **unpack**   | extract `source.tar.gz` to `/nix/store/...-source`     |
| 2 | **patch**    | apply `.patch`es to source                             |
| 3 | configure    | run `./configure`                                      |
| 4 | **build**    | optional custom build script, builds in `$TMPDIR`      |
| 5 | check        | run tests, disabled by default (set `doCheck = true;`) |
| 6 | **install**  | move built content to `$out`                           |
| 7 | **fixup**    | small fixes by default to make package Nix-compatible  |
| 8 | installCheck | tests for compiled / final content                     |
| 9 | dist         | create tarball from `$out`                             |

## tmpfiles.d

| Type | Path                               | Argument            | Mode | User | Group | Age         |
|------|------------------------------------|---------------------|------|------|-------|-------------|
| f±   | /file/to/create{,-or-truncate}     | content             | mode | user | group | -           |
| w±   | /file/to/{write,append}-to         | content             | -    | -    | -     | -           |
| d    | /directory/to/create-and-clean-up  | -                   | mode | user | group | cleanup-age |
| D    | /directory/to/create-and-remove    | -                   | mode | user | group | cleanup-age |
| e    | /directory/to/clean-up             | -                   | mode | user | group | cleanup-age |
| v    | /subvolume-or-directory/to-create  | -                   | mode | user | group | cleanup-age |
| L±   | /symlink/to/{,re}create            | symlink/target/path | -    | -    | -     | -           |
| C±   | /target/to/create                  | /source/to/copy     | -    | -    | -     | cleanup-age |
| Xx   | /path/or/glob/to/ignore            | -                   | -    | -    | -     | cleanup-age |
| rR   | /path/or/glob/to/remove            | -                   | -    | -    | -     | -           |
| zZ   | /path/or/glob/to/adjust/mode       | -                   | mode | user | group | -           |
| tT   | /path/or/glob/to/set/xattrs        | xattrs              | -    | -    | -     | -           |
| hH   | /path/or/glob/to/set/attrs         | file attrs          | -    | -    | -     | -           |
| aA±  | /path/or/glob/to/{set,append}/acls | POSIX ACLs          | -    | -    | -     | -           |

###

- capital letter for recursive. Yes Xx is reversed.
- ± means use plus for second variant in {}.
- ! after letter means only run on boot.
