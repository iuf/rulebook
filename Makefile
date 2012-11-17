PROJECT='iuf-rulebook'
SRCDIR='src'
OUTDIR='out'
TRANSDIR='translations'
LATEXARGS= -halt-on-error -file-line-error -shell-escape -interaction=nonstopmode -output-directory=$(OUTDIR)

all: original

original: $(PROJECT)-pdf

translation-%: translate-% $(TRANSDIR)/$(PROJECT)-%-pdf
	



%-pdf:
	mkdir -p $(OUTDIR)
	pdflatex $(LATEXARGS) -draftmode $(SRCDIR)/$*.tex && \
	pdflatex $(LATEXARGS) $(SRCDIR)/$*.tex


transdir:
	mkdir -p $(TRANSDIR)

init-translation-%: transdir translation-template
	cp $(TRANSDIR)/$(PROJECT).pot $(TRANSDIR)/$(PROJECT)-$*.po

update-translation-%: transdir
	po4a-updatepo -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po

translation-template: transdir
	po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex -L Utf-8 -p $(TRANSDIR)/$(PROJECT).pot

translate-%: transdir
	po4a-translate -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po -l $(TRANSDIR)/$(PROJECT)-$*.tex -k 0



clean:
	rm -rf $(OUTDIR)
	rm -rf $(TRANSDIR)

