.SUFFIXES: .pcf .bdf

FNTS = tadepe-16b.pcf
SRCS = ${FNTS:.pcf=.bdf}
FONTS_DIR = ${HOME}/.fonts

all: ${FNTS}

.bdf.pcf:
	bdftopcf -t -o $@ $<

edit:
	gbdfed ${SRCS} &

install: ${FNTS}
	install -m 644 ${FNTS} ${FONTS_DIR}
	cd ${FONTS_DIR} ; mkfontdir ; mkfontscale ; xset fp rehash

clean:
	-rm -f ${FNTS}

.PHONY: all edit install clean
