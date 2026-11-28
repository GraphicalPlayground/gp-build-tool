# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# Valid GP platform tokens accepted by gpThirdpartySetSourcesByPlatform().
set(GPBT_THIRDPARTY_AVAILABLE_PLATFORMS "Windows;macOS;iOS;Android;Linux;FreeBSD")

# @brief Declare source files that GPBT should compile as part of a thirdparty dependency.
# @param[in] ... Source file paths (relative to the thirdparty source directory, absolute, or generator expressions).
# @remarks Repeated calls accumulate entries; duplicate entries are ignored.
#          Only used when GPBT generates the target itself (packages without an upstream CMake target).
# @example
#   gpThirdpartySetSources(
#     imgui.cpp
#     imgui_draw.cpp
#     imgui_tables.cpp
#     imgui_widgets.cpp
#   )
function(gpbt_thirdpartySetSources)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetSources")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetSources: at least one source file is required")
  endif()

  gpbt_getScopedProperty(_packageSources _existing)
  foreach(_src IN LISTS ARGN)
    if(NOT _src IN_LIST _existing)
      list(APPEND _existing "${_src}")
      gpbt_appendScopedProperty(_packageSources "${_src}")
    endif()
  endforeach()

  gpbt_log(VERBOSE "  Sources: ${ARGN}")
endfunction()

# @brief Declare platform-specific source files for a thirdparty dependency.
# @param[in] ... Platform sections keyed by GP platform tokens:
#                Windows | macOS | iOS | Android | Linux | FreeBSD
# @remarks Repeated calls accumulate entries per platform; duplicate entries are ignored.
#          At resolution time, only the sources matching GPBT_CURRENT_PLATFORM are compiled.
# @example
#   gpThirdpartySetSourcesByPlatform(
#     Windows
#       src/platform_win32.cpp
#     Linux
#       src/platform_linux.cpp
#     macOS
#       src/platform_macos.mm
#   )
function(gpbt_thirdpartySetSourcesByPlatform)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetSourcesByPlatform")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetSourcesByPlatform: at least one platform section is required")
  endif()

  cmake_parse_arguments(_PS "" "" "${GPBT_THIRDPARTY_AVAILABLE_PLATFORMS}" ${ARGN})

  if(_PS_UNPARSED_ARGUMENTS)
    gpbt_log(FATAL "gpThirdpartySetSourcesByPlatform: unexpected arguments '${_PS_UNPARSED_ARGUMENTS}'. Expected platform tokens: ${GPBT_THIRDPARTY_AVAILABLE_PLATFORMS}")
  endif()

  set(_addedAny FALSE)
  foreach(_platform IN LISTS GPBT_THIRDPARTY_AVAILABLE_PLATFORMS)
    if(_PS_${_platform})
      set(_addedAny TRUE)
      gpbt_getScopedProperty(_packagePlatformSources_${_platform} _existing)
      foreach(_src IN LISTS _PS_${_platform})
        if(NOT _src IN_LIST _existing)
          list(APPEND _existing "${_src}")
          gpbt_appendScopedProperty(_packagePlatformSources_${_platform} "${_src}")
        endif()
      endforeach()
      gpbt_log(VERBOSE "  Platform sources [${_platform}]: ${_PS_${_platform}}")
    endif()
  endforeach()

  if(NOT _addedAny)
    gpbt_log(FATAL "gpThirdpartySetSourcesByPlatform: no source files specified for any platform")
  endif()
endfunction()
