#
# CMake file for turbobadger dependencies
#

cmake_minimum_required (VERSION 3.4.3)
project (turbobadger_thirdparty NONE)

include (ExternalProject)
get_directory_property (hasParent PARENT_DIRECTORY)

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
endif (hasParent)

if (TB_BUILD_GLFW)
  # Download glfw
  ExternalProject_Add (GLFWEXT
    PREFIX GLFWEXT
    URL https://github.com/glfw/glfw/archive/3.3.tar.gz
    URL_HASH MD5=5be03812f5d109817e6558c3fab7bbe1
    DOWNLOAD_DIR "${DOWNLOAD_DIR}"
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

if (TB_BUILD_SDL2)
  set (SDL_VERSION 2.0.5)
  set (SDL_VERSION_HASH d4055424d556b4a908aa76fad63abd3c)
  set (SDL_VERSION 2.0.10)
  set (SDL_VERSION_HASH 5a2114f2a6f348bdab5bf52b994811db)

  if (ANDROID)
    ExternalProject_Add (sdl2X
      PREFIX sdl2X
      # latest development version from HG
      #URL https://hg.libsdl.org/SDL/archive/tip.tar.bz2
      # some random (fixed) version from HG
      URL https://hg.libsdl.org/SDL/archive/d6decc5d2464.tar.bz2
      URL_HASH MD5=c14f6b8da34e895990d01915bc9d3a82
      #URL https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz
      #URL_HASH "MD5=${SDL_VERSION_HASH}"
      DOWNLOAD_DIR "${DOWNLOAD_DIR}"
      UPDATE_COMMAND ""
      PATCH_COMMAND ""
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ""
      LOG_DOWNLOAD ON)
  else ()
    ExternalProject_Add (sdl2X
      PREFIX sdl2X
      #HG_REPOSITORY https://hg.libsdl.org/SDL
      URL https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz
      URL_HASH "MD5=${SDL_VERSION_HASH}"
      DOWNLOAD_DIR "${DOWNLOAD_DIR}"
      UPDATE_COMMAND ""
      PATCH_COMMAND ""
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ""
      LOG_DOWNLOAD ON)
  endif ()
  ExternalProject_Get_Property (sdl2X source_dir)

  if (hasParent)
    #set (SDL_CMAKE_DEBUG_POSTFIX "\"\"" CACHE STRING "Name suffix for debug builds" FORCE)
    if (ANDROID)
      set (SDL_SHARED   ON  CACHE BOOL "" FORCE)
      set (SDL_STATIC   OFF CACHE BOOL "" FORCE)
      # sdl2-2.0.10 needs cpufeatures
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
    set (SDL_RENDER     OFF CACHE BOOL "" FORCE)
    #set (SDL_HAPTIC     OFF CACHE BOOL "" FORCE)
    #set (SDL_JOYSTICK   OFF CACHE BOOL "" FORCE)
    add_subdirectory ("${source_dir}" "${CMAKE_CURRENT_BINARY_DIR}/sdl2X_binary_dir" EXCLUDE_FROM_ALL)
    add_library (SDL2-interface INTERFACE IMPORTED GLOBAL)
    if (SDL_VERSION VERSION_LESS "2.0.10")
      set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
        "${CMAKE_CURRENT_BINARY_DIR}/sdl2X_binary_dir/include;${source_dir}/include")
    endif (SDL_VERSION VERSION_LESS "2.0.10")
    if (WIN32)
      target_link_libraries (SDL2-interface INTERFACE SDL2main)
    endif (WIN32)
    if (ANDROID)
      if (NOT TARGET SDL2)
        message (FATAL_ERROR "Didn't create 'SDL2' target")
      endif ()
      target_link_libraries (SDL2-interface INTERFACE SDL2)
      #target_link_libraries (SDL2-interface INTERFACE cpufeatures)
      #set_target_properties (SDL2-static PROPERTIES DEBUG_POSTFIX "")
    else ()
      if (NOT TARGET SDL2-static)
        message (FATAL_ERROR "Didn't create 'SDL2-static' target")
      endif ()
      target_link_libraries (SDL2-interface INTERFACE SDL2-static)
    endif ()
  endif (hasParent)
elseif (TB_BACKEND STREQUAL SDL2 AND hasParent)
  #
  # Not building SDL2, so try to find it
  #
  add_library (SDL2-interface INTERFACE IMPORTED GLOBAL)
  if (EMSCRIPTEN)
    if (${CMAKE_VERSION} VERSION_LESS "3.8.0")
      set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_COMPILE_OPTIONS -s USE_SDL=2)
      set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_LINK_OPTIONS    -s USE_SDL=2)
    else ()
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s USE_SDL=2" PARENT_SCOPE)
    endif ()
  else ()
    message ("Looking for SDL2 with find_package()...")
    find_package (SDL2 2.0.10)
    if (NOT SDL2_FOUND)
      message ("Looking for SDL2 with find_library()...")
      # CMAKE_FIND_ROOT_PATH_BOTH is needed for finding local iOS FW in CMAKE_FIND_FRAMEWORK
      find_library (SDL2_LIBRARY SDL2 CMAKE_FIND_ROOT_PATH_BOTH)
      find_path (SDL2_INCLUDE_DIR "SDL.h" PATH_SUFFIXES "SDL2" CMAKE_FIND_ROOT_PATH_BOTH)
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
      # look for SDL2
      if (SDL2_LIBRARY AND SDL2_INCLUDE_DIR AND OPENGL_FOUND)
        add_library (SDL2 INTERFACE IMPORTED GLOBAL)
        set_property (TARGET SDL2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${SDL2_LIBRARY} OpenGL::GL)
        set_property (TARGET SDL2 APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${SDL2_INCLUDE_DIR})
        set (SDL2_FOUND TRUE)
        message (STATUS "SDL2_LIBRARY    : ${SDL2_LIBRARY}")
        message (STATUS "SDL2_INCLUDE_DIR: ${SDL2_INCLUDE_DIR}")
      else ()
        message (FATAL_ERROR "SDL2 NOT Found: '${SDL2_LIBRARY}' '${SDL2_INCLUDE_DIR}' '${OPENGL_FOUND}'")
      endif ()
    endif (NOT SDL2_FOUND)
    if (NOT SDL2_FOUND)
      message ("Looking for SDL2 with pkg_search_module()...")
      include (FindPkgConfig)
      pkg_search_module (SDL2 REQUIRED sdl2)
      #set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${SDL2_LIBRARY})
      #set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${SDL2_INCLUDE_DIR})
    endif (NOT SDL2)
    if (NOT SDL2_FOUND)
      message (FATAL_ERROR "Unable to find SDL2: ${SDL2}, ${SDL2_FOUND}")
    endif ()
    set_property (TARGET SDL2-interface APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS SDL_FRAMEWORK=1)
    target_link_libraries (SDL2-interface INTERFACE SDL2)
  endif (EMSCRIPTEN)
endif (TB_BUILD_SDL2)

if (TB_BUILD_FREETYPE)
  #
  # freetype
  #
  ExternalProject_Add (freetypeX
    PREFIX freetypeX
    URL http://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz
    URL_HASH MD5=3adb0e35d3c100c456357345ccfa8056
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
    set (DISABLE_FORCE_DEBUG_POSTFIX TRUE CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_ZLIB ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_BZip2 ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_PNG ON CACHE STRING "" FORCE)
    set (CMAKE_DISABLE_FIND_PACKAGE_HarfBuzz ON CACHE STRING "" FORCE)
    set (FREETYPE_NO_DIST ON CACHE STRING "" FORCE)
    add_subdirectory ("${FREETYPE_SRC_DIR}"
      "${CMAKE_CURRENT_BINARY_DIR}/freetype_build"
      EXCLUDE_FROM_ALL)
    set_property (TARGET freetype APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
      $<TARGET_PROPERTY:freetype,INCLUDE_DIRECTORIES>)
  endif (hasParent)
elseif (EMSCRIPTEN AND TB_FONT_RENDERER STREQUAL FREETYPE AND hasParent)
  add_library (freetype INTERFACE IMPORTED GLOBAL)
  set_property (TARGET freetype APPEND PROPERTY INTERFACE_COMPILE_OPTIONS -s USE_FREETYPE=1)
  set_property (TARGET freetype APPEND PROPERTY INTERFACE_LINK_OPTIONS    -s USE_FREETYPE=1)
endif (TB_BUILD_FREETYPE)

if (WIN32)
  ExternalProject_Add (GLEWX
    PREFIX GLEWX
    URL "https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0-win32.zip"
    URL_HASH MD5=32a72e6b43367db8dbea6010cd095355
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
    add_library (GLEW INTERFACE IMPORTED GLOBAL)
    set_property (TARGET GLEW APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${source_dir}/include")
    set_property (TARGET GLEW APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${source_dir}/lib/Release/Win32/glew32s.lib")
    set_property (TARGET GLEW APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS GLEW_STATIC=1)
  endif (hasParent)
endif (WIN32)
