
all:
	$(MAKE) glfw sdl3 lib
	[ `uname` != 'Darwin' ] || $(MAKE) osx ios
	[ ! -d ~/.android ] || $(MAKE) and
	[ ! -f ~/.emscripten ] || $(MAKE) em em-glfw

glfw:
	[ -f Build-glfw/Makefile ] || cmake . -BBuild-glfw -DTB_RENDERER=GL -DTB_BUILD_DEMO=GLFW
	cd Build-glfw && $(MAKE) package

sdl3:
	[ -f Build-sdl3/Makefile ] || cmake . -BBuild-sdl3 -DTB_RENDERER=GL3 -DTB_BUILD_DEMO=SDL3
	cd Build-sdl3 && $(MAKE) package

Build-emsc/Makefile:
#	source ${HOME}/local/emsdk/emsdk_env.sh ;
	emcmake cmake . -BBuild-emsc -DTB_BUILD_DEMO=SDL3 -DCMAKE_BUILD_TYPE=Debug

em-sdl3: Build-emsc/Makefile
	cd Build-emsc && $(MAKE)

Build-emscgl/Makefile:
#	source ${HOME}/local/emsdk/emsdk_env.sh ;
	emcmake cmake . -BBuild-emscgl -DTB_BUILD_DEMO=GLFW -DCMAKE_BUILD_TYPE=Debug

em-glfw: Build-emscgl/Makefile
	cd Build-emscgl && $(MAKE)

em: em-sdl3 # em-glfw

emrun:
	cd Build-emsc && emrun TurboBadgerDemo.html

Build-osx/TurboBadger.xcodeproj:
	cmake . -G Xcode -BBuild-osx -DTB_RENDERER=GL3 -DTB_BUILD_DEMO=SDL3

osx: Build-osx/TurboBadger.xcodeproj
	cd Build-osx && cmake --build . -j 8 --target package --config Debug

osxr: Build-osx/TurboBadger.xcodeproj
	cd Build-osx && cmake --build . --target package --config Release

Build-ios/TurboBadger.xcodeproj:
	cmake . -G Xcode -BBuild-ios -DCMAKE_TOOLCHAIN_FILE=cmake/iOS.cmake -DTB_BUILD_DEMO=SDL3

ios: Build-ios/TurboBadger.xcodeproj
	cd Build-ios && cmake --build . --target package --config Debug

iosr: Build-ios/TurboBadger.xcodeproj
	cd Build-ios && cmake --build . --target package --config Release

lib:
	[ -d Build-lib ] || cmake . -BBuild-lib -DTB_BACKEND=GLFW -DTB_BUILD_GLFW=ON
#	[ -d Build-lib ] || cmake . -BBuild-lib -DTB_BACKEND=SDL3 -DTB_BUILD_SDL3=ON
	cd Build-lib && cmake --build . --config Release

and:
	cd DemoAndroid && ./gradlew build

website: em-sdl3
	./doc/ghpages.sh

distclean:
	rm -rf Build-*

#%:
#	cd Build && $(MAKE) $@
#
