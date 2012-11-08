PROJECT='iuf-rulebook'
OUTDIR='0_out'
TRANSDIR='0_translations'
LATEXARGS= -halt-on-error -file-line-error -shell-escape -interaction=nonstopmode -output-directory=$(OUTDIR)

all: original

original: $(PROJECT)-pdf

translation-%: translate-% $(TRANSDIR)/$(PROJECT)-%-pdf
	



%-pdf:
	mkdir -p $(OUTDIR)
	pdflatex $(LATEXARGS) -draftmode $*.tex && \
	pdflatex $(LATEXARGS) $*.tex


transdir:
	mkdir -p $(TRANSDIR)

init-translation-%: transdir translation-template
	cp $(TRANSDIR)/$(PROJECT).pot $(TRANSDIR)/$(PROJECT)-$*.po

update-translation-%: transdir
	po4a-updatepo -f latex -m $(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po

translation-template: transdir
	po4a-gettextize -f latex -m $(PROJECT).tex -L Utf-8 -p $(TRANSDIR)/$(PROJECT).pot

translate-%: transdir
	po4a-translate -f latex -m $(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po -l $(TRANSDIR)/$(PROJECT)-$*.tex -k 0



clean:
	rm -rf $(OUTDIR)
	rm -rf $(TRANSDIR)

