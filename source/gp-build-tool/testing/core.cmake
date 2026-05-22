# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/testing/frameworks/googletest)
include(gp-build-tool/testing/frameworks/catch2)
include(gp-build-tool/testing/generate)

# @brief Bootstrap all test frameworks required by the current build.
# @remarks Called by gpbt_endBuildTool() at the start of CONFIGURATION phase, before thirdparty
#          resolution.  For each registered target that called gpEnableTests(), this function
#          determines the effective framework (per-target FRAMEWORK override → global
#          GPBT_TEST_FRAMEWORK) and registers its source package when the project has not
#          already declared its own version of that package.
#
#          Logging: always emits an INFO summary so the active framework is visible in the
#          configure output — no GPBT_LOG_VERBOSE_ENABLED required.
#
#          User-override: declaring gpStartThirdparty("googletest") or
#          gpStartThirdparty("catch2") anywhere before gpEndBuildTool() causes the built-in
#          registration to be skipped.
#
#          CUSTOM: set GPBT_TEST_FRAMEWORK=CUSTOM (or pass FRAMEWORK CUSTOM to gpEnableTests())
#          and GPBT_TEST_FRAMEWORK_CUSTOM_TARGET to the CMake target name.
function(gpbt_initTestingSystem)
  gpbt_logSection("Initializing test framework")

  # Scan all registered targets for those that opted in via gpEnableTests().
  # For each such target collect the effective framework name (per-target or global).
  gpbt_getProperty(GPBT_TARGETS _allTargets)

  set(_frameworksNeeded "")
  set(_testTargetCount 0)

  foreach(_t IN LISTS _allTargets)
    gpbt_pushScope("${_t}")
    gpbt_getScopedProperty(_targetEnableTests  _testEnabled)
    gpbt_getScopedProperty(_targetTestFramework _perTargetFW)
    gpbt_getScopedProperty(_targetName         _name)
    gpbt_popScope()

    if(NOT _testEnabled)
      continue()
    endif()

    math(EXPR _testTargetCount "${_testTargetCount} + 1")

    # Effective framework: per-target override → global default
    if(_perTargetFW)
      set(_effectiveFW "${_perTargetFW}")
    else()
      set(_effectiveFW "${GPBT_TEST_FRAMEWORK}")
    endif()

    if(_effectiveFW STREQUAL "NONE" OR NOT _effectiveFW)
      gpbt_log(WARNING "Target '${_name}' called gpEnableTests() but GPBT_TEST_FRAMEWORK is NONE and no per-target FRAMEWORK was specified — test target will not be generated")
      continue()
    endif()

    list(APPEND _frameworksNeeded "${_effectiveFW}")
    gpbt_log(VERBOSE "  ${_name}: framework = ${_effectiveFW}")
  endforeach()

  if(_testTargetCount EQUAL 0)
    gpbt_log(INFO "No targets called gpEnableTests() — test framework not registered")
    return()
  endif()

  list(REMOVE_DUPLICATES _frameworksNeeded)

  # Enable CTest before any add_test() calls.
  enable_testing()

  gpbt_getProperty(GPBT_THIRDPARTY_PACKAGES _existing)

  foreach(_fw IN LISTS _frameworksNeeded)
    if(_fw STREQUAL "GOOGLETEST")
      if("googletest" IN_LIST _existing)
        gpbt_log(INFO "  GoogleTest  →  user-declared package")
      else()
        gpbt_registerGoogleTestFramework()
      endif()

    elseif(_fw STREQUAL "CATCH2")
      if("catch2" IN_LIST _existing)
        gpbt_log(INFO "  Catch2      →  user-declared package")
      else()
        gpbt_registerCatch2Framework()
      endif()

    elseif(_fw STREQUAL "CUSTOM")
      if(NOT GPBT_TEST_FRAMEWORK_CUSTOM_TARGET)
        gpbt_log(FATAL "GPBT_TEST_FRAMEWORK=CUSTOM but GPBT_TEST_FRAMEWORK_CUSTOM_TARGET is not set. Set it to the CMake target name your test framework provides.")
      endif()
      gpbt_log(INFO "  CUSTOM      →  '${GPBT_TEST_FRAMEWORK_CUSTOM_TARGET}'")

    else()
      gpbt_log(WARNING "Unknown test framework '${_fw}'. Valid values: NONE | GOOGLETEST | CATCH2 | CUSTOM")
    endif()
  endforeach()

  gpbt_log(INFO "${_testTargetCount} target(s) will generate test executables")
endfunction()
