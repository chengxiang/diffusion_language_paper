#!/usr/bin/env bash
# Build with the DCC-local Tectonic installation, or an installed TeX toolchain.
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$paper_dir"
mkdir -p build

if [[ -x "$paper_dir/.local/bin/tectonic" ]]; then
    mkdir -p "$paper_dir/.local/cache"
    export XDG_CACHE_HOME="$paper_dir/.local/cache"
    paper_compiler="$paper_dir/.local/bin/tectonic"
elif command -v tectonic >/dev/null 2>&1; then
    paper_compiler="$(command -v tectonic)"
elif command -v latexmk >/dev/null 2>&1; then
    exec latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error -outdir=build main.tex
else
    printf '%s\n' 'No TeX compiler found. Install Tectonic or a TeX distribution with latexmk.' >&2
    exit 127
fi

exec "$paper_compiler" --synctex --keep-logs --keep-intermediates --outdir build main.tex
