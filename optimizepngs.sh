#!/bin/sh
set -o errexit

PNGS=`find . -iname "*.png"`
TMP1="_TMP1.PNG"
TMP2="_TMP2.PNG"

for PNG in ${PNGS}
do
        BEFORE=`stat -c %s ${PNG}`
        cp ${PNG} ${TMP1}
        COLORS=`pngtopnm ${PNG} | ppmhist -noheader | wc -l`

        if [ "$COLORS" -lt 2 ]; then
                COLORS=2
        fi

        if [ "$COLORS" -lt 257 ]; then
                cat ${PNG} | pngquant ${COLORS} > ${TMP1}
        fi

        pngcrush -q -brute -l 9 -rem alla ${TMP1} ${TMP2}
        rm ${TMP1}
        optipng -quiet -o7 -out ${TMP1} ${TMP2}

        AFTER=`stat -c %s ${TMP1}`
        if [ "$AFTER" -lt "$BEFORE" ]; then
                mv ${TMP1} ${PNG}
                echo "${PNG}: ${BEFORE} --> ${AFTER}"
        else 
                echo "${PNG}: ${BEFORE} (Already optimal)"
        fi

        rm -f ${TMP1} ${TMP2}
done