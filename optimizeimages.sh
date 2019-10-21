#!/bin/sh
set -o errexit

# @TODO detect fd and fallback to find
files=$(fd -e png -e jpg -e jpeg .)
# files=$(find . \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))

optimize_a_png() {
    echo "Optimizing a PNG"
    png=$1
    tmp1="${png}_tmp1.png"
    tmp2="${png}_tmp2.png"

    before=$(stat -c %s "${png}")
    printf "	%s: %s " "${png}" "${before}"
    cp "${png}" "${tmp1}"
    colors=$(pngtopnm "${png}" | ppmhist -noheader | wc -l)

    if [ "$colors" -lt 2 ]; then
	colors=2
    fi

    if [ "$colors" -lt 257 ]; then
	pngquant ${colors} < "${png}" > "${tmp1}"
    fi

    pngcrush -q -l 9 -brute -rem alla "${tmp1}" "${tmp2}"
    rm "${tmp1}"
    optipng -quiet -o7 -out "${tmp1}" "${tmp2}"

    after=$(stat -c %s "${tmp1}")
    if [ "$after" -lt "$before" ]; then
	mv "${tmp1}" "${png}"
	echo "--> ${after}"
    else
	echo "(Already optimal)"
    fi

    rm -f "${tmp1}" "${tmp2}"
}

optimize_a_jpg() {
    echo "Optimizing a JPEG"
    jpg=$1
    tmp1="${jpg}_tmp1.png"
    tmp2="${jpg}_tmp2.png"
    before=$(stat -c %s "${jpg}")
    printf "	%s: %s " "${jpg}" "${before}"
    jpegtran -optimize -copy none "${jpg}" > "${tmp1}"
    after=$(stat -c %s "${tmp1}")

    if [ "$after" -lt "$before" ]; then
	mv "${tmp1}" "${jpg}"
	echo "--> ${after}"
    else
	echo "(Already optimal)"
    fi
    rm -f "${tmp1}"
}



for file in ${files}
do
    case $(file -bi "$file") in
	"image/jpeg; charset=binary" )
	    optimize_a_jpg "$file"
	    ;;
	"image/png; charset=binary" )
	    optimize_a_png "$file"
	    ;;
	"inode/x-empty; charset=binary" )
	    echo "skipping empty file ${file}"
	    ;;
    esac
done
