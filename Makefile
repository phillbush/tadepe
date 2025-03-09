.SUFFIXES: .pcf .bdf

FNTS = tadepe-16b.pcf tadepe-32b.pcf tadepe-64b.pcf
SRCS = letters-16b.bdf
GENS = ${FNTS} ${FNTS:.pcf=.bdf} braille-16b.bdf
FONTS_DIR = ${HOME}/.fonts

all: ${FNTS}

.bdf.pcf:
	bdftopcf -t -o $@ $<

braille-16b.bdf: tools/braille.awk
	./tools/braille.awk >$@

tadepe-16b.bdf: tools/merge.awk letters-16b.bdf diacritics-16b.bdf braille-16b.bdf
	./tools/merge.awk\
	letters-16b.bdf diacritics-16b.bdf braille-16b.bdf\
	>$@

tadepe-32b.bdf: tools/enlarge.awk tadepe-16b.bdf
	awk -f ./tools/enlarge.awk <tadepe-16b.bdf >tadepe-32b.bdf

tadepe-64b.bdf: tools/enlarge.awk tadepe-32b.bdf
	awk -f ./tools/enlarge.awk <tadepe-32b.bdf >tadepe-64b.bdf

edit:
	gbdfed ${SRCS} &

install: ${FNTS}
	install -m 644 ${FNTS} ${FONTS_DIR}
	cd ${FONTS_DIR} ; mkfontdir ; mkfontscale ; xset fp rehash

clean:
	-rm -f ${GENS}

.PHONY: all edit install clean
