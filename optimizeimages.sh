#!/bin/sh
set -o errexit

PNGS=`find . -iname "*.png"`
JPGS=`find . -iname "*.jpg"`
TMP1="_TMP1.PNG"
TMP2="_TMP2.PNG"

echo "Optimizing PNG"
for PNG in ${PNGS}
do
	BEFORE=`stat -c %s ${PNG}`
	echo -n "	${PNG}: ${BEFORE} "
	cp ${PNG} ${TMP1}
	COLORS=`pngtopnm ${PNG} | ppmhist -noheader | wc -l`

	if [ "$COLORS" -lt 2 ]; then
		COLORS=2
	fi

	if [ "$COLORS" -lt 257 ]; then
		cat ${PNG} | pngquant ${COLORS} > ${TMP1}
	fi

	pngcrush -q -l 9 -brute -rem alla ${TMP1} ${TMP2}
	rm ${TMP1}
	optipng -quiet -o7 -out ${TMP1} ${TMP2}

	AFTER=`stat -c %s ${TMP1}`
	if [ "$AFTER" -lt "$BEFORE" ]; then
		mv ${TMP1} ${PNG}
		echo "--> ${AFTER}"
	else
		echo "(Already optimal)"
	fi

	rm -f ${TMP1} ${TMP2}
done

echo "Optimizing JPG"
for JPG in ${JPGS}
do
	BEFORE=`stat -c %s ${JPG}`
	echo -n "	${JPG}: ${BEFORE} "
	jpegtran -optimize -copy none ${JPG} > ${TMP1}
	AFTER=`stat -c %s ${TMP1}`

	if [ "$AFTER" -lt "$BEFORE" ]; then
		mv ${TMP1} ${JPG}
		echo "--> ${AFTER}"
	else
		echo "(Already optimal)"
	fi
	rm -f ${TMP1}
done