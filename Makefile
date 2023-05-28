.SUFFIXES: .pcf .bdf

FONTS = tadepe-16n.pcf tadepe-16b.pcf

all: pcf

pcf: ${FONTS}

.bdf.pcf:
	bdftopcf -t -o $@ $<

edit-16n:
	gbdfed tadepe-16n.bdf &

edit-16b:
	gbdfed tadepe-16b.bdf &

install: ${FONTS}
	install -m 644 ${FONTS} ${HOME}/lib/fonts

clean:
	-rm -f ${FONTS}

test: install
	cd ${HOME}/lib/fonts ; mkfontdir ; mkfontscale ; xset fp rehash

.PHONY: all pcf edit-16n edit-16b install clean test
