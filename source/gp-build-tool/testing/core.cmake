# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/testing/frameworks/googletest)
include(gp-build-tool/testing/frameworks/catch2)
include(gp-build-tool/testing/generate)

# @brief Bootstrap the test framework for the current build.
# @remarks Called by gpbt_endBuildTool() at the start of CONFIGURATION phase, before thirdparty
#          resolution. When GPBT_TEST_FRAMEWORK is GOOGLETEST or CATCH2, this function registers
#          the built-in framework package unless the project has already declared its own package
#          with that name (gp::thirdparty::googletest / gp::thirdparty::catch2). After the
#          framework package is registered, the normal thirdparty resolution loop will fetch and
#          build it alongside all other packages.
#
#          User-override mechanism:
#            If a project declares its own googletest/catch2 via gpStartThirdparty("googletest")
#            before gpEndBuildTool(), the built-in registration is skipped and the project's
#            version is used instead.
#
#          CUSTOM framework:
#            Set GPBT_TEST_FRAMEWORK=CUSTOM and GPBT_TEST_FRAMEWORK_CUSTOM_TARGET to the
#            CMake target name of the framework to link against. The target must already exist
#            when CONFIGURATION phase begins (i.e., declared via gpStartThirdparty / find_package
#            in the top-level CMakeLists.txt before gpEndBuildTool()).
function(gpbt_initTestingSystem)
  if(GPBT_TEST_FRAMEWORK STREQUAL "NONE")
    return()
  endif()

  # Only bootstrap if at least one target has actually called gpEnableTests().
  # This avoids downloading a test framework for a project that set the option
  # globally but never uses it for any module.
  gpbt_getProperty(GPBT_TARGETS _allTargets)
  set(_hasTestTargets FALSE)
  foreach(_t IN LISTS _allTargets)
    gpbt_pushScope("${_t}")
    gpbt_getScopedProperty(_targetEnableTests _testEnabled)
    gpbt_popScope()
    if(_testEnabled)
      set(_hasTestTargets TRUE)
      break()
    endif()
  endforeach()

  if(NOT _hasTestTargets)
    gpbt_log(VERBOSE "Testing: GPBT_TEST_FRAMEWORK=${GPBT_TEST_FRAMEWORK} but no target called gpEnableTests(), framework not registered")
    return()
  endif()

  # CTest requires enable_testing() to be called before any add_test() calls.
  enable_testing()

  gpbt_getProperty(GPBT_THIRDPARTY_PACKAGES _existing)

  if(GPBT_TEST_FRAMEWORK STREQUAL "GOOGLETEST")
    if("googletest" IN_LIST _existing)
      gpbt_log(INFO "Testing: using user-declared 'googletest' thirdparty package")
    else()
      gpbt_registerGoogleTestFramework()
    endif()

  elseif(GPBT_TEST_FRAMEWORK STREQUAL "CATCH2")
    if("catch2" IN_LIST _existing)
      gpbt_log(INFO "Testing: using user-declared 'catch2' thirdparty package")
    else()
      gpbt_registerCatch2Framework()
    endif()

  elseif(GPBT_TEST_FRAMEWORK STREQUAL "CUSTOM")
    if(NOT GPBT_TEST_FRAMEWORK_CUSTOM_TARGET)
      gpbt_log(FATAL "GPBT_TEST_FRAMEWORK=CUSTOM but GPBT_TEST_FRAMEWORK_CUSTOM_TARGET is not set. Set it to the CMake target name your test framework provides.")
    endif()
    gpbt_log(INFO "Testing: using custom framework target '${GPBT_TEST_FRAMEWORK_CUSTOM_TARGET}'")

  else()
    gpbt_log(WARNING "Unknown GPBT_TEST_FRAMEWORK value: '${GPBT_TEST_FRAMEWORK}'. Valid values: NONE | GOOGLETEST | CATCH2 | CUSTOM")
  endif()
endfunction()
