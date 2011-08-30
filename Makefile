JUNK_FILES=$(FINAL).* *.aux *.log styles/*.aux
SOURCE=book
WEBSITE=$(USER)@learncodethehardway.org:/var/www/learncodethehardway.org
FINAL=book-final

book:
	dexy
	cp Makefile output/
	cp pastie.sty output/
	${MAKE} -C output clean $(FINAL).pdf
	rm -rf output/*.dvi output/*.pdf
	${MAKE} -C output $(FINAL).pdf

draft: $(FINAL).dvi

$(FINAL).dvi:
	cp $(SOURCE).tex $(FINAL).tex
	latex -halt-on-error $(FINAL).tex

html: 
	cd output && htlatex $(FINAL).tex
	cd output && tidy -quiet -ashtml -omit -ic -m $(FINAL).html || true
	
$(FINAL).pdf: $(FINAL).dvi
	dvipdf $(FINAL).dvi

view: $(FINAL).pdf
	evince $(FINAL).pdf

clean:
	rm -rf $(JUNK_FILES)
	find . -name "*.aux" -exec rm {} \;
	rm -rf output

release: clean $(FINAL).pdf draft $(FINAL).pdf sync

sync: book html
	rsync -vz output/$(FINAL).pdf $(WEBSITE)/$(FINAL).pdf
	rsync -vz output/$(FINAL).html $(WEBSITE)/index.html
	rsync -vz output/$(FINAL).css $(WEBSITE)/

