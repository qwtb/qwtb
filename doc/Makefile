#pridat vlna

INPUTSOURCE = QWTB-Tb_doc

pdf:
	rm -rf $(INPUTSOURCE).log $(INPUTSOURCE).aux $(INPUTSOURCE).toc $(INPUTSOURCE).bbl $(INPUTSOURCE).bbg *.out $(INPUTSOURCE).blg $(INPUTSOURCE)-blx.bib
	rm -rf $(INPUTSOURCE).bcf $(INPUTSOURCE).run.xml $(INPUTSOURCE).tex.blg 
	pdflatex $(INPUTSOURCE).tex
	biber $(INPUTSOURCE)
	pdflatex $(INPUTSOURCE).tex
	pdflatex $(INPUTSOURCE).tex
	rm -rf QWTB-Alg_doc.log QWTB-Alg_doc.aux QWTB-Alg_doc.toc QWTB-Alg_doc.bbl QWTB-Alg_doc.bbg *.out QWTB-Alg_doc.blg QWTB-Alg_doc-blx.bib
	rm -rf QWTB-Alg_doc.bcf QWTB-Alg_doc.run.xml QWTB-Alg_doc.tex.blg 
	pdflatex QWTB-Alg_doc.tex
	biber QWTB-Alg_doc
	pdflatex QWTB-Alg_doc.tex
	pdflatex QWTB-Alg_doc.tex


clean:
	rm -rf $(INPUTSOURCE).log $(INPUTSOURCE).aux $(INPUTSOURCE).toc $(INPUTSOURCE).bbl $(INPUTSOURCE).bbg *.out $(INPUTSOURCE).blg $(INPUTSOURCE)-blx.bib
	rm -rf $(INPUTSOURCE).bcf $(INPUTSOURCE).run.xml $(INPUTSOURCE).tex.blg 
	rm -rf QWTB-Alg_doc.log QWTB-Alg_doc.aux QWTB-Alg_doc.toc QWTB-Alg_doc.bbl QWTB-Alg_doc.bbg *.out QWTB-Alg_doc.blg QWTB-Alg_doc-blx.bib
	rm -rf QWTB-Alg_doc.bcf QWTB-Alg_doc.run.xml QWTB-Alg_doc.tex.blg 

draft:
	pdflatex $(INPUTSOURCE).tex

bib:
	biber $(INPUTSOURCE)
	biber QWTB-Alg_doc
