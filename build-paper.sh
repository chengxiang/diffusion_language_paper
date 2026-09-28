#!/usr/bin/env bash
# Build with the DCC-local Tectonic installation, or an installed TeX toolchain.
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$paper_dir"
paper_source="${1:-main.tex}"
if [[ $# -gt 2 || "$paper_source" != *.tex || ! -f "$paper_source" ]]; then
    printf '%s\n' 'Usage: bash build-paper.sh [existing-document.tex [output-directory]]' >&2
    exit 2
fi
paper_source_dir="$(cd -- "$(dirname -- "$paper_source")" && pwd)"
paper_source_name="$(basename -- "$paper_source")"
paper_output_dir="${2:-$paper_dir/build}"
mkdir -p -- "$paper_output_dir"
paper_output_dir="$(cd -- "$paper_output_dir" && pwd)"

if [[ -x "$paper_dir/.local/bin/tectonic" ]]; then
    mkdir -p "$paper_dir/.local/cache"
    export XDG_CACHE_HOME="$paper_dir/.local/cache"
    paper_compiler="$paper_dir/.local/bin/tectonic"
elif command -v tectonic >/dev/null 2>&1; then
    paper_compiler="$(command -v tectonic)"
elif command -v latexmk >/dev/null 2>&1; then
    cd -- "$paper_source_dir"
    exec latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error "-outdir=$paper_output_dir" "$paper_source_name"
else
    printf '%s\n' 'No TeX compiler found. Install Tectonic or a TeX distribution with latexmk.' >&2
    exit 127
fi

# Relative figure and bibliography paths belong to the selected document,
# including when it is the independently packaged arXiv source.
cd -- "$paper_source_dir"
exec "$paper_compiler" --synctex --keep-logs --keep-intermediates --outdir "$paper_output_dir" "$paper_source_name"
