PROJECT='iuf-rulebook'
SRCDIR='src'
OUTDIR='out'
TRANSDIR='translations'
LATEXLOG='latex-log'
LATEXARGS= -output-directory=$(OUTDIR) -interaction=nonstopmode -file-line-error

all: original

original: $(PROJECT)-pdf

translation-%: translate-% $(TRANSDIR)/$(PROJECT)-%-pdf
	



%-pdf:
	mkdir -p $(OUTDIR)
	TEXINPUTS=$(SRCDIR): pdflatex $(LATEXARGS) -draftmode $(SRCDIR)/$*.tex 2>&1 | tee $(OUTDIR)/$(LATEXLOG) && \
	TEXINPUTS=$(SRCDIR): pdflatex $(LATEXARGS) $(SRCDIR)/$*.tex 2>&1 | tee $(OUTDIR)/$(LATEXLOG)


transdir:
	mkdir -p $(TRANSDIR)/templates

init-translation-%: transdir translation-template
	cp $(TRANSDIR)/$(PROJECT).pot $(TRANSDIR)/$(PROJECT)-$*.po

update-translation-%: transdir
	TEXINPUTS=$(SRCDIR): po4a-updatepo -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po

translation-template: transdir
	TEXINPUTS=$(SRCDIR): po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex -L Utf-8 -p $(TRANSDIR)/templates/$(PROJECT).pot

translate-%: transdir
	TEXINPUTS=$(SRCDIR): po4a-translate -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po -l $(TRANSDIR)/$(PROJECT)-$*.tex -k 0



clean:
	rm -rf $(OUTDIR)/*
	rm -rf $(TRANSDIR)/*

