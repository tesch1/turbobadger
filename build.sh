#!/bin/bash

# die on errors
set -e

: ${VERBOSE=0}
: ${BUILD_DIR=Build}
: ${MAKE_FLAGS=}
: ${NPROC=}
# if available, use cmake3
if command -v cmake3 >/dev/null 2>&1 ; then
    : ${CMAKE=cmake3}
else
    : ${CMAKE=cmake}
fi
: ${CMAKE_FLAGS=}

CMDLINE="$0 $@"
SCRIPT=$(basename "$0")
SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OnError() {
    echo "$SCRIPT: Error on line ${BASH_LINENO[0]}, exiting."
    exit 1
}
trap OnError ERR
if [ -z "$NPROC" ]; then
    if command -v nproc &> /dev/null ; then
        NPROC=$(nproc)
    elif command -v sysctl &> /dev/null ; then
        NPROC=$(sysctl -n hw.ncpu)
    else
        NPROC=1
    fi
fi

usage () {
    cat <<EOF
usage:
 $0 [options]

  -h       this help message
  -o [dir] set build directory      

  -gl      build for open gl
  -gl3     build for open gl3 (use with -sdl2)
  -gles2   build for open gles2 (use with -sdl2)

  -em      build for emscripten
  -sdl2    build for sdl2
  -glfw    build for glfw
  -clang   set CC=clang CXX=clang++

  -doc     build doxygen docs in doc/

  -v       be more verbose
  -q       be less verbose
EOF
    exit 1
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_SYSTEM=LINUX" ;;
    Darwin*)
        CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_SYSTEM=MACOSX"
        export CC=clang
        export CXX=clang++
        ;;
    CYGWIN*)    CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_SYSTEM=WINDOWS" ;;
    MINGW*)     CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_SYSTEM=WINDOWS" ;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "CMAKE_FLAGS: ${CMAKE_FLAGS}"
cd "${SRC_DIR}"

# process command line args
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -o)                    BUILD_DIR=$(mkdir -p "$2" && cd "$2" && pwd); shift ;;
        -C|-clang)
            export CC=clang
            export CXX=clang++
            ;;
        -doc*)
            for skin in resources/*skin*/ ; do
                ./doc/skindoc.py "$skin/skin.tb.txt"
            done
            # take a detour, update the gh-pages branch
            ./doc/ghpages.sh
            echo "Made docs"
            exit 0
            ;;
        -gl)
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_RENDERER=GL"
            ;;
        -gl3)
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_RENDERER=GL3"
            ;;
        -gles2)
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_RENDERER=GLES_2"
            ;;
        -em*)
            BUILD_DIR="BuildEmsc"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_RENDERER=GLES_2"
            source ${HOME}/local/emsdk/emsdk_env.sh
            #${EMSCRIPTEN}/emcc --clear-cache --clear-ports
            CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_TOOLCHAIN_FILE=${EMSCRIPTEN}/cmake/Modules/Platform/Emscripten.cmake"
            #CMAKE_FLAGS="${CMAKE_FLAGS} -G Unix Makefiles"
            ;;
        -sdl*)
            BUILD_DIR="BuildSDL2"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_DEMO=SDL2"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_SDL2=ON"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_FREETYPE=ON"
            ;;
        -glfw)
            BUILD_DIR="BuildGLFW"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_DEMO=GLFW"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_RENDERER=GL"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_GLFW=ON"
            #CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_BUILD_FREETYPE=ON"
            CMAKE_FLAGS="${CMAKE_FLAGS} -DTB_FONT_RENDERER=TBBF"
            ;;
        -v|--verbose)          VERBOSE=$(( ${VERBOSE} + 1 ))
                               MAKE_FLAGS="${MAKE_FLAGS} VERBOSE=1"
                               CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
                               ;;
        -q|--quiet)            VERBOSE=$(( ${VERBOSE} - 1 ))
                               ;;
        -h|--help)             usage ;;
        *)
            # unknown option
            echo "unknown option $key"
            usage
            ;;
    esac
    shift
done

if [ ! -f ./integration.txt ]; then
    echo "run build.sh from turbobadger root directory"
    exit 1
fi

if [ ! -f Demo/thirdparty/glfw/CMakeLists.txt ]; then
    git submodule init
    git submodule update
fi

if [ ! -z "${BUILD_DIR}" ] && [ -d "${BUILD_DIR}" ]; then
    rm -rf "${BUILD_DIR}"
fi
mkdir -p "${BUILD_DIR}"

cmake "${SRC_DIR}" -B"${BUILD_DIR}" ${CMAKE_FLAGS} -G 'Unix Makefiles'
cd "${BUILD_DIR}"
make -j${NPROC} ${MAKE_FLAGS}
