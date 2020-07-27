
all:
	$(MAKE) glfw sdl2 lib
	[ `uname` != 'Darwin' ] || $(MAKE) osx ios
	[ ! -d ~/.android ] || $(MAKE) and
	[ ! -f ~/.emscripten ] || $(MAKE) em em-glfw

glfw:
	[ -f Build-glfw/Makefile ] || cmake . -BBuild-glfw -DTB_RENDERER=GL -DTB_BUILD_DEMO=GLFW
	cd Build-glfw && $(MAKE) package

sdl2:
	[ -f Build-sdl2/Makefile ] || cmake . -BBuild-sdl2 -DTB_RENDERER=GL3 -DTB_BUILD_DEMO=SDL2
	cd Build-sdl2 && $(MAKE) package

Build-emsc/Makefile:
	source ${HOME}/local/emsdk/emsdk_env.sh ; \
	emconfigure cmake . -BBuild-emsc -DTB_BUILD_DEMO=SDL2 -DCMAKE_BUILD_TYPE=Debug

em-sdl2: Build-emsc/Makefile
	cd Build-emsc && $(MAKE)

Build-emscgl/Makefile:
	source ${HOME}/local/emsdk/emsdk_env.sh ; \
	emconfigure cmake . -BBuild-emscgl -DTB_BUILD_DEMO=GLFW -DCMAKE_BUILD_TYPE=Debug

em-glfw: Build-emscgl/Makefile
	cd Build-emscgl && $(MAKE)

em: em-sdl2 em-glfw

Build-osx/TurboBadger.xcodeproj:
	cmake . -G Xcode -BBuild-osx -DTB_RENDERER=GL3 -DTB_BUILD_DEMO=SDL2

osx: Build-osx/TurboBadger.xcodeproj
	cd Build-osx && cmake --build . --target package --config Debug

osxr: Build-osx/TurboBadger.xcodeproj
	cd Build-osx && cmake --build . --target package --config Release

Build-ios/TurboBadger.xcodeproj:
	cmake . -G Xcode -BBuild-ios -DCMAKE_TOOLCHAIN_FILE=cmake/iOS.cmake -DTB_BUILD_DEMO=SDL2

ios: Build-ios/TurboBadger.xcodeproj
	cd Build-ios && cmake --build . --target package --config Debug

iosr: Build-ios/TurboBadger.xcodeproj
	cd Build-ios && cmake --build . --target package --config Release

lib:
	[ -d Build-lib ] || cmake . -BBuild-lib -DTB_BACKEND=GLFW -DTB_BUILD_GLFW=ON
#	[ -d Build-lib ] || cmake . -BBuild-lib -DTB_BACKEND=SDL2 -DTB_BUILD_SDL2=ON
	cd Build-lib && cmake --build . --config Release

and:
	cd DemoAndroid2 && ./gradlew build

website: em-sdl2
	./doc/ghpages.sh

distclean:
	rm -rf Build-*

#%:
#	cd Build && $(MAKE) $@
#
