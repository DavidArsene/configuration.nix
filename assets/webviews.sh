#!/usr/bin/env bash

cd ~ || exit 1

codeCaches=($(find . -type d -name "Code Cache" 2> /dev/null))
webViewRoots=$(basename -a ${codeCaches[@]})

echo "Found WebView roots:"
for root in $webViewRoots; do
	echo "$root"
done
