#!/usr/bin/awk -f
#
# Usage: merge letters.bdf diacritics.bdf > tadepe.bdf
# Creates a font with precomposed characters.
# Requires an awk(1) implementation with or() and gensub().
#
# © 2025 Lucas de Sena <lucas at seninha dot org>.  No rights reserved.
# THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY (Works On My Machine).

function err(obj, msg) {
	printf "merge: %s: %s\n", obj, msg >"/dev/stderr"
	status=1
	exit
}

function readheader(encoding, property, value, i, s) {
	s = ""
	for (i = 1; i <= NF; i++) {
		if (substr($i,1,6) == "CHARS ")
			continue;
		if (s != "")
			s = s "\n"
		s = s $i
	}
	if (header == "")
		header = s
}

function readrecord(encoding, property, value, i, s) {
	for (i = 2; i <= NF; i++) {
		if (match($i, /^ENCODING[[:space:]]+/)) {
			encoding = substr($i, RSTART+RLENGTH) + 0
			break
		}
	}
	if (!encoding)
		err($1, "no encoding found")
	for (i = 2; i <= NF; i++) {
		if (substr($i,1,8) == "ENCODING")
			continue
		if (substr($i,1,6) == "BITMAP")
			break
		property = gensub(/[[:space:]].*/, "", 1, $i)
		value = gensub(/[^[:space:]]+[[:space:]]+/, "", 1, $i)
		props[property] = value
	}
	s = ""
	for (i++; i <= NF; i++) {
		s = s $i
		if (i < NF)
			s = s "\n"
	}
	bitmaps[encoding] = s
}

function h2d(hex,    i, n, a, d) {
	n = split(hex, a, "")
	d = 0
	for (i = 1; i <= n; i++) {
		if (a[i] == "A" || a[i] == "a")
			d += 10 * 16 ^ (n-i)
		else if (a[i] == "B" || a[i] == "b")
			d += 11 * 16 ^ (n-i)
		else if (a[i] == "C" || a[i] == "c")
			d += 12 * 16 ^ (n-i)
		else if (a[i] == "D" || a[i] == "d")
			d += 13 * 16 ^ (n-i)
		else if (a[i] == "E" || a[i] == "e")
			d += 14 * 16 ^ (n-i)
		else if (a[i] == "F" || a[i] == "f")
			d += 15 * 16 ^ (n-i)
		else
			d += a[i] * 16 ^ (n-i)
	}
	return d
}

function merge(encoding,    parts, bits, ndigits, fmt, a, i, j, n, s) {
	ndigits = props["BBX"] / 4
	fmt = "%0" ndigits "X"
	split(compositions[encoding], parts, /[[:space:]]+/)

	# composite char already existant
	if (encoding in bitmaps)
		return

	# a part of a composite char is not in font
	for (j in parts) {
		parts[j] = h2d(parts[j])
		if (!(parts[j] in bitmaps)) {
			return
		}
	}

	for (j in parts) {
		n = split(bitmaps[parts[j]], a, /\n+/)
		if (index(names[encoding], "CAPITAL") &&\
		    index(names[parts[j]], "COMBINING") &&\
		    names[parts[j]] !~ /BELOW|CEDILLA|OGONEK/) {
			for (i = 1; i <= n/2; i++) {
				a[i] = a[i+ndigits]
			}
		}
		for (i = 1; i <= n; i++) {
			bits[i] = or(bits[i], h2d(a[i]))
		}
	}

	s = ""
	for (i = 1; i <= length(bits); i++) {
		s = s sprintf(fmt, bits[i])
		if (i < length(bits))
			s = s "\n"
	}
	bitmaps[encoding] = s
}

function getcharname(encoding) {
	if (encoding in names)
		return names[encoding]
	return sprintf("U+%04X", encoding)
}

BEGIN {
	RS="(\nENDCHAR)?\nSTARTCHAR[[:space:]]*|\nENDCHAR(\nENDFONT)?\n?"
	FS="\n"
	nfonts = 0

	for (nfonts = 1; nfonts < ARGC; nfonts++) {
		if ((getline <ARGV[nfonts]) <= 0)
			err(file, "no font in file")
		readheader()
		while ((getline <ARGV[nfonts]) > 0)
			readrecord()
	}

	RS="\n"
	FS=";"
	OFS=" "
	while ((getline <"UnicodeData.txt") > 0) {
		# do not go above basic multilingual plane
		if (length($1) > 4)
			break
		encoding = h2d($1)
		names[encoding] = $2
		if ($6 !~ /([0-9a-zA-Z])+( ([0-9a-zA-Z])+)+/)
			continue        # composite char is not a letter+diacritic
		compositions[encoding] = $6
	}

	for (encoding in compositions)
		merge(encoding)

	print header
	print "CHARS", length(bitmaps)
	for (encoding in bitmaps) {
		print "STARTCHAR", getcharname(encoding)
		print "ENCODING", encoding
		print "SWIDTH", props["SWIDTH"]
		print "DWIDTH", props["DWIDTH"]
		print "BBX", props["BBX"]
		print "BITMAP"
		print bitmaps[encoding]
		print "ENDCHAR"
	}
	print "ENDFONT"
}

END {
	exit status
}
