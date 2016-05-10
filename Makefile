
.PHONY: all clean

all: ./document.pdf ./Makefile

./document.pdf: ./tmp/out.pdf
	cp ./tmp/out.pdf ./document.pdf

./tmp/:
	mkdir tmp

./tmp/mkdn.tex: ./tmp/
	echo -n > ./tmp/mkdn.tex
	pandoc ./text/*.mkdn -RS -o ./tmp/mkdn.tex -f markdown -t latex

./tmp/out.tex: ./info/author.tex ./info/style.tex ./info/packages.tex ./tmp/mkdn.tex ./tmp/abstract.tex
	echo \\\\documentclass[a4paper,11pt,notitlepage]{article} > ./tmp/out.tex
	cat ./info/packages.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./info/author.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./info/style.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./src/*.tex 1>> ./tmp/out.tex 2>/dev/null || true
	echo \\\\begin{document} >> ./tmp/out.tex
	echo \\\maketitle >> ./tmp/out.tex
	cat ./tmp/abstract.tex 1>> ./tmp/out.tex 2>/dev/null || true
	echo \\\\tableofcontents >> ./tmp/out.tex
	echo \\\\newpage >> ./tmp/out.tex
	cat ./tmp/mkdn.tex >> ./tmp/out.tex 
	echo \\\\newpage >> ./tmp/out.tex
	echo \\\\printbibliography >> ./tmp/out.tex
	echo \\\\printindex >> ./tmp/out.tex
	echo \\\\end{document} >> ./tmp/out.tex

./tmp/out.bbl: ./tmp/out.bcf
	cd ./tmp/ && biber out

./tmp/out.ind: ./tmp/out.idx
	cd ./tmp/ && makeindex out

./tmp/out.bcf: ./tmp/bibliography.bib ./tmp/out.aux
./tmp/out.idx: ./tmp/out.aux

./tmp/out.aux: ./tmp/out.tex
	cd ./tmp/ && xelatex out.tex 1>/dev/null 2>/dev/null

./tmp/out.pdf: ./tmp/out.tex ./tmp/out.bbl ./tmp/out.ind
	cd ./tmp/ && xelatex out.tex 1>/dev/null 2>/dev/null
	cd ./tmp/ && xelatex out.tex

./tmp/bibliography.bib:
	echo -n > ./tmp/bibliography.bib
	cat ./info/*.bib > ./tmp/bibliography.bib || true

./tmp/abstract.tex: $(ABSTRACT)
	echo -n > ./tmp/abstract.tex
	test -f ./info/abstract.mkdn && echo \\\\begin{abstract} > ./tmp/abstract.tex || true
	test -f ./info/abstract.mkdn && pandoc ./info/abstract.mkdn -RS -o -f markdown -t latex >> ./tmp/abstract.tex || true
	test -f ./info/abstract.mkdn && echo \\\\end{abstract}  >> ./tmp/abstract.tex || true

clean:
	rm -f ./tmp/*
	rm -f ./document.pdf

