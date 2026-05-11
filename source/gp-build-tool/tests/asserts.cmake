# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/config)
include(gp-build-tool/utilities/colors)
include(gp-build-tool/utilities/properties)

# @brief Sets up the test suite by initializing necessary properties and ensuring it is only called once.
function(gpbt_setupTestSuite)
  # Get the current test suite setup status
  gpbt_getProperty(GPBT_TESTS_SETUP_DONE setupDone)
  if(setupDone)
    message(FATAL_ERROR "gpbt_setupTestSuite has already been called. It should only be called once per test suite.")
  endif()

  # Initialize global properties to track test setup status
  gpbt_setProperty(GPBT_TESTS_SETUP_DONE TRUE)

  # Setup global properties to track test statistics
  gpbt_setProperty(GPBT_TESTS_STATS_TOTAL 0)
  gpbt_setProperty(GPBT_TESTS_STATS_PASSED 0)
  gpbt_setProperty(GPBT_TESTS_STATS_FAILED 0)
  gpbt_setProperty(GPBT_TESTS_STATS_SKIPPED 0)
  gpbt_setProperty(GPBT_TESTS_STATS_ASSERTIONS 0)

  # Initialize properties to track failed sections and current section
  gpbt_setProperty(GPBT_TESTS_FAILED_SECTIONS "")
  gpbt_setProperty(GPBT_TESTS_CURRENT_SECTION "")
endfunction()

# @brief Dumps the test statistics summary at the end of the test suite execution.
function(gpbt_dumpTestStats)
  # Retrieve test statistics from global properties
  gpbt_getProperty(GPBT_TESTS_STATS_TOTAL totalTests)
  gpbt_getProperty(GPBT_TESTS_STATS_PASSED passedTests)
  gpbt_getProperty(GPBT_TESTS_STATS_FAILED failedTests)
  gpbt_getProperty(GPBT_TESTS_STATS_SKIPPED skippedTests)
  gpbt_getProperty(GPBT_TESTS_STATS_ASSERTIONS assertions)
  gpbt_getProperty(GPBT_TESTS_FAILED_SECTIONS failedSections)

  # Print the test statistics summary
  message(STATUS "")
  message(STATUS "Test Summary: ${totalTests} Total, ${GPBT_COLOR_FG_GREEN}${passedTests}${GPBT_COLOR_RESET} Passed, ${GPBT_COLOR_FG_RED}${failedTests}${GPBT_COLOR_RESET} Failed, ${GPBT_COLOR_FG_YELLOW}${skippedTests}${GPBT_COLOR_RESET} Skipped, ${GPBT_COLOR_FG_BLUE}${assertions}${GPBT_COLOR_RESET} Assertions")
  message(STATUS "")
endfunction()

# @brief Starts a new test section with the given name, initializing necessary properties and handling section filtering.
# @param[in] sectionName The name of the test section to start.
function(gpbt_startTestSection sectionName)
  # Clean the test name to create a valid property name
  string(TOUPPER "${sectionName}" cleanedTestName)
  string(REPLACE " " "_" cleanedTestName "${cleanedTestName}")
  string(REGEX REPLACE "[^A-Z0-9_]" "" cleanedTestName "${cleanedTestName}")

  # Initialize properties for the new test section
  gpbt_setProperty(GPBT_TESTS_${cleanedTestName}_NAME "${sectionName}")
  gpbt_setProperty(GPBT_TESTS_${cleanedTestName}_ASSERTIONS 0)
  gpbt_setProperty(GPBT_TESTS_${cleanedTestName}_FAILED_TESTS "")
  gpbt_setProperty(GPBT_TESTS_CURRENT_SECTION "${cleanedTestName}")

  # Check if the section should be filtered based on the GPBT_TESTS_FILTER_SECTION variable
  if(GPBT_TESTS_FILTER_SECTION AND NOT sectionName MATCHES "${GPBT_TESTS_FILTER_SECTION}")
    gpbt_setProperty(GPBT_TESTS_SKIP_NEXT_SECTION TRUE)
  endif()

  # Check if the section is not already marked to be skipped and print the banner
  gpbt_getProperty(GPBT_TESTS_SKIP_NEXT_SECTION skipNextSection)
  if(skipNextSection)
    message(STATUS "${GPBT_COLOR_FG_YELLOW}[---SKIP---]${GPBT_COLOR_RESET} Skipping tests from: ${sectionName}")
  else()
    message(STATUS "")
    message(STATUS "${GPBT_COLOR_FG_GREEN}[----------]${GPBT_COLOR_RESET} Running tests from: ${sectionName}")
  endif()
endfunction()

# @brief Ends the current test section, updating statistics and printing the appropriate banner based on the test results.
# @param[in] sectionName The name of the test section to end.
function(gpbt_endTestSection)
  gpbt_getProperty(GPBT_TESTS_CURRENT_SECTION currentSection)
  if(currentSection STREQUAL "")
    message(FATAL_ERROR "gpbt_endTestSection called without a matching gpbt_startTestSection")
  endif()

  gpbt_getProperty(GPBT_TESTS_${currentSection}_NAME sectionName)

  gpbt_getProperty(GPBT_TESTS_${currentSection}_FAILED_TESTS failedTests)
  if(NOT failedTests STREQUAL "")
    gpbt_appendProperty(GPBT_TESTS_FAILED_SECTIONS "${currentSection}")
    gpbt_incrementProperty(GPBT_TESTS_STATS_FAILED)
  else()
    gpbt_incrementProperty(GPBT_TESTS_STATS_PASSED)
  endif()

  # Check if the section has been marked to be skipped and print the appropriate banner
  gpbt_getProperty(GPBT_TESTS_SKIP_NEXT_SECTION skipNextSection)
  if(NOT skipNextSection)
    message(STATUS "${GPBT_COLOR_FG_GREEN}[----------]${GPBT_COLOR_RESET} Running tests from: ${sectionName}")
    message(STATUS "")
  endif()

  gpbt_setProperty(GPBT_TESTS_CURRENT_SECTION "")
  gpbt_setProperty(GPBT_TESTS_SKIP_NEXT_SECTION FALSE)
endfunction()

# @brief Utility function to check if an assertion method can be called within the current test section context.
# @param[in] methodName The name of the assertion method being called (for error reporting purposes).
function(gpbt_checkCanAssert methodName)
  gpbt_getProperty(GPBT_TESTS_CURRENT_SECTION currentSection)
  if(currentSection STREQUAL "")
    message(FATAL_ERROR "${methodName} called without a matching gpbt_startTestSection")
  endif()
endfunction()

# @brief Fails an assertion with the given description, updating statistics and printing a failure message.
# @param[in] description A description of the failed assertion for reporting purposes.
function(gpbt_assertFail description)
  gpbt_getProperty(GPBT_TESTS_CURRENT_SECTION currentSection)
  if(currentSection STREQUAL "")
    message(FATAL_ERROR "gpbt_assertFail called without a matching gpbt_startTestSection")
  endif()

  gpbt_incrementProperty(GPBT_TESTS_${cleanedTestName}_ASSERTIONS)
  gpbt_incrementProperty(GPBT_TESTS_STATS_ASSERTIONS)
  gpbt_appendProperty(GPBT_TESTS_${currentSection}_FAILED_TESTS "${description}")

  message(STATUS "${GPBT_COLOR_FG_RED}[  FAILED  ]${GPBT_COLOR_RESET} ${description}")
endfunction()

# @brief Succeeds an assertion with the given description, updating statistics and printing a success message.
# @param[in] description A description of the successful assertion for reporting purposes.
function(gpbt_assertSuccess description)
  gpbt_getProperty(GPBT_TESTS_CURRENT_SECTION currentSection)
  if(currentSection STREQUAL "")
    message(FATAL_ERROR "gpbt_assertSuccess called without a matching gpbt_startTestSection")
  endif()

  gpbt_incrementProperty(GPBT_TESTS_${cleanedTestName}_ASSERTIONS)
  gpbt_incrementProperty(GPBT_TESTS_STATS_ASSERTIONS)

  message(STATUS "${GPBT_COLOR_FG_GREEN}[    OK    ]${GPBT_COLOR_RESET} ${description}")
endfunction()

# @brief Handles the logic for determining if an assertion should be skipped based on the current test section's skip status.
# @param[in] description A description of the assertion being checked for skipping (for reporting purposes).
# @param[out] outputShouldSkip A boolean output variable that will be set to TRUE if the assertion should be skipped, or FALSE otherwise.
function(gpbt_assertHandleSkip description outputShouldSkip)
  gpbt_getProperty(GPBT_TESTS_SKIP_NEXT_ASSERT skipNext)
  gpbt_getProperty(GPBT_TESTS_SKIP_NEXT_SECTION skipNextSection)
  if(skipNext OR skipNextSection)
    gpbt_getProperty(GPBT_TESTS_CURRENT_SECTION currentSection)
    gpbt_incrementProperty(GPBT_TESTS_${currentSection}_ASSERTIONS)
    gpbt_incrementProperty(GPBT_TESTS_STATS_ASSERTIONS)
    gpbt_incrementProperty(GPBT_TESTS_STATS_SKIPPED)

    if(skipNext)
      message(STATUS "${GPBT_COLOR_FG_YELLOW}[   SKIP   ]${GPBT_COLOR_RESET} ${description}")
      gpbt_setProperty(GPBT_TESTS_SKIP_NEXT_ASSERT FALSE)
    endif()

    set(${outputShouldSkip} TRUE PARENT_SCOPE)
  else()
    set(${outputShouldSkip} FALSE PARENT_SCOPE)
  endif()
endfunction()

# @brief Marks the next assertion to be skipped, which will cause the next assertion method called to be skipped and reported as such.
function(gpbt_skipNextAssert)
  gpbt_setProperty(GPBT_TESTS_SKIP_NEXT_ASSERT TRUE)
endfunction()

# @brief Marks the next test section to be skipped, which will cause all assertions in the next test section to be skipped and reported as such.
function(gpbt_skipNextSection)
  gpbt_setProperty(GPBT_TESTS_SKIP_NEXT_SECTION TRUE)
endfunction()

# ASSERTIONS METHODS

# @brief Asserts that the given value is TRUE, reporting success or failure with the provided description.
# @param[in] value The value to check for being TRUE (should be the string "TRUE" to pass).
# @param[in] description A description of the assertion for reporting purposes.
function(gpbt_assertTrue value description)
  gpbt_checkCanAssert("gpbt_assertTrue")

  gpbt_assertHandleSkip("${description}" shouldSkip)
  if(shouldSkip)
    return()
  endif()

  if("${value}" STREQUAL "TRUE")
    gpbt_assertSuccess("${description}")
  else()
    gpbt_assertFail("${description} (Expected 'TRUE' but got '${value}')")
  endif()
endfunction()

# @brief Asserts that the given value is FALSE, reporting success or failure with the provided description.
# @param[in] value The value to check for being FALSE (should be the string "FALSE" to pass).
# @param[in] description A description of the assertion for reporting purposes.
function(gpbt_assertFalse value description)
  gpbt_checkCanAssert("gpbt_assertFalse")

  gpbt_assertHandleSkip("${description}" shouldSkip)
  if(shouldSkip)
    return()
  endif()

  if("${value}" STREQUAL "FALSE")
    gpbt_assertSuccess("${description}")
  else()
    gpbt_assertFail("${description} (Expected 'FALSE' but got '${value}')")
  endif()
endfunction()

# @brief Asserts that the given value is equal to the expected value, reporting success or failure with the provided description.
# @param[in] value The value to check for equality.
# @param[in] expected The expected value for comparison.
# @param[in] description A description of the assertion for reporting purposes.
function(gpbt_assertEqual value expected description)
  gpbt_checkCanAssert("gpbt_assertEqual")

  gpbt_assertHandleSkip("${description}" shouldSkip)
  if(shouldSkip)
    return()
  endif()

  if("${value}" STREQUAL "${expected}")
    gpbt_assertSuccess("${description}")
  else()
    gpbt_assertFail("${description} (Expected '${expected}' but got '${value}')")
  endif()
endfunction()

# @brief Asserts that the given value is not equal to the expected value, reporting success or failure with the provided description.
# @param[in] value The value to check for inequality.
# @param[in] expected The expected value for comparison.
# @param[in] description A description of the assertion for reporting purposes.
function(gpbt_assertNotEqual value expected description)
  gpbt_checkCanAssert("gpbt_assertNotEqual")

  gpbt_assertHandleSkip("${description}" shouldSkip)
  if(shouldSkip)
    return()
  endif()

  if("${value}" STREQUAL "${expected}")
    gpbt_assertFail("${description} (Expected value to not be '${expected}')")
  else()
    gpbt_assertSuccess("${description}")
  endif()
endfunction()
