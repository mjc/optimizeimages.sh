#!/bin/bash
set -o errexit

optimize_a_png() {
    png=$1
    tmp1="${png}_tmp1.png"
    tmp2="${png}_tmp2.png"

    before=$(stat -c %s "${png}")
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

    printf "	%s: %s " "${png}" "${before}"
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
    tmp1="${jpg}_tmp1.png"
    tmp2="${jpg}_tmp2.png"
    before=$(stat -c %s "${jpg}")
    jpegtran -optimize -copy none "${jpg}" > "${tmp1}"
    after=$(stat -c %s "${tmp1}")

    printf "	%s: %s " "${jpg}" "${before}"
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
	* )
	    echo "wtf is this file: ${file}"
	    file -bi "$file"
	    exit 1;
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
    elif which nproc > /dev/null; then
	core_count=$(nproc --all)
	thread_count=$core_count
    fi
    echo "Number of cores: ${core_count}, number of threads: ${thread_count}"
}

call_find_utility() {
    if which fd > /dev/null; then
	files=$(fd -e png -e jpg -e jpeg .)
    elif which find > /dev/null; then
	files=$(find . \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))
    fi
}


# from https://unix.stackexchange.com/a/216475
# @TODO port to POSIX or use some other method.
make_semaphore() {
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    sem_count=$1
    while [ "$((sem_count != 0))" -ne 0 ]; do
	printf %s 000 >&3
	: "$((sem_count = sem_count - 1))"
    done
}

run_with_lock() {
    local x
    read -r -u 3 -n 3 x && ((0==x)) || exit "$x"
    (
	( "$@"; )
	printf '%.3d' $? >&3
    )&
}

detect_core_count
make_semaphore "$thread_count"

call_find_utility

for file in ${files}
do
    run_with_lock pick_an_optimizer "${file}"
done
