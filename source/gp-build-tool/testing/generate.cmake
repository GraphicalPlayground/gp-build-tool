# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# @brief Create a CTest-registered test executable for a registered GPBT module.
# @param[in] cleanName The clean (snake_case) name of the module whose tests to generate.
# @remarks Sources are globbed recursively from <targetLocation>/tests/.
#          The test executable is named gp_<cleanName>_tests (export) / gp-<name>-tests (output).
#          It links PRIVATE against the module under test and the active test framework target.
#          The function is a no-op if no test sources are found, or during REGISTRATION phase.
function(gpbt_generateTestTarget cleanName)
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  if(GPBT_TEST_FRAMEWORK STREQUAL "NONE")
    return()
  endif()

  gpbt_pushScope("${cleanName}")
  gpbt_getScopedProperty(_targetExportName  _mainExportName)
  gpbt_getScopedProperty(_targetLocation    _location)
  gpbt_getScopedProperty(_targetOutputName  _outputName)
  gpbt_getScopedProperty(_targetCustomFolder _folder)
  gpbt_popScope()

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

  # Link against the resolved test framework target.
  if(GPBT_TEST_FRAMEWORK STREQUAL "GOOGLETEST")
    target_link_libraries(${_testExportName} PRIVATE gp_thirdparty_googletest)
  elseif(GPBT_TEST_FRAMEWORK STREQUAL "CATCH2")
    target_link_libraries(${_testExportName} PRIVATE gp_thirdparty_catch2)
  elseif(GPBT_TEST_FRAMEWORK STREQUAL "CUSTOM")
    target_link_libraries(${_testExportName} PRIVATE "${GPBT_TEST_FRAMEWORK_CUSTOM_TARGET}")
  endif()

  add_test(NAME "${_testExportName}" COMMAND ${_testExportName})

  gpbt_log(SUCCESS "Created test target '${_testExportName}' for '${cleanName}'")
endfunction()
