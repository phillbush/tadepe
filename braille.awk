#!/usr/bin/awk -f

function halfblank() {
	printf "00\n"
}

function fullblank() {
	printf "00\n00\n"
}

function dot(a, b, c,    s, t) {
	s = and(a, power[b]) ? "6" : "0"
	t = and(a, power[c]) ? "6" : "0"
	printf "%s%s\n%s%s\n", s, t, s, t
}

function char(n) {
	printf "STARTCHAR braille%d\n", n
	printf "ENCODING %d\n", (10240 + n)
	printf "SWIDTH 480 0\n"
	printf "DWIDTH 8 0\n"
	printf "BBX 8 16 0 -4\n"
	printf "BITMAP\n"
	halfblank()
	dot(n, 0, 3)
	fullblank()
	dot(n, 1, 4)
	fullblank()
	dot(n, 2, 5)
	fullblank()
	dot(n, 6, 7)
	printf "ENDCHAR\n"
}

BEGIN {
	power[0] = 1
	power[1] = 2
	power[2] = 4
	power[3] = 8
	power[4] = 16
	power[5] = 32
	power[6] = 64
	power[7] = 128
	for (i = 0; i < 256; i++) {
		char(i)
	}
}
