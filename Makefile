all: pcf

pcf: tadepe-16n.pcf

tadepe-16n.pcf: tadepe-16n.bdf
	bdftopcf -t -o tadepe-16n.pcf tadepe-16n.bdf

edit:
	gbdfed tadepe-16n.bdf

once:
	xset +fp ${HOME}/proj/tadepe

install: tadepe-16n.pcf
	install -m 644 tadepe-16n.pcf ${HOME}/theme/fonts

test: install
	cd ${HOME}/theme/fonts ; mkfontdir ; mkfontscale ; xset fp rehash
