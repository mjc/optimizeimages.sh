#!/bin/sh

PNGS=`find . -name "*.png"`
TMP="_TMP.PNG"

for PNG in ${PNGS}
do
        BEFORE=`stat -c %s ${PNG}`
        COLORS=`pngtopnm ${PNG} | ppmhist -noheader | wc -l`

        if [ "$COLORS" -lt 2 ]; then
                COLORS=2
        fi

        if [ "$COLORS" -lt 257 ]; then
                cat ${PNG} | pngquant ${COLORS} > ${TMP}
        else 
                mv ${PNG} ${TMP}
        fi

        pngcrush -q -rem alla ${TMP} ${PNG}
        optipng -quiet -force -out ${PNG} ${TMP}
        rm ${TMP}
        AFTER=`stat -c %s ${PNG}`
        echo "${PNG}: ${BEFORE} --> ${AFTER}"
done