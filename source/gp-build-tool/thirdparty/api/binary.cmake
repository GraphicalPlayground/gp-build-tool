# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Declare a prebuilt binary archive for a specific platform / compiler combination.
# @param[in] PLATFORMS  Space-separated GP platform tokens to match (empty = any platform).
#                        Tokens: Windows | macOS | iOS | Android | Linux | FreeBSD
# @param[in] COMPILERS  Space-separated GP compiler tokens to match (empty = any compiler).
#                        Tokens: MSVC | Clang | GCC
# @param[in] URL        Download URL of the prebuilt archive (zip or tar.gz).
# @param[in] HASH       CMake hash string (e.g. "SHA256=abc123...").
# @remarks
#   The archive must follow the GP binary layout convention:
#     include/          - public headers
#     lib/              - config-agnostic import libraries (.lib / .a / .so / .dylib)
#     lib/debug/        - Debug-config-specific libraries
#     lib/release/      - All non-Debug config libraries (Development, Profile, Shipping)
#     bin/              - Runtime DLLs / shared objects (Windows: .dll, Linux: .so)
#   Multiple gpThirdpartyBinary() declarations are evaluated in order; the first
#   matching platform + compiler combination wins.
function(gpbt_thirdpartyBinary)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyBinary")

  cmake_parse_arguments(_BIN "" "URL;HASH" "PLATFORMS;COMPILERS" ${ARGN})

  if(NOT _BIN_URL)
    gpbt_log(FATAL "gpThirdpartyBinary: URL is required")
  endif()
  if(NOT _BIN_HASH)
    gpbt_log(WARNING "gpThirdpartyBinary: no HASH provided, archive integrity will not be verified. Add HASH \"SHA256=...\" for production use.")
  endif()

  # Get current binary slot index
  gpbt_getScopedProperty(_packageBinaryCount _binaryCount)
  gpbt_getScopedProperty(_packageCleanName _cleanName)

  # Store binary slot properties in a nested scope
  gpbt_pushScope("thirdparty_${_cleanName}_binary_${_binaryCount}")
  gpbt_setScopedProperty(_binaryPlatforms "${_BIN_PLATFORMS}")
  gpbt_setScopedProperty(_binaryCompilers "${_BIN_COMPILERS}")
  gpbt_setScopedProperty(_binaryUrl "${_BIN_URL}")
  gpbt_setScopedProperty(_binaryHash "${_BIN_HASH}")
  gpbt_popScope()

  # Increment the binary count in the package scope
  math(EXPR _newCount "${_binaryCount} + 1")
  gpbt_setScopedProperty(_packageBinaryCount "${_newCount}")

  gpbt_log(VERBOSE "  Binary slot ${_binaryCount}: platforms=[${_BIN_PLATFORMS}] compilers=[${_BIN_COMPILERS}]")
endfunction()
