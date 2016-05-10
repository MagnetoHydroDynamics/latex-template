
.PHONY: all clean

all: ./document.pdf ./Makefile

./document.pdf: ./tmp/out.pdf
	cp ./tmp/out.pdf ./document.pdf

./tmp/mkdn.tex:
	echo -n > ./tmp/mkdn.tex
	pandoc ./text/*.mkdn -RS -o ./tmp/mkdn.tex -f markdown -t latex

./tmp/out.tex: ./info/author.tex ./info/layout.tex ./info/packages.tex ./tmp/mkdn.tex ./tmp/abstract.tex
	echo \\\\documentclass[a4paper,11pt]{report} > ./tmp/out.tex
	cat ./info/packages.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./info/author.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./info/abstract.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./info/layout.tex 1>> ./tmp/out.tex 2>/dev/null || true
	cat ./incl/*.tex 1>> ./tmp/out.tex 2>/dev/null || true
	echo \\\\bibliography{bibliography.bib} >> ./tmp/out.tex
	echo \\\\begin{document} >> ./tmp/out.tex
	echo \\\maketitle >> ./tmp/out.tex
	echo \\\\tableofcontents >> ./tmp/out.tex
	echo \\\\newpage >> ./tmp/out.tex
	cat ./tmp/mkdn.tex >> ./tmp/out.tex 
	echo \\\\newpage >> ./tmp/out.tex
	echo \\\\printbibliography >> ./tmp/out.tex
	echo \\\\printindex >> ./tmp/out.tex
	echo \\\\end{document} >> ./tmp/out.tex

./tmp/out.bbl: ./tmp/out.bcf
	cd ./tmp/ && bibtex out

./tmp/out.ind: ./tmp/out.idx
	cd ./tmp/ && makeindex out

./tmp/out.bcf: ./tmp/bibliography.bib ./tmp/out.aux
./tmp/out.idx: ./tmp/out.aux

./tmp/out.aux: ./tmp/out.tex
	cd ./tmp/ && xelatex out.tex

./tmp/out.pdf: ./tmp/out.tex ./tmp/out.bbl ./tmp/out.ind
	cd ./tmp/ && xelatex out.tex


./tmp/bibliography.bib:
	echo -n > ./tmp/bibliography.bib
	cat ./info/*.bib > ./tmp/bibliography.bib || true

./tmp/abstract.tex: $(ABSTRACT)
	touch ./tmp/abstract.tex
	test -f ./info/abstract.mkdn && echo '\abstract{%' > ./tmp/abstract.tex || true
	test -f ./info/abstract.mknd && pandoc ./info/abstract.mkdn -RS -o -f markdown -t latex >> ./tmp/abstract.tex || true
	test -f ./info/abstract.mkdn && echo "%\n}%" >> ./tmp/abstract.tex || true

clean:
	rm -f ./tmp/*
	rm -f ./document.pdf

