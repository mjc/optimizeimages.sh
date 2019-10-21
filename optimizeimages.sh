#!/bin/sh
set -o errexit

# @TODO detect fd and fallback to find
pngs=$(fd -e png .)
jpgs=$(fd -e jpg .)
#pngs=$(find . -iname "*.png")
#jpgs=$(find . -iname "*.jpg")
tmp1="_tmp1.PNG"
tmp2="_tmp2.PNG"

optimize_a_png() {
    png=$1
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
    jpg=$1
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

echo "Optimizing PNG"
for png in ${pngs}
do
    optimize_a_png "$png"
done

echo "Optimizing JPG"
for jpg in ${jpgs}
do
  optimize_a_jpg "$jpg"
done
