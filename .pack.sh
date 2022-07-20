#!/usr/bin/env bash

tar -caf nautilus-bridge-tools-"${1?Missing argument: version}".tar.gz lib README.md LICENSE $(find . -maxdepth 1 -executable -type f)

