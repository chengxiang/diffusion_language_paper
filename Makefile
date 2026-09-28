.PHONY: pdf arxiv arxiv-source tectonic clean

pdf:
	bash build-paper.sh

arxiv:
	bash build-paper.sh main_arxiv.tex

arxiv-source: arxiv
	python3 package-arxiv.py

tectonic:
	mkdir -p build
	tectonic --keep-logs --outdir build main.tex

clean:
	rm -f build/main.aux build/main.bbl build/main.blg build/main.fdb_latexmk build/main.fls build/main.log build/main.out build/main.synctex.gz build/main.xdv
	rm -f build/main_arxiv.aux build/main_arxiv.bbl build/main_arxiv.blg build/main_arxiv.fdb_latexmk build/main_arxiv.fls build/main_arxiv.log build/main_arxiv.out build/main_arxiv.synctex.gz build/main_arxiv.xdv
