#!/usr/bin/awk -f

BEGIN {
	large["0"] = "00"
	large["1"] = "03"
	large["2"] = "0C"
	large["3"] = "0F"
	large["4"] = "30"
	large["5"] = "33"
	large["6"] = "3C"
	large["7"] = "3F"
	large["8"] = "C0"
	large["9"] = "C3"
	large["A"] = "CC"
	large["B"] = "CF"
	large["C"] = "F0"
	large["D"] = "F3"
	large["E"] = "FC"
	large["F"] = "FF"
}

$1 == "FONT" {
	n = split($2, a, "-")
	a[8] *= 2
	a[9] *= 2
	s = ""
	for (i = 2; i <= n; i++)
		s = s "-" a[i]
	$2 = s
}

$1 == "SIZE" || $1 == "PIXEL_SIZE" || \
$1 == "POINT_SIZE" || $1 == "FONTBOUNDINGBOX" || \
$1 == "FONT_DESCENT" || $1 == "FONT_ASCENT" || \
$1 == "DWIDTH" || $1 == "BBX" {
	for (i = 2; i <= NF; i++)
		$i *= 2
}

NF == 1 && $0 ~ /^[0-9A-F]+$/ {
	s = ""
	for (i = 1; i <= length($0); i++)
		s = s large[substr($0, i, 1)]
	$0 = s "\n" s
}

{
	print
}
