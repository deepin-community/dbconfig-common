# example Makefile for viewing/editing an encrypted file
TARGETS := dbconfig-common dbapp-policy

#EXTENSIONS := xml dvi html info ps pdf txt tov tex
EXTENSIONS := html ps pdf txt

#default: xml dvi html info ps pdf txt tov tex
default: ${EXTENSIONS}

xml:	${foreach t,${TARGETS},${t}.xml}
dvi:	${foreach t,${TARGETS},${t}.dvi}
html:	${foreach t,${TARGETS},${t}.html}
info:	${foreach t,${TARGETS},${t}.info}
ps:	${foreach t,${TARGETS},${t}.ps}
pdf:	${foreach t,${TARGETS},${t}.pdf}
txt:	${foreach t,${TARGETS},${t}.txt}
tov:	${foreach t,${TARGETS},${t}.tov}
tex:	${foreach t,${TARGETS},${t}.tex}

clean:	${foreach f, ${TARGETS}, ${f}-clean}
	
%-clean:
	rm -rf ${foreach ext,xml dvi html info ps pdf txt tov tex tpt, ${@:-clean=}.${ext}}

%.xml:	%.sgml
	debiandoc2docbookxml ${@:.xml=.sgml}

%.dvi:	%.sgml
	debiandoc2dvi ${@:.dvi=.sgml}

%.html:	%.sgml
	debiandoc2html ${@:.html=.sgml}

%.info:	%.sgml
	debiandoc2info ${@:.info=.sgml}

%.tex:	%.sgml
	debiandoc2latex ${@:.tex=.sgml}

%.ps:	%.sgml
	debiandoc2ps ${@:.ps=.sgml}
	rm -f head.tmp body.tmp

%.pdf:	%.sgml
	debiandoc2pdf ${@:.pdf=.sgml}
	rm -f ${@:.pdf=.tpt}

%.txt:	%.sgml
	debiandoc2text ${@:.txt=.sgml}

%.tov:	%.sgml
	debiandoc2textov ${@:.tov=.sgml}
