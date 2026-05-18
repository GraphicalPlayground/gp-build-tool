# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Restrict this package to a set of platforms; it is silently skipped on all others.
# @param[in] ... GP platform tokens: Windows | macOS | iOS | Android | Linux | FreeBSD
# @remarks If called multiple times, the lists are merged (union). If never called, the package
#          is considered valid on all platforms.
function(gpbt_thirdpartyRequiresPlatforms)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyRequiresPlatforms")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartyRequiresPlatforms: at least one platform token is required")
  endif()

  foreach(_platform IN LISTS ARGN)
    gpbt_appendScopedProperty(_packageRequiredPlatforms "${_platform}")
  endforeach()

  gpbt_log(VERBOSE "  Required platforms: ${ARGN}")
endfunction()

# @brief Restrict this package to a set of compilers; it is silently skipped on all others.
# @param[in] ... GP compiler tokens: MSVC | Clang | GCC
# @remarks If called multiple times, the lists are merged (union). If never called, the package
#          is considered valid for all compilers.
function(gpbt_thirdpartyRequiresCompilers)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyRequiresCompilers")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartyRequiresCompilers: at least one compiler token is required")
  endif()

  foreach(_compiler IN LISTS ARGN)
    gpbt_appendScopedProperty(_packageRequiredCompilers "${_compiler}")
  endforeach()

  gpbt_log(VERBOSE "  Required compilers: ${ARGN}")
endfunction()
