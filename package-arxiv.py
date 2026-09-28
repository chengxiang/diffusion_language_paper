#!/usr/bin/env python3
"""Package the flattened arXiv manuscript after `make arxiv`.

Only the manuscript, bibliography, and referenced figures enter the upload.
Generated packages stay under the ignored build/ directory.
"""

from pathlib import Path
import re
import shutil
import tempfile
import zipfile


def main():
    root = Path(__file__).resolve().parent
    source = root / "main_arxiv.tex"
    text = source.read_text()
    bibliography = root / "build/main_arxiv.bbl"
    if not bibliography.is_file() or bibliography.stat().st_mtime < source.stat().st_mtime:
        raise SystemExit("Build the current manuscript first: make arxiv")
    if re.search(r"\\(?:input|include)\s*\{", text):
        raise SystemExit("The manuscript is no longer flattened; include its new dependencies before packaging.")

    assets = re.findall(r"\\includegraphics(?:\[[^]]*\])?\{([^}]+)\}", text)
    bibs = [name.strip() + ".bib" for group in re.findall(r"\\bibliography\{([^}]+)\}", text)
            for name in group.split(",")]
    files = {"main_arxiv.tex": source, "main_arxiv.bbl": bibliography}
    for name in sorted(set(assets + bibs)):
        path = root / name
        if Path(name).is_absolute() or ".." in Path(name).parts or not path.is_file():
            raise SystemExit(f"Missing or nonlocal submission dependency: {name}")
        files[name] = path

    target = root / "build/arxiv_submission"
    archive = root / "build/arxiv_submission.zip"
    # Assemble separately so a missing input cannot leave a partial upload folder.
    with tempfile.TemporaryDirectory(prefix="arxiv-package-", dir=root / "build") as tmp:
        staging = Path(tmp) / "source"
        for name, path in files.items():
            dest = staging / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
        staged_zip = Path(tmp) / "submission.zip"
        with zipfile.ZipFile(staged_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
            for name in sorted(files):
                z.write(staging / name, arcname=name)
        if target.exists():
            shutil.rmtree(target)
        shutil.move(str(staging), target)
        staged_zip.replace(archive)

    print(f"Source folder: {target}")
    print(f"Upload ZIP: {archive} ({archive.stat().st_size:,} bytes)")
    print(f"{len(files)} files: manuscript, BibTeX source, compiled bibliography, and {len(set(assets))} figures.")


if __name__ == "__main__":
    main()
