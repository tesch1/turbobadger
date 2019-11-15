#################################################################################
#
# Functions to add resource files
#
define_property (SOURCE PROPERTY RES_LOCATION
  BRIEF_DOCS "Resource location."
  FULL_DOCS "The location within the resource tree where the file should be put.")

function (add_resources RES_LIST_NAME RES_ROOT_PATH)
  #
  # Add file or directory resources to the variable RES_LIST_NAME
  # The destination of the found resource files will be the relative path to RES_ROOT_PATH
  # A prefix to the destination can be added by specifying a DESTINATION argument.
  # This sets the MACOSX_PACKAGE_LOCATION of the source file to Resources/<destination>
  # It also sets a custom property RES_LOCATION on the source file to <destination>.
  #
  # examples:
  #
  # Add a number of image and text files:
  #   add_resources(RES_FILES "${CMAKE_SOURCE_DIR}/resources" "*.txt" "*.png" "*.svg")
  #
  # Add some font files from default_font to a resource directory "font/":
  #
  #   add_resources(RES_FILES "${CMAKE_SOURCE_DIR}/resources/default_font"
  #                 DESTINATION "font" "*.txt" "*.ttf")
  #
  # Add a resource directory of images
  #
  #   add_resources(RES_FILES "${CMAKE_SOURCE_DIR}/resources-apple" "Images.xcassets")
  #
  set (options )
  set (oneValueArgs DESTINATION)
  set (multiValueArgs )
  cmake_parse_arguments (AR "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  foreach (globby ${AR_UNPARSED_ARGUMENTS})

    # find file list
    set (RES_FILES_ "")
    if (IS_DIRECTORY "${RES_ROOT_PATH}/${globby}")
      set (RES_FILES_ "${RES_ROOT_PATH}/${globby}")
    else ()
      file (GLOB_RECURSE RES_FILES_ "${RES_ROOT_PATH}/${globby}")
    endif ()

    # make sure we found something
    if ("" STREQUAL "${RES_FILES_}")
      message (FATAL_ERROR "No matching resources found: '${RES_ROOT_PATH}' / '${globby}'")
    else ()
      list (APPEND ${RES_LIST_NAME} ${RES_FILES_})
    endif ()

    # add the files/dirs to the RES_LIST_NAME and set the properties
    foreach (RES_FILE IN LISTS RES_FILES_)

      # Get the relative path from the data-folder to the particular file
      file (RELATIVE_PATH RES_PATH ${RES_ROOT_PATH} ${RES_FILE})
      get_filename_component (RES_DIR ${RES_PATH} DIRECTORY)

      # Set it's location inside the app package (under Resources)
      set_property (SOURCE ${RES_FILE} PROPERTY MACOSX_PACKAGE_LOCATION "Resources/${AR_DESTINATION}${RES_DIR}")
      set_property (SOURCE ${RES_FILE} PROPERTY RES_LOCATION "${AR_DESTINATION}${RES_DIR}")

      #message ("${RES_FILE} -> '${AR_DESTINATION}' '${RES_DIR}'")
    endforeach ()
  endforeach ()

  set (${RES_LIST_NAME} ${${RES_LIST_NAME}} PARENT_SCOPE)

endfunction ()

function (fixup_resources RES_LIST_NAME)
  #
  # example: fixup_resources(RES_FILES)
  #
  foreach (RES_FILE IN LISTS ${RES_LIST_NAME})
    # Get the original root-absolute pah
    get_property (RES_LOCATION SOURCE ${RES_FILE} PROPERTY RES_LOCATION)
    get_property (MPL SOURCE ${RES_FILE} PROPERTY MACOSX_PACKAGE_LOCATION)
    #message ("${RES_FILE} -> ${RES_LOCATION} / ${MPL}")
  endforeach ()
endfunction ()

