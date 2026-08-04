#!/usr/bin/env bash

set -euo pipefail
shopt -s extglob

pushd ~/.local/share/Steam || exit 1

touch .steam-enable-steamrt64-client

paths=(
	# bootstrap.tar.*z
	ThirdPartyLegalNotices*
	# package/ ???
	"steamrt64/locales/!(en-US).pak"
	ubuntu12_32/steam-runtime.old
	ubuntu12_32/steam-runtime.tar.*z
	"ubuntu12_64/locales/!(en-US).pak"

	# ubuntu12_32 # steamrt64 only when?
)

for path in "${paths[@]}"; do
	# shellcheck disable=SC2086
	rm -rfv $path
done

rtcs=(
	steamrt64/pv-runtime/steam-runtime-steamrt/steamrt3c_platform_*
)
# leave the last one (luckily sorted by date in name)
unset "rtcs[-1]"
rm -rv "${rtcs[@]}" || true
