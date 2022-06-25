all: pcf

pcf: tadepe-16n.pcf

tadepe-16n.pcf: tadepe-16n.bdf
	bdftopcf -t -o tadepe-16n.pcf tadepe-16n.bdf

edit:
	gbdfed tadepe-16n.bdf

once:
	xset +fp ${HOME}/proj/tadepe

test: tadepe-16n.pcf
	mkfontdir
	mkfontscale
	xset fp rehash
