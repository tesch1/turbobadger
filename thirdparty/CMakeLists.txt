#
# CMake file for turbobadger dependencies
#

cmake_minimum_required (VERSION 3.10.2)
project (turbobadger_thirdparty NONE)

include (ExternalProject)
get_directory_property (hasParent PARENT_DIRECTORY)

if (CMAKE_XCODE_BUILD_SYSTEM VERSION_GREATER_EQUAL 12)
  cmake_policy (SET CMP0114 NEW)
endif ()
# CMP0135: DOWNLOAD_EXTRACT_TIMESTAMP - only available in CMake 3.24+
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  cmake_policy (SET CMP0135 NEW)
endif ()

if (NOT WIN32)
  set (DOWNLOAD_DIR "$ENV{HOME}/Downloads")
else (NOT WIN32)
  set (DOWNLOAD_DIR "C:/Downloads")
endif (NOT WIN32)

# quiet warning messages
message ("${CMAKE_CONFIGURATION_TYPES} ${ANDROID}")

if (hasParent)
  #
  # setup search paths
  #
  if (IOS)
    set (CMAKE_FRAMEWORK_PATH "${CMAKE_SOURCE_DIR}/Frameworks.iOS")
    set (CMAKE_SYSTEM_FRAMEWORK_PATH ${CMAKE_SYSTEM_FRAMEWORK_PATH} "${CMAKE_SOURCE_DIR}/Frameworks.iOS")
  else ()
    set (CMAKE_FRAMEWORK_PATH "${CMAKE_SOURCE_DIR}/Frameworks.macOS")
  endif ()
endif ()

if (TB_BUILD_GLFW)
  # Download glfw
  ExternalProject_Add (GLFWEXT
    PREFIX GLFWEXT
    URL https://github.com/glfw/glfw/archive/refs/tags/3.3.10.tar.gz
    URL_HASH MD5=f6e72e39141fb7f9e71017d52781ee42
    DOWNLOAD_DIR "${DOWNLOAD_DIR}"
    DOWNLOAD_NAME glfw-3.3.10.tar.gz
    #GIT_REPOSITORY "https://github.com/glfw/glfw.git"
    #GIT_TAG "3.3"
    #GIT_SHALLOW 1
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD ON)
  ExternalProject_Get_Property (GLFWEXT source_dir)
  ExternalProject_Get_Property (GLFWEXT binary_dir)
  if (hasParent)
    set (GLFW_SRC_DIR "${source_dir}" PARENT_SCOPE)
    set (GLFW_INCLUDE_DIRS "${source_dir}/include" PARENT_SCOPE)

    # Configure glfw & add_subdirectory()
    set (GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
    set (GLFW_BUILD_TESTS OFF CACHE BOOL "just want glfw library" FORCE)
    set (GLFW_BUILD_EXAMPLES OFF CACHE BOOL "just want glfw library" FORCE)
    set (GLFW_CLIENT_LIBRARY opengl CACHE STRING "client to use for glfw" FORCE) # glesv1, glesv2
    set (GLFW_INSTALL OFF CACHE BOOL "just want glfw library" FORCE)
    # set (GLFW_USE_OPTIMUS_HPG ON "just want glfw library")
    add_subdirectory (${source_dir} ${binary_dir})
    set (EXTRA_LIBS ${EXTRA_LIBS} glfw ${GLFW_LIBRARIES} PARENT_SCOPE)
  endif (hasParent)
elseif (TB_BACKEND STREQUAL GLFW AND hasParent)
  #add_library (glfw INTERFACE IMPORTED GLOBAL)
  if (EMSCRIPTEN)
    if (${CMAKE_VERSION} VERSION_LESS "3.8.0")
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s USE_GLFW=3" PARENT_SCOPE)
    else ()
      add_library (glfw INTERFACE IMPORTED GLOBAL)
      set_property (TARGET glfw APPEND PROPERTY INTERFACE_COMPILE_OPTIONS -s USE_GLFW=3)
      set_property (TARGET glfw APPEND PROPERTY INTERFACE_LINK_OPTIONS    -s USE_GLFW=3)
    endif ()
  else ()
    find_package (glfw3 REQUIRED)
    #add_library (glfw ALIIAS glfw3)
  endif (EMSCRIPTEN)
endif (TB_BUILD_GLFW)

if (TB_BUILD_SDL3)
  set (SDL_VERSION 3.2.26)
  # Note: MD5 hash to be verified after first download
  set (SDL_VERSION_HASH "")

  ExternalProject_Add (sdl3X
    PREFIX sdl3X
    URL https://github.com/libsdl-org/SDL/releases/download/release-${SDL_VERSION}/SDL3-${SDL_VERSION}.tar.gz
    #URL_HASH "MD5=${SDL_VERSION_HASH}"
    DOWNLOAD_DIR "${DOWNLOAD_DIR}"
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD ON)
  ExternalProject_Get_Property (sdl3X source_dir)

  if (hasParent)
    #set (SDL_CMAKE_DEBUG_POSTFIX "\"\"" CACHE STRING "Name suffix for debug builds" FORCE)
    if (ANDROID)
      set (SDL_SHARED   ON  CACHE BOOL "" FORCE)
      set (SDL_STATIC   OFF CACHE BOOL "" FORCE)
      # sdl3 needs cpufeatures on Android
      include (AndroidNdkModules)
      android_ndk_import_module_cpufeatures ()
      get_target_property (CPUFEATURES_INCLUDES cpufeatures INCLUDE_DIRECTORIES)
      list (GET CPUFEATURES_INCLUDES -1 CPUFEATURES_INCLUDES_)
      list (APPEND EXTRA_CFLAGS "-I${CPUFEATURES_INCLUDES_}")
      list (APPEND EXTRA_LDFLAGS "$<TARGET_FILE:cpufeatures>")
    else ()
      set (SDL_SHARED   OFF CACHE BOOL "" FORCE)
      set (SDL_STATIC   ON  CACHE BOOL "" FORCE)
    endif ()
    set (SDL_STATIC_PIC ON  CACHE BOOL "" FORCE)
    set (SDL_TEST       OFF CACHE BOOL "" FORCE)
    # Disable Cocoa (macOS-only) for iOS builds
    if (IOS)
      set (SDL_COCOA    OFF CACHE BOOL "" FORCE)
    endif ()

    #set (ENV{CFLAGS}    "-std=c99")
    add_subdirectory ("${source_dir}" "${CMAKE_CURRENT_BINARY_DIR}/sdl3X_binary_dir" EXCLUDE_FROM_ALL)
    set (SDL3_DIR "${source_dir}" CACHE STRING "Path to SDL3 sources" FORCE)

    # Create SDL3-interface
    add_library (SDL3-interface INTERFACE IMPORTED GLOBAL)

    # Link to the appropriate SDL3 target based on platform
    if (ANDROID)
      if (NOT TARGET SDL3-shared)
        message (FATAL_ERROR "Didn't create 'SDL3-shared' target")
      endif ()
      target_link_libraries (SDL3-interface INTERFACE SDL3-shared)
    else ()
      if (NOT TARGET SDL3-static)
        message (FATAL_ERROR "Didn't create 'SDL3-static' target")
      endif ()
      target_link_libraries (SDL3-interface INTERFACE SDL3-static)
    endif ()
  endif (hasParent)
elseif ((TB_BACKEND STREQUAL SDL3) AND hasParent)
  #
  # Not building SDL3, so try to find it
  #
  add_library (SDL3-interface INTERFACE IMPORTED GLOBAL)
  if (EMSCRIPTEN)
    # Note: Emscripten SDL3 support
    if (${CMAKE_VERSION} VERSION_LESS "3.8.0")
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s USE_SDL=3" CACHE STRING BLAH FORCE)
    else ()
      set_property (TARGET SDL3-interface APPEND PROPERTY INTERFACE_COMPILE_OPTIONS -s USE_SDL=3)
      set_property (TARGET SDL3-interface APPEND PROPERTY INTERFACE_LINK_OPTIONS    -s USE_SDL=3)
    endif ()
  else ()
    message ("Looking for SDL3 with find_package()...")
    find_package (SDL3 QUIET CONFIG)
    if (NOT SDL3_FOUND)
      message ("Looking for SDL3 with find_library()...")
      # CMAKE_FIND_ROOT_PATH_BOTH is needed for finding local iOS FW in CMAKE_FIND_FRAMEWORK
      find_library (SDL3_LIBRARY SDL3 CMAKE_FIND_ROOT_PATH_BOTH)
      find_path (SDL3_INCLUDE_DIR "SDL3/SDL.h" CMAKE_FIND_ROOT_PATH_BOTH)
      # look for OpenGL
      if (NOT IOS)
        set (OpenGL_GL_PREFERENCE GLVND)
        find_package (OpenGL)
      else ()
        # iOS SDL Framework needs some other frameworks...
        set (OPENGL_FOUND TRUE)
        set (IOS_FRAMEWORKS
          Foundation AVFoundation AudioToolbox CoreGraphics
          QuartzCore Metal OpenGLES UIKit MediaPlayer
          GameController CoreMotion )
        add_library (OpenGL::GL INTERFACE IMPORTED GLOBAL)
        foreach (FW ${IOS_FRAMEWORKS})
          set_property (TARGET OpenGL::GL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "-framework ${FW}")
        endforeach ()
      endif ()
      # look for SDL3
      if (SDL3_LIBRARY AND SDL3_INCLUDE_DIR AND OPENGL_FOUND)
        add_library (SDL3 INTERFACE IMPORTED GLOBAL)
        set_property (TARGET SDL3 APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${SDL3_LIBRARY} OpenGL::GL)
        set_property (TARGET SDL3 APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${SDL3_INCLUDE_DIR})
        set (SDL3_FOUND TRUE)
        message (STATUS "SDL3_LIBRARY    : ${SDL3_LIBRARY}")
        message (STATUS "SDL3_INCLUDE_DIR: ${SDL3_INCLUDE_DIR}")
      else ()
        message (FATAL_ERROR "SDL3 NOT Found: '${SDL3_LIBRARY}' '${SDL3_INCLUDE_DIR}' '${OPENGL_FOUND}'")
      endif ()
    endif ()
    if (NOT SDL3_FOUND)
      message ("Looking for SDL3 with pkg_search_module()...")
      include (FindPkgConfig)
      pkg_search_module (SDL3 REQUIRED sdl3)
    endif ()
    if (NOT SDL3_FOUND)
      message (FATAL_ERROR "Unable to find SDL3: ${SDL3}, ${SDL3_FOUND}")
    endif ()
    set_property (TARGET SDL3-interface APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS SDL_FRAMEWORK=1)
    target_link_libraries (SDL3-interface INTERFACE SDL3)
  endif (EMSCRIPTEN)
endif (TB_BUILD_SDL3)

if (TB_BUILD_FREETYPE)
  #
  # freetype
  #
  ExternalProject_Add (freetypeX
    PREFIX freetypeX
    URL http://download.savannah.gnu.org/releases/freetype/freetype-2.13.3.tar.gz
    URL_HASH MD5=ac1f0b517f62bd40d50bc995faa5741d
    #URL http://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz
    #URL_HASH MD5=3adb0e35d3c100c456357345ccfa8056
    #URL http://download.savannah.gnu.org/releases/freetype/freetype-2.8.1.tar.gz
    #URL_HASH MD5=c947b6b1c513e814cc9d7617a44bc6cf
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD ON )
  ExternalProject_Get_Property (freetypeX source_dir)
  if (hasParent)
    set (FREETYPE_SRC_DIR "${source_dir}")
    message (STATUS " FREETYPE_SRC_DIR: ${FREETYPE_SRC_DIR}")
    # freetype config variables
    set (FT_WITH_ZLIB OFF CACHE STRING "" FORCE)
    set (FT_WITH_BZIP2 OFF CACHE STRING "" FORCE)
    set (FT_WITH_PNG OFF CACHE STRING "" FORCE)
    set (FT_WITH_HARFBUZZ OFF CACHE STRING "" FORCE)
    set (FT_WITH_BROTLI OFF CACHE STRING "" FORCE)
    set (DISABLE_FORCE_DEBUG_POSTFIX TRUE CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_ZLIB ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_BZip2 ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_PNG ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_HarfBuzz ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_BrotliDec ON CACHE STRING "" FORCE)
    set (FREETYPE_NO_DIST ON CACHE STRING "" FORCE)
    add_subdirectory ("${FREETYPE_SRC_DIR}"
      "${CMAKE_CURRENT_BINARY_DIR}/freetype_build"
      EXCLUDE_FROM_ALL)
    set_property (TARGET freetype APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
      $<TARGET_PROPERTY:freetype,INCLUDE_DIRECTORIES>)
  endif (hasParent)
elseif (EMSCRIPTEN AND TB_FONT_RENDERER STREQUAL FREETYPE AND hasParent)
  cmake_minimum_required (VERSION 3.13.1)
  add_library (freetype INTERFACE IMPORTED GLOBAL)
  target_compile_options (freetype INTERFACE "SHELL: -s USE_FREETYPE=1")
  target_link_options    (freetype INTERFACE "SHELL: -s USE_FREETYPE=1")
endif (TB_BUILD_FREETYPE)

if (WIN32)
  ExternalProject_Add (GLEWX
    PREFIX GLEWX
    #URL "https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0-win32.zip"
    #URL_HASH MD5=32a72e6b43367db8dbea6010cd095355
    URL "https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0-win32.zip"
    URL_HASH MD5=1feddfe8696c192fa46a0df8eac7d4bf
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD ON
    )
  ExternalProject_Get_Property (GLEWX source_dir)
  if (hasParent)
    add_library (GLEW_WRAP INTERFACE IMPORTED GLOBAL)
    set_property (TARGET GLEW_WRAP APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${source_dir}/include")
    if ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
      set_property (TARGET GLEW_WRAP APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${source_dir}/lib/Release/Win32/glew32s.lib")
    else ()
      set_property (TARGET GLEW_WRAP APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${source_dir}/lib/Release/x64/glew32s.lib")
    endif ()
    set_property (TARGET GLEW_WRAP APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS GLEW_STATIC=1)
    add_library (GLEW::GLEW ALIAS GLEW_WRAP)
  endif (hasParent)
endif (WIN32)
