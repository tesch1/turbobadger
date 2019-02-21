Hasty Badger
-----------------------------------------------------------------------------------

```text
I created Turbo Badger because i wanted a small UI toolkit for use in games and
hardware accelerated applications across multiple platforms (that target both
desktop and mobile).

The goal is a toolkit that can be easily integrated into an existing codebase to
make UI with skinning.

It has no dependency on stl, RTTI or exceptions. Compiling without these features
makes footprint very small. Utility classes (such as string, lists, hash table,
etc.) are quite minimal for the basic needs of Turbo Badger itself.

See [integration.txt](integration.txt) for details about integrating image loading,
renderer, font system etc.
```

Hasty is not Turbo.

HastyBadger is a fork of the excellent widget and GUI library [Turbo
Badger](https://github.com/fruxo/turbobadger).  Notabe additions are
c++14 and out-of-the box SDL2 / GLES2 / GL3 / Emscripten demos, plus
continuous integration to ease community contribution.  The aim is to
be super user friendly at the cost of being a bit more bloated than
TurboBadger.


Features
-----------------------------------------------------------------------------------

![Default skin](Demo/screenshot/screenshot_01.png)

### TurboBadger Core

  * Widgets (many common standard widgets)
  * Text editing widget (With clipboard, undo/redo, styling functionality,
    embedded content (read only)...)
  * Extendable skin system with automatic runtime atlas creation,
    Expand (shadows & glow without nasty margin hacks),
    conditions (simple selectors), overrides, overlays, children, multiple
    pixel density support etc.
  * Automatic widget layout (No need to specify widget dimensions by pixels)
  * Text based UI resource format, supporting conditions etc.
  * Keyboard friendly (tab focus etc.)
  * Message handling, with delayed/timed messages.
  * All containers are scrollable/pannable (automatically from mouse/finger
    interaction, and following focus).
  * Very failproof event handling.
  * Widget connections (synchronize multiple widgets with "widget-values")
  * Language string handling
  * No dependency on stl, exceptions, RTTI
  * Very portable & easy to implement new backends (Image loading, fonts,
    renderer)
  * Support 32/64bit architectures and tested on Windows/Linux/Mac/iOS/Android
  * Uses constexpr by default for all ID comparisions on compilers that support
    it.
  * Unicode support (UTF8)
  * Multiple font systems can be used (Implementations of TBBF, freetype and stbf
    provided)
  * Animation system.
  * Unit tests.

### Differences from TurboBadger

- [SDL2 Platform Demo](Demo/platform/port_sdl2.cpp)
- [Android Studio Project](DemoAndroid2/)
- [Emscripten Platform Demo](http://tesch1.github.io/turbobadger/TurboBadgerDemoSDL.html)
- [Basic GL3 and GLES2 Renderers](src/tb/renderers/tb_renderer_gl.cpp)
- [CircleCI Continuous Integration](https://circleci.com/gh/tesch1/turbobadger)


Developement
-----------------------------------------------------------------------------------

```text
APIs are changed, features improved & added. Be aware that if you use this right
now, you'll probably have to adjust your code to API changes sometimes after
pulling master. Documentation about API changes take place in the git commit
changelog for now ;)
```

The HastyBadger is a work in progress, contributions and constructive
commentary are welcome!

```text
If you try to familiarize yourself with the code, you might notice the heavily used
object `TBID` that may seem like a string. It's actually an uint32 that can be set
from a string (using the strings hash value). It's used for hash keys, as
substitute for enums and all kind of things needing custom IDs.

With compilers supporting C++ 11 `constexpr`, the string to integer conversion is
done compile time.

If you want to add new stuff, here are some hints that will make it easier to get a
pull requests accepted:

  * Do not make it dependant on exceptions, RTTI or stl (or boost or similar)

  * It should not leak or crash if running out of memory.

  * Follow the used code style (4 spaces wide tabs, indentation & whitespace style,
    documentation etc.)

  * Features that may be optional should be optional and not tied to the core.
```

### Current TODOs

- create iOS demo
- code test coverage measures
- fix/text macos Xcode demo
- fix Android Demo
- fix Windows Demo
- port over last few months of active TB development to HB
- make the docs prettier, cleanup
- fix sdl2 build
- differentiate between building the library and the demo


Building
-----------------------------------------------------------------------------------

Current build status:
[![CircleCI](https://circleci.com/gh/tesch1/turbobadger/tree/hastybadger.svg?style=svg)](https://circleci.com/gh/tesch1/turbobadger/tree/hastybadger)

The build process is streamlined into a handy bash script with several command line options. You can investigate the script yourself if you want to do the build process by yourself.


```sh
$ ./build -h
usage:
 ./build.sh [options]

  -h       this help message
  -o [dir] set build directory

  -gl      build for open gl
  -gl3     build for open gl3
  -gles2   build for open gles2

  -em      build for emscripten
  -sdl2    build for sdl2
  -glfw    build for glfw

  -v       be more verbose
  -q       be less verbose
```

### VisualStudio
There is project files for Visual Studio 2012 in Demo/VisualStudio.
For other platforms/compilers, you need to first run cmake to generate makefile or
projects for your favorite IDE.

### Sublime
There's a Sublime Text project for a small Android test app in DemoAndroid with a
custom build & deploy script (Windows .bat file. There's currently no Linux/Mac
scripts).


License
-----------------------------------------------------------------------------------

The original software "Turbo Badger" (<https://github.com/fruxo/turbobadger>) was
provided by Emil Segerås (<http://fiffigt.com>) under the following license:

```text
This software is provided 'as-is', without any express or implied warranty. In no
event will the authors be held liable for any damages arising from the use of this
software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to the
following restrictions:

  1. The origin of this software must not be misrepresented; you must not claim
  that you wrote the original software. If you use this software in a product,
  an acknowledgment in the product documentation would be appreciated but is not
  required.

  2. Altered source versions must be plainly marked as such, and must not be
  misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.
```

Redistribution terms for "Hasty Badger" (<https://github.com/tesch1/turbobadger>)
have yet to be determinated by Michael Tesch.

