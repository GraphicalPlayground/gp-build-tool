# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Pass extra CMake cache variables to this package when building from source.
# @param[in] ... KEY=VALUE pairs forwarded verbatim to the subproject's CMake configuration.
# @remarks Only used in SOURCE resolution mode. Ignored when the package is resolved as a prebuilt
#          binary or a system package. Can be called multiple times; arguments accumulate.
# @example
#   gpThirdpartySetCMakeArgs(
#       SDL_SHARED=OFF
#       SDL_STATIC=ON
#       SDL_TEST=OFF
#   )
function(gpbt_thirdpartySetCMakeArgs)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetCMakeArgs")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetCMakeArgs: at least one KEY=VALUE argument is required")
  endif()

  foreach(_arg IN LISTS ARGN)
    gpbt_appendScopedProperty(_packageCmakeArgs "${_arg}")
  endforeach()

  gpbt_log(VERBOSE "  CMake args: ${ARGN}")
endfunction()
