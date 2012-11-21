PROJECT='iuf-rulebook'

SRCDIR='src'
OUTDIR='out'
PODIR='po'
TRANSLATEDDIR='translated'
PO4ACHARSETS=-M Utf-8 -L Utf-8

LATEXARGS= -output-directory=$(OUTDIR) -interaction=nonstopmode -file-line-error


#TRANSLATED:=`for file in `find $(TRANSLATEDDIR)/*.tex`; do basename $(OUTDIR)/$file | sed "s/tex/pdf/"; done`


all: master translated


master:
	mkdir -p $(OUTDIR)
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log && \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log; \

translated: update-translation
	mkdir -p $(TRANSLATEDDIR)
	mkdir -p $(OUTDIR)
	for file in `find $(TRANSLATEDDIR)/*.tex`; do \
		TEXDIR=$(TRANSLATEDDIR); \
		TEXFILE=`basename $$file`; \
		#echo $$TEXDIR/$$TEXFILE: \
		TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $$TEXDIR/$$TEXFILE 2>&1 | tee $(OUTDIR)/$$TEXFILE.log && \
		TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) $$TEXDIR/$$TEXFILE 2>&1 | tee $(OUTDIR)/$$TEXFILE.log; \
	done

update-translation: translation-template
	../pootle/manage.py sync_stores
	TEXINPUTS=$(SRCDIR): po4a $(PO4ACHARSETS) po4a.cfg
	chmod 0777 po/*
	../pootle/manage.py update_stores

translation-template: $(TRANSLATEDDIR) $(PODIR)
	TEXINPUTS=$(SRCDIR): po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex $(PO4ACHARSETS) -p $(PODIR)/template.pot



$(OUTDIR):

$(TRANSLATEDDIR):

$(PODIR):
	mkdir -p $(PODIR)



#init-translation-%: transdir translation-template
#	cp $(TRANSDIR)/$(PROJECT).pot $(TRANSDIR)/$(PROJECT)-$*.po

#update-translation-%: transdir
#	TEXINPUTS=$(SRCDIR): po4a-updatepo -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po

#translate-%: transdir
#	TEXINPUTS=$(SRCDIR): po4a-translate -f latex -m $(SRCDIR)/$(PROJECT).tex -p $(TRANSDIR)/$(PROJECT)-$*.po -l $(TRANSDIR)/$(PROJECT)-$*.tex -k 0



clean:
	rm -rf $(OUTDIR)/*
	rm -rf $(TRANSLATEDDIR)

