OUTPUTDIR='0_out'
LATEXARGS= -halt-on-error -file-line-error -shell-escape -interaction=nonstopmode -output-directory=$(OUTPUTDIR)

all:
	mkdir -p $(OUTPUTDIR)
	pdflatex $(LATEXARGS) -draftmode iuf-rulebook.tex && \
	pdflatex $(LATEXARGS) iuf-rulebook.tex


clean:
	rm -rf $(OUTPUTDIR) 
