#!/bin/sh
set -o errexit

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

pick_an_optimizer() {
    file=$1
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
}

detect_core_count() {
    if [ "$(uname -s)" = "FreeBSD" ]; then
	core_count=$(sysctl hw.ncpu | cut -d':' -f2 | tr -d ' ')
	# @TODO this is probably wrong.
	thread_count=$core_count
    elif [ "$(uname -s)" = "Darwin" ]; then
	core_count=$(sysctl hw.physicalcpu | cut -d':' -f2 | tr -d ' ')
	thread_count=$(sysctl hw.logicalcpu | cut -d':' -f2 | tr -d ' ')
    elif [ -r /proc/cpuinfo ]; then
	core_count=$(grep 'cpu cores' /proc/cpuinfo | uniq | cut -d':' -f2 | tr -d ' ')
	thread_count=$(grep 'processor' /proc/cpuinfo | tail -n 1 | cut -d':' -f2 | tr -d ' ')
	thread_count=$((thread_count+1))
    elif which nproc; then
	core_count=$(nproc --all)
	thread_count=$core_count
    fi
    echo "Number of cores: ${core_count}, number of threads: ${thread_count}"
}
detect_core_count

# @TODO detect fd and fallback to find
files=$(fd -e png -e jpg -e jpeg .)
# files=$(find . \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))
for file in ${files}
do
    pick_an_optimizer "${file}"
done
