# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)

# @brief Validate that the caller is inside a gpStartThirdparty / gpEndThirdparty block.
# @param[in] functionName Name of the calling function (for diagnostics).
macro(gpbt_checkInThirdpartyDefinition functionName)
  gpbt_getProperty(GPBT_IS_IN_THIRDPARTY_DEFINITION _gpbt_inThirdparty)
  if(NOT _gpbt_inThirdparty)
    gpbt_log(FATAL "${functionName} called outside of a gpStartThirdparty / gpEndThirdparty block")
  endif()
endmacro()

# @brief Open a thirdparty package definition.
# @param[in] packageName  Human-readable name (e.g. "sdl2", "PhysX", "nlohmann-json").
# @param[in] VERSION      Version string (e.g. "2.30.3"). Used for logging and cache-key disambiguation.
# @remarks Must be paired with gpEndThirdparty().
function(gpbt_startThirdparty packageName)
  # Must be inside a build tool session
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED _hasBuildTool)
  if(NOT _hasBuildTool)
    gpbt_log(FATAL "gpStartThirdparty called outside of a gpStartBuildTool / gpEndBuildTool block")
  endif()

  # Must not be nested inside a target definition
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION _inTarget)
  if(_inTarget)
    gpbt_log(FATAL "gpStartThirdparty cannot be called inside a target definition")
  endif()

  # Must not be nested inside another thirdparty definition
  gpbt_getProperty(GPBT_IS_IN_THIRDPARTY_DEFINITION _inThirdparty)
  if(_inThirdparty)
    gpbt_log(FATAL "gpStartThirdparty cannot be nested: already inside a thirdparty definition")
  endif()

  # Parse optional VERSION keyword
  cmake_parse_arguments(_TP "" "VERSION" "" ${ARGN})
  set(_version "${_TP_VERSION}")
  if(NOT _version)
    set(_version "unversioned")
  endif()

  # Derive a clean, stable scope key from the package name (snake_case)
  gpbt_convertCase(snake_case "${packageName}" _cleanName)

  # Verify uniqueness
  gpbt_getProperty(GPBT_THIRDPARTY_PACKAGES _existingPackages)
  if(_cleanName IN_LIST _existingPackages)
    gpbt_log(FATAL "Thirdparty package '${packageName}' (clean: '${_cleanName}') is already registered")
  endif()

  # Enter the package scope
  gpbt_pushScope("thirdparty_${_cleanName}")

  gpbt_setScopedProperty(_packageName "${packageName}")
  gpbt_setScopedProperty(_packageCleanName "${_cleanName}")
  gpbt_setScopedProperty(_packageVersion "${_version}")
  gpbt_setScopedProperty(_packageBinaryCount 0)
  gpbt_setScopedProperty(_packageSourceUrl "")
  gpbt_setScopedProperty(_packageSourceHash "")
  gpbt_setScopedProperty(_packageSourceTarget "")
  gpbt_setScopedProperty(_packageCmakeArgs "")
  gpbt_setScopedProperty(_packageRequiredPlatforms "")
  gpbt_setScopedProperty(_packageRequiredCompilers "")
  gpbt_setScopedProperty(_packageMode "")
  gpbt_setScopedProperty(_packageStripStrictWarnings FALSE)
  gpbt_setScopedProperty(_packageSystemMode "")
  gpbt_setScopedProperty(_packageSystemFindPackageName "")
  gpbt_setScopedProperty(_packageSystemFindPackageComponents "")
  gpbt_setScopedProperty(_packageSystemFindPackageTarget "")
  gpbt_setScopedProperty(_packageSystemFrameworks "")
  gpbt_setScopedProperty(_packageSystemWindowsSdkLibs "")

  gpbt_setProperty(GPBT_IS_IN_THIRDPARTY_DEFINITION TRUE)
  gpbt_log(VERBOSE "Registered thirdparty package: ${packageName} ${_version}")
endfunction()

# @brief Close the current thirdparty package definition and register it for resolution.
# @remarks Must be paired with gpStartThirdparty().
function(gpbt_endThirdparty)
  gpbt_checkInThirdpartyDefinition("gpbt_endThirdparty")

  gpbt_getScopedProperty(_packageName    packageName)
  gpbt_getScopedProperty(_packageCleanName cleanName)

  gpbt_popScope()
  gpbt_setProperty(GPBT_IS_IN_THIRDPARTY_DEFINITION FALSE)
  gpbt_appendProperty(GPBT_THIRDPARTY_PACKAGES "${cleanName}")

  gpbt_log(VERBOSE "Thirdparty package '${packageName}' registered successfully")
endfunction()
