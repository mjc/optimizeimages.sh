# Script to recursively optimize all images in current directory
# THIS WILL OVERWRITE YOUR ORIGINAL IMAGES AND STRIP METADATA. MAKE A SNAPSHOT.

Forked from [this](https://gist.github.com/mstroeck/3363227), which is a fork of: [this](https://gist.github.com/Munter/2576308)

This will be POSIX sh compliant as soon as I fix the semaphore implementation.

Recommend also using [Pingo](https://css-ig.net/pingo) but it appears to be closed source.

### TODO:
- [x] Pass shellcheck
- [x] Use functions to make parallelization easier
- [x] Don't reuse the same filenames so we can parallelize
- [x] Use fd instead of find so walking files is a lot faster.
- [x] Only use one `fd` or `find` and optimize both types of images in the same loop.
- [x] Use `file(1)` to detect file type and skip empty files.
- [x] Detect cpu count
- [x] Only spawn N processes and make sure N are always running when there are images to optimize
- [x] Detect if [fd](https://github.com/sharkdp/fd) is installed and fall back to `find` if it isn't.
- [ ] Add support for gif and other file types
- [ ] Detect if the prerequisite programs are installed
- [ ] Install prerequisites if they are not installed
