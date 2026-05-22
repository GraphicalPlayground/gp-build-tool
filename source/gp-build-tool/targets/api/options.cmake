# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Mark the current target as header-only.
# @remarks An INTERFACE library is created instead of a compiled library.
#          No source files are compiled; all include directories and usage requirements
#          are INTERFACE-propagated. gpbt_checkForEmptySources will not add a dummy .cpp.
function(gpbt_setHeaderOnly)
  gpbt_checkInTargetDefinition("gpbt_setHeaderOnly")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetIsHeaderOnly TRUE)
  gpbt_log(VERBOSE "Target marked as header-only (INTERFACE library)")
endfunction()

# @brief Enable Unity Build for the current target.
# @remarks CMake batches source files into unity translation units (UNITY_BUILD_BATCH_SIZE=16).
#          This can significantly speed up builds for large targets at the cost of hiding
#          missing include guards or ODR violations.
function(gpbt_enableUnityBuild)
  gpbt_checkInTargetDefinition("gpbt_enableUnityBuild")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetEnableUnityBuild TRUE)
  gpbt_log(VERBOSE "Enabled Unity Build for target")
endfunction()

# @brief Disable strict warnings for the current target.
# @remarks By default all targets are compiled with -Wall -Wextra -Werror (or MSVC /W4 /WX).
#          Use this for third-party targets or generated code that does not pass strict checks.
function(gpbt_disableStrictWarnings)
  gpbt_checkInTargetDefinition("gpbt_disableStrictWarnings")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetEnableStrictWarnings FALSE)
  gpbt_log(VERBOSE "Disabled strict warnings for target")
endfunction()

# @brief Force the current module target to be built as a static library, regardless of
#        the global BUILD_SHARED_LIBS / GPBT_IS_MONOLITHIC setting.
function(gpbt_setStatic)
  gpbt_checkInTargetDefinition("gpbt_setStatic")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetIsBuildShared FALSE)
  gpbt_log(VERBOSE "Target forced to build as STATIC library")
endfunction()

# @brief Force the current module target to be built as a shared library, regardless of
#        the global BUILD_SHARED_LIBS / GPBT_IS_MONOLITHIC setting.
function(gpbt_setShared)
  gpbt_checkInTargetDefinition("gpbt_setShared")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetIsBuildShared TRUE)
  gpbt_log(VERBOSE "Target forced to build as SHARED library")
endfunction()

# @brief Enable the test suite for the current target.
# @param[in] FRAMEWORK (optional) Per-target framework override: GOOGLETEST | CATCH2 | CUSTOM.
#   If omitted the global GPBT_TEST_FRAMEWORK is used.
# @remarks Sources are auto-discovered from tests/ next to the target's CMakeLists.txt.
function(gpbt_enableTests)
  gpbt_checkInTargetDefinition("gpbt_enableTests")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  cmake_parse_arguments(_ET "" "FRAMEWORK" "" ${ARGN})

  gpbt_setScopedProperty(_targetEnableTests TRUE)

  if(_ET_FRAMEWORK)
    string(TOUPPER "${_ET_FRAMEWORK}" _normalizedFramework)
    gpbt_setScopedProperty(_targetTestFramework "${_normalizedFramework}")
    gpbt_log(VERBOSE "Tests enabled for target with per-target framework: ${_normalizedFramework}")
  else()
    gpbt_setScopedProperty(_targetTestFramework "")
    gpbt_log(VERBOSE "Tests enabled for target (inherits global GPBT_TEST_FRAMEWORK)")
  endif()
endfunction()

# @brief Enable benchmarks for the current target (reserved for future per-target benchmark integration).
function(gpbt_enableBenchmarks)
  gpbt_checkInTargetDefinition("gpbt_enableBenchmarks")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetEnableBenchmarks TRUE)
  gpbt_log(VERBOSE "Benchmarks enabled for target")
endfunction()

# @brief Enable examples for the current target (reserved for future per-target example integration).
function(gpbt_enableExamples)
  gpbt_checkInTargetDefinition("gpbt_enableExamples")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetEnableExamples TRUE)
  gpbt_log(VERBOSE "Examples enabled for target")
endfunction()

# @brief Add a precompiled header to the current target.
# @param[in] headerFile Path to the header file (absolute or relative to target location).
# @remarks The PCH is applied PRIVATE so it does not leak through public include directories.
function(gpbt_addPrecompiledHeader headerFile)
  gpbt_checkInTargetDefinition("gpbt_addPrecompiledHeader")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_getScopedProperty(_targetLocation targetLocation)
  if(NOT IS_ABSOLUTE "${headerFile}")
    set(headerFile "${targetLocation}/${headerFile}")
  endif()
  get_filename_component(headerFile "${headerFile}" ABSOLUTE)
  gpbt_appendScopedProperty(_targetPreCompiledHeaders "${headerFile}")
  gpbt_log(VERBOSE "Added precompiled header '${headerFile}'")
endfunction()
