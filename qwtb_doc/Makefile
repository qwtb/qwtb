#pridat vlna

INPUTSOURCE = QWTB_doc

pdf:
	rm -rf $(INPUTSOURCE).log $(INPUTSOURCE).aux $(INPUTSOURCE).toc $(INPUTSOURCE).bbl $(INPUTSOURCE).bbg *.out $(INPUTSOURCE).blg $(INPUTSOURCE)-blx.bib
	rm -rf $(INPUTSOURCE).bcf $(INPUTSOURCE).run.xml $(INPUTSOURCE).tex.blg 
	pdflatex $(INPUTSOURCE).tex
	biber $(INPUTSOURCE)
	pdflatex $(INPUTSOURCE).tex
	pdflatex $(INPUTSOURCE).tex


clean:
	rm -rf $(INPUTSOURCE).log $(INPUTSOURCE).aux $(INPUTSOURCE).toc $(INPUTSOURCE).bbl $(INPUTSOURCE).bbg *.out $(INPUTSOURCE).blg $(INPUTSOURCE)-blx.bib
	rm -rf $(INPUTSOURCE).bcf $(INPUTSOURCE).run.xml $(INPUTSOURCE).tex.blg 

draft:
	pdflatex $(INPUTSOURCE).tex

bib:
	biber $(INPUTSOURCE)
