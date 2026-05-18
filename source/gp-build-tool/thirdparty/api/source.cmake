# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Declare the source archive for this package.
# @param[in] URL     Archive URL (tar.gz or zip, no git).
# @param[in] HASH    CMake hash string (e.g. "SHA256=abc123...").
# @param[in] TARGET  (Optional) CMake target name exposed by the subproject after FetchContent_MakeAvailable.
#                    Defaults to "<cleanName>::<cleanName>" if omitted.
# @remarks Only one source declaration is allowed per package. Call within gpStartThirdparty / gpEndThirdparty.
function(gpbt_thirdpartySource)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySource")

  cmake_parse_arguments(_SRC "" "URL;HASH;TARGET" "" ${ARGN})

  if(NOT _SRC_URL)
    gpbt_log(FATAL "gpThirdpartySource: URL is required")
  endif()
  if(NOT _SRC_HASH)
    gpbt_log(WARNING "gpThirdpartySource: no HASH provided for '${packageName}', archive integrity will not be verified. Add HASH \"SHA256=...\" for production use.")
  endif()

  # Warn on duplicate source declaration
  gpbt_getScopedProperty(_packageSourceUrl _existingUrl)
  if(_existingUrl)
    gpbt_getScopedProperty(_packageName _name)
    gpbt_log(WARNING "gpThirdpartySource: source URL already declared for '${_name}', overwriting")
  endif()

  gpbt_setScopedProperty(_packageSourceUrl "${_SRC_URL}")
  gpbt_setScopedProperty(_packageSourceHash "${_SRC_HASH}")
  gpbt_setScopedProperty(_packageSourceTarget "${_SRC_TARGET}")

  gpbt_log(VERBOSE "  Source URL: ${_SRC_URL}")
endfunction()
