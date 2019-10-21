# Script to recursively optimize all images in current directory

Forked from: https://gist.github.com/mstroeck/3363227

This should be POSIX sh compliant.

### TODO:
- [x] Pass shellcheck
- [x] Use functions to make parallelization easier
- [x] Don't reuse the same filenames so we can parallelize
- [x] Dse fd instead of find so walking files is a lot faster.
- [x] Only use one `fd` or `find` and optimize both types of images in the same loop.
- [x] Use `file(1)` to detect file type and skip empty files.
- [x] Detect cpu count
- [x] Only spawn N processes and make sure N are always running when there are images to optimize
- [ ] Detect if [fd](https://github.com/sharkdp/fd) is installed and fall back to `find` if it isn't.
- [ ] Detect if the prerequisite programs are installed
- [ ] Install prerequisites if they are not installed
