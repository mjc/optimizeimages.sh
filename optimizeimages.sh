#!/bin/sh
set -o errexit

# @TODO detect fd and fallback to find
pngs=$(fd -e png .)
jpgs=$(fd -e jpg .)
#pngs=$(find . -iname "*.png")
#jpgs=$(find . -iname "*.jpg")
TMP1="_TMP1.PNG"
TMP2="_TMP2.PNG"

echo "Optimizing PNG"
for png in ${pngs}
do
	BEFORE=$(stat -c %s "${png}")
	printf "	%s: %s " "${png}" "${BEFORE}"
	cp "${png}" "${TMP1}"
	COLORS=$(pngtopnm "${png}" | ppmhist -noheader | wc -l)

	if [ "$COLORS" -lt 2 ]; then
		COLORS=2
	fi

	if [ "$COLORS" -lt 257 ]; then
	    pngquant ${COLORS} < "${png}" > "${TMP1}"
	fi

	pngcrush -q -l 9 -brute -rem alla "${TMP1}" "${TMP2}"
	rm "${TMP1}"
	optipng -quiet -o7 -out "${TMP1}" "${TMP2}"

	AFTER=$(stat -c %s "${TMP1}")
	if [ "$AFTER" -lt "$BEFORE" ]; then
		mv "${TMP1}" "${png}"
		echo "--> ${AFTER}"
	else
		echo "(Already optimal)"
	fi

	rm -f "${TMP1}" "${TMP2}"
done

echo "Optimizing JPG"
for jpg in ${jpgs}
do
	BEFORE=$(stat -c %s "${jpg}")
	printf "	%s: %s " "${jpg}" "${BEFORE}"
	jpegtran -optimize -copy none "${jpg}" > "${TMP1}"
	AFTER=$(stat -c %s "${TMP1}")

	if [ "$AFTER" -lt "$BEFORE" ]; then
		mv "${TMP1}" "${jpg}"
		echo "--> ${AFTER}"
	else
		echo "(Already optimal)"
	fi
	rm -f "${TMP1}"
done
