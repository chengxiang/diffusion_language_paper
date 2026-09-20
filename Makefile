.PHONY: pdf tectonic clean

pdf:
	bash build-paper.sh

tectonic:
	mkdir -p build
	tectonic --keep-logs --outdir build main.tex

clean:
	rm -f build/main.aux build/main.bbl build/main.blg build/main.fdb_latexmk build/main.fls build/main.log build/main.out build/main.synctex.gz build/main.xdv
