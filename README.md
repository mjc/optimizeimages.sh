# Script to recursively optimize all images in current directory

Forked from: https://gist.github.com/mstroeck/3363227

This should be POSIX sh compliant.

### TODO:
- [x] pass shellcheck
- [x] use functions to make parallelization easier
- [x] don't reuse the same filenames so we can parallelize
- [x] use fd instead of find so walking files is a lot faster.
- [ ] detect if [fd](https://github.com/sharkdp/fd) is installed and fall back to `find` if it isn't.
- [ ] detect if the prerequisite programs are installed
- [ ] install prerequisites if they are not installed
- [ ] detect cpu count
- [ ] only spawn N processes and make sure N are always running when there are images to optimize
- [ ] only use one `fd` or `find` and optimize both types of images in the same loop.
