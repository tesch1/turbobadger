#!/bin/bash
#
# Generage the gh-pages branch from this doxygen
#
set -xe

SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# make sure we're in the right place
cd "${SRC_DIR}"
[ -d DemoAndroid2/app ] || exit 1
[ -f doc/Doxyfile.in ] || exit 1
[ "${SRC_DIR}/Build-emsc/doc/Doxyfile" ] || exit 1
EMSCRIPTEN_FILES="
    TurboBadgerDemo.html 
    TurboBadgerDemo.data 
    TurboBadgerDemo.wasm
    TurboBadgerDemo.js"
for F in ${EMSCRIPTEN_FILES} ; do
    if ! [ -f "Build-emsc/${F}" ]; then
        echo "Unable to find 'Build-emsc/${F}', did you build the Emscripten Demo?"
        exit 1
    fi
done

# should already be configured
cd "${SRC_DIR}/Build-emsc"
make TurboBadgerDemo

# get a new tb
if [ ! -f "doc/html/index.html" ]; then
    # cleanup old doc location
    rm -rf   "doc/html"
    mkdir -p "doc/html"
    cd       "doc/html"
    git clone --depth 1 --branch gh-pages git@github.com:tesch1/turbobadger.git .
fi

cd       "${SRC_DIR}/doc/html"

if [ x != x"$(ls)" ] ; then
    git rm -rf *
fi

# make the docs
cd       "${SRC_DIR}/Build-emsc"
make docs
[ -f doc/html/index.html ] || exit 1

# copy the demo files
for F in ${EMSCRIPTEN_FILES} ; do
    cp "${SRC_DIR}/Build-emsc/${F}" "${SRC_DIR}/Build-emsc/doc/html/"
done

# check the docs in
cd "${SRC_DIR}/Build-emsc/doc/html"
git add .
git commit . -m 'updated doxygen docs' --amend

set +x
echo "to commit to github:"
echo "cd ${SRC_DIR}/Build-emsc/doc/html && git push -f --set-upstream origin gh-pages"
echo "or to view:"
echo "xdg-open ${SRC_DIR}/Build-emsc/doc/html/index.html"
# git push -f --set-upstream origin gh-pages
