#!/bin/bash
dirs="dream cerebri"

for dir in $dirs
do
	echo $dir
	pushd $dir
	docker compose build && docker compose push
	popd
done
