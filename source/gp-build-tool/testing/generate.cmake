# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# @brief Create a CTest-registered test executable for a registered GPBT module.
# @param[in] cleanName The clean (snake_case) name of the module whose tests to generate.
# @remarks Sources are globbed recursively from <targetLocation>/tests/.
#          The effective test framework is resolved as: per-target FRAMEWORK override set via
#          gpEnableTests(FRAMEWORK <x>) → global GPBT_TEST_FRAMEWORK.
#          The function is a no-op during REGISTRATION phase or when no test sources exist.
function(gpbt_generateTestTarget cleanName)
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_pushScope("${cleanName}")
  gpbt_getScopedProperty(_targetExportName   _mainExportName)
  gpbt_getScopedProperty(_targetLocation     _location)
  gpbt_getScopedProperty(_targetOutputName   _outputName)
  gpbt_getScopedProperty(_targetCustomFolder _folder)
  gpbt_getScopedProperty(_targetTestFramework _perTargetFW)
  gpbt_popScope()

  # Effective framework: per-target override → global default
  if(_perTargetFW)
    set(_framework "${_perTargetFW}")
  else()
    set(_framework "${GPBT_TEST_FRAMEWORK}")
  endif()

  if(_framework STREQUAL "NONE" OR NOT _framework)
    return()
  endif()

  set(_extraArgs "")
  if(GPBT_CONFIGURE_DEPENDS)
    list(APPEND _extraArgs CONFIGURE_DEPENDS)
  endif()

  file(GLOB_RECURSE _testSources ${_extraArgs}
    "${_location}/tests/*.cpp"
    "${_location}/tests/*.cxx"
    "${_location}/tests/*.cc"
    "${_location}/tests/*.c"
  )

  if(NOT _testSources)
    gpbt_log(VERBOSE "Testing: no sources in '${_location}/tests/' for '${cleanName}', skipping test target")
    return()
  endif()

  set(_testExportName "gp_${cleanName}_tests")
  set(_testOutputName "${_outputName}-tests")

  add_executable(${_testExportName} ${_testSources})

  set_target_properties(${_testExportName} PROPERTIES
    OUTPUT_NAME     "${_testOutputName}"
    CXX_STANDARD    23
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS  OFF
    FOLDER          "tests/${_folder}"
  )

  # Tests have access to the module's PUBLIC interface (headers + transitive deps).
  target_link_libraries(${_testExportName} PRIVATE ${_mainExportName})

  # Link against the resolved framework target.
  if(_framework STREQUAL "GOOGLETEST")
    target_link_libraries(${_testExportName} PRIVATE gp_thirdparty_googletest)
  elseif(_framework STREQUAL "CATCH2")
    target_link_libraries(${_testExportName} PRIVATE gp_thirdparty_catch2)
  elseif(_framework STREQUAL "CUSTOM")
    target_link_libraries(${_testExportName} PRIVATE "${GPBT_TEST_FRAMEWORK_CUSTOM_TARGET}")
  endif()

  add_test(NAME "${_testExportName}" COMMAND ${_testExportName})

  gpbt_log(SUCCESS "Created test target '${_testExportName}' [${_framework}] for '${cleanName}'")
endfunction()
