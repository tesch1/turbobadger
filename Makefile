
all:
	$(MAKE) glfw sdl2 lib
	[ `uname` != 'Darwin' ] || $(MAKE) osx ios
	[ ! -d ~/.android ] || $(MAKE) and
	[ ! -f ~/.emscripten ] || $(MAKE) em em-glfw

glfw:
	[ -d Build-glfw ] || ./build.sh -glfw -gl -o Build-glfw
	cd Build-glfw && $(MAKE) package

sdl2:
	[ -d Build-sdl2 ] || ./build.sh -sdl2 -gl3 -o Build-sdl2
	cd Build-sdl2 && $(MAKE) package

em-sdl2:
	[ -d Build-emsc ] || ./build.sh -gles2 -sdl2 -em -o Build-emsc
	cd Build-emsc && $(MAKE)

em-glfw:
	[ -d Build-emscgl ] || ./build.sh -gles2 -glfw -em -o Build-emscgl
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
	[ -d Build-lib ] || ./build.sh -o Build-lib -gl3
	cd Build-lib && $(MAKE) package

and:
	cd DemoAndroid2 && ./gradlew build

distclean:
	rm -rf Build-*

#%:
#	cd Build && $(MAKE) $@
#
