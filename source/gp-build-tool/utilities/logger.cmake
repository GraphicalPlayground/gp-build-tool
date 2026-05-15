# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/config)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/colors)

gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${GPBT_LOG_PREFIX_ENABLED}")
gpbt_setProperty(GPBT_PREVIOUS_LOG_PREFIX_ENABLED "${GPBT_CURRENT_LOG_PREFIX_ENABLED}")
gpbt_setProperty(GPBT_LOG_STEP_CURRENT 0)
gpbt_setProperty(GPBT_LOG_STEP_TOTAL 0)
gpbt_setProperty(GPBT_LOG_STEP_CURRENT_STACK "")
gpbt_setProperty(GPBT_LOG_STEP_TOTAL_STACK "")

# @brief Resolve a severity name into a color code and a fixed-width 9-char badge.
# @param[out] outColor Color code string for this severity level.
# @param[out] outBadge Fixed-width badge string for this severity level.
# @param[in] severity Severity name, e.g. "ERROR", "WARNING", "INFO", etc.
function(_gpbt_resolveLevelBadge outColor outBadge severity)
  if("${severity}" STREQUAL "ERROR")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_RED}" PARENT_SCOPE)
    set(${outBadge} "[ ERROR ]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "FATAL")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_RED}" PARENT_SCOPE)
    set(${outBadge} "[ FATAL ]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "WARNING")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_YELLOW}" PARENT_SCOPE)
    set(${outBadge} "[WARNING]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "INFO")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_BLUE}" PARENT_SCOPE)
    set(${outBadge} "[ INFO  ]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "SUCCESS")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_GREEN}" PARENT_SCOPE)
    set(${outBadge} "[SUCCESS]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "DEBUG")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_CYAN}" PARENT_SCOPE)
    set(${outBadge} "[ DEBUG ]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "VERBOSE")
    set(${outColor} "${GPBT_COLOR_FG_HI_BOLD_PURPLE}" PARENT_SCOPE)
    set(${outBadge} "[VERBOSE]" PARENT_SCOPE)
  elseif("${severity}" STREQUAL "BULLET")
    set(${outColor} "${GPBT_COLOR_FG_HI_WHITE}" PARENT_SCOPE)
    set(${outBadge} "    -" PARENT_SCOPE)
  else()
    set(${outColor} "${GPBT_COLOR_FG_HI_WHITE}" PARENT_SCOPE)
    set(${outBadge} "[  LOG  ]" PARENT_SCOPE)
  endif()
endfunction()

# @brief Compose the [GPBT] source tag with trailing space, or empty string.
# @param[out] outVar Variable to receive the prefix string.
function(_gpbt_buildPrefix outVar)
  gpbt_getProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED _enabled)
  if(_enabled)
    set(${outVar} "${GPBT_COLOR_FG_HI_BLACK}[GPBT]${GPBT_COLOR_RESET} " PARENT_SCOPE)
  else()
    set(${outVar} "" PARENT_SCOPE)
  endif()
endfunction()

# @brief Right-pad a number string to a target character width using leading spaces.
# @param[out] outVar Variable to receive the padded string.
# @param[in] num Number string to pad.
# @param[in] width Target width for the padded string.
function(_gpbt_padNumber outVar num width)
  set(_result "${num}")
  string(LENGTH "${_result}" _len)
  while(_len LESS "${width}")
    set(_result " ${_result}")
    string(LENGTH "${_result}" _len)
  endwhile()
  set(${outVar} "${_result}" PARENT_SCOPE)
endfunction()

# @brief Enable or disable the [GPBT] source tag on each log line.
# @param[in] enabled Boolean, FALSE suppresses the tag.
# @remarks This function is a no-op when GPBT_LOG_PREFIX_ENABLED is FALSE globally,
#          because the global option acts as a kill-switch for the prefix system.
function(gpbt_setLogPrefixEnabled enabled)
  if(NOT GPBT_LOG_PREFIX_ENABLED)
    return()
  endif()
  gpbt_setProperty(GPBT_PREVIOUS_LOG_PREFIX_ENABLED "${GPBT_CURRENT_LOG_PREFIX_ENABLED}")
  gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${enabled}")
endfunction()

# @brief Restore the prefix state saved by the previous gpbt_setLogPrefixEnabled call.
function(gpbt_restorePreviousLogPrefixEnabled)
  gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${GPBT_PREVIOUS_LOG_PREFIX_ENABLED}")
endfunction()

# @brief Log a message at the given severity level.
# @param[in] severity ERROR | FATAL | WARNING | INFO | SUCCESS | DEBUG | VERBOSE | BULLET
# @param[in] ... Message tokens, joined with spaces.
function(gpbt_log severity)
  if("${severity}" STREQUAL "VERBOSE" AND NOT GPBT_LOG_VERBOSE_ENABLED)
    return()
  endif()

  set(_tokens "${ARGN}")
  string(REPLACE ";" " " _msg "${_tokens}")

  _gpbt_resolveLevelBadge(_color _badge "${severity}")
  _gpbt_buildPrefix(_prefix)

  message(STATUS "${_prefix}${_color}${_badge}${GPBT_COLOR_RESET} ${_msg}")

  if(
    "${severity}" STREQUAL "FATAL" OR
    ("${severity}" STREQUAL "WARNING" AND GPBT_TREAT_WARNINGS_AS_FATAL) OR
    ("${severity}" STREQUAL "ERROR"   AND GPBT_TREAT_ERRORS_AS_FATAL)
  )
    message(FATAL_ERROR "Build stopped due to a fatal error.")
  endif()
endfunction()

# @brief Print the build tool startup banner.
# @remarks The banner is guarded by GPBT_HAS_LOGGED_BANNER so it prints only once per CMake
#          run even if gp-build-tool.cmake is included from multiple super-projects sharing a cache.
function(gpbt_logBanner)
  if(NOT GPBT_LOG_BANNER_ENABLED)
    return()
  endif()
  _gpbt_buildPrefix(_prefix)
  set(linesBorder "${GPBT_COLOR_FG_HI_WHITE}================================================================${GPBT_COLOR_RESET}")
  set(toolName "${GPBT_COLOR_FG_HI_BOLD_WHITE}Graphical Playground Build Tool${GPBT_COLOR_RESET}")
  set(toolVersion "${GPBT_COLOR_FG_HI_BLACK}v${GPBT_CURRENT_VERSION}${GPBT_COLOR_RESET}")

  set(currentOS "${CMAKE_SYSTEM_NAME}")
  set(currentArch "${CMAKE_SYSTEM_PROCESSOR}")
  set(cxxCompiler "${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
  set(cxxStandard "C++${CMAKE_CXX_STANDARD}")
  set(cmakeVersion "${CMAKE_VERSION}")
  set(generatorName "${CMAKE_GENERATOR}")

  # For multi-config generators (Visual Studio, Xcode) CMAKE_BUILD_TYPE is empty at configure time;
  # report the full list of configured types instead.
  get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(_isMultiConfig)
    set(buildType "${CMAKE_CONFIGURATION_TYPES} (multi-config)")
  else()
    set(buildType "${CMAKE_BUILD_TYPE}")
  endif()

  find_package(Git QUIET)
  set(lastCommit "Unknown")
  set(lastCommitDate "Unknown")
  set(lastCommitAuthor "Unknown")
  set(gitRepository "Unknown")
  if(GIT_FOUND)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE lastCommit
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} remote get-url origin
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE gitRepository
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} log --format=%ad --date=short -1
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE lastCommitDate
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} log --format=%an -1
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE lastCommitAuthor
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()

  message(STATUS "")
  message(STATUS "${_prefix}${linesBorder}")
  message(STATUS "${_prefix}           ${toolName}  ${toolVersion}")
  message(STATUS "${_prefix}${linesBorder}")

  gpbt_logSection("Build Information")

  message(STATUS "${_prefix}System:           ${currentOS} (${currentArch})")
  message(STATUS "${_prefix}Compiler:         ${cxxCompiler}")
  message(STATUS "${_prefix}Standard:         ${cxxStandard}")
  message(STATUS "${_prefix}CMake:            ${cmakeVersion}")
  message(STATUS "${_prefix}Build Type:       ${buildType}")
  message(STATUS "${_prefix}Generator:        ${generatorName}")
  message(STATUS "${_prefix}Git Commit:       ${lastCommit} by ${lastCommitAuthor} on ${lastCommitDate}")
  message(STATUS "${_prefix}Git Repository:   ${gitRepository}")
endfunction()

# @brief Print a named section header.
# @param[in] title Label shown in the header.
function(gpbt_logSection title)
  _gpbt_buildPrefix(_prefix)
  # Compute dash fill from the uncolored title string so ANSI escape bytes don't skew the width.
  set(_head "--- ${title} ")
  string(LENGTH "${_head}" _headLen)
  math(EXPR _dashCount "64 - ${_headLen}")
  if(_dashCount LESS 2)
    set(_dashCount 2)
  endif()
  set(_tail "")
  foreach(_i RANGE 1 ${_dashCount})
    string(APPEND _tail "-")
  endforeach()
  message(STATUS "")
  message(STATUS "${_prefix}${GPBT_COLOR_FG_HI_BOLD_WHITE}${_head}${_tail}${GPBT_COLOR_RESET}")
  message(STATUS "")
endfunction()

# @brief Print a new empty line.
function(gpbt_logNewLine)
  message(STATUS "")
endfunction()

# @brief Print a plain horizontal separator.
function(gpbt_logSeparator)
  _gpbt_buildPrefix(_prefix)
  message(STATUS "${_prefix}${GPBT_COLOR_FG_HI_BLACK}----------------------------------------------------------------${GPBT_COLOR_RESET}")
endfunction()

# @brief Begin a step-counter block. Must be paired with gpbt_logEndSteps.
# @param[in] total Total number of steps expected in this block.
function(gpbt_logBeginSteps total)
  gpbt_getProperty(GPBT_LOG_STEP_CURRENT _current)
  gpbt_getProperty(GPBT_LOG_STEP_TOTAL   _total)
  gpbt_getProperty(GPBT_LOG_STEP_CURRENT_STACK _currentStack)
  gpbt_getProperty(GPBT_LOG_STEP_TOTAL_STACK   _totalStack)
  list(APPEND _currentStack "${_current}")
  list(APPEND _totalStack   "${_total}")
  gpbt_setProperty(GPBT_LOG_STEP_CURRENT_STACK "${_currentStack}")
  gpbt_setProperty(GPBT_LOG_STEP_TOTAL_STACK   "${_totalStack}")
  gpbt_setProperty(GPBT_LOG_STEP_CURRENT 0)
  gpbt_setProperty(GPBT_LOG_STEP_TOTAL "${total}")
endfunction()

# @brief Advance the step counter and emit a message with a [N/T] badge.
# @param[in] ... Message tokens, joined with spaces.
function(gpbt_logStep)
  gpbt_getProperty(GPBT_LOG_STEP_CURRENT _current)
  gpbt_getProperty(GPBT_LOG_STEP_TOTAL   _total)
  math(EXPR _next "${_current} + 1")
  gpbt_setProperty(GPBT_LOG_STEP_CURRENT "${_next}")

  set(_tokens "${ARGN}")
  string(REPLACE ";" " " _msg "${_tokens}")

  string(LENGTH "${_total}" _width)
  _gpbt_padNumber(_paddedStep "${_next}" "${_width}")

  _gpbt_buildPrefix(_prefix)
  message(STATUS "${_prefix}${GPBT_COLOR_FG_HI_BOLD_WHITE}[${_paddedStep}/${_total}]${GPBT_COLOR_RESET} ${_msg}")
endfunction()

# @brief End a step-counter block and restore the previous counter state.
function(gpbt_logEndSteps)
  gpbt_getProperty(GPBT_LOG_STEP_CURRENT_STACK _currentStack)
  gpbt_getProperty(GPBT_LOG_STEP_TOTAL_STACK   _totalStack)
  list(LENGTH _currentStack _len)
  if(_len GREATER 0)
    list(GET _currentStack -1 _prevCurrent)
    list(GET _totalStack   -1 _prevTotal)
    list(REMOVE_AT _currentStack -1)
    list(REMOVE_AT _totalStack   -1)
    gpbt_setProperty(GPBT_LOG_STEP_CURRENT_STACK "${_currentStack}")
    gpbt_setProperty(GPBT_LOG_STEP_TOTAL_STACK   "${_totalStack}")
    gpbt_setProperty(GPBT_LOG_STEP_CURRENT "${_prevCurrent}")
    gpbt_setProperty(GPBT_LOG_STEP_TOTAL   "${_prevTotal}")
  else()
    gpbt_setProperty(GPBT_LOG_STEP_CURRENT 0)
    gpbt_setProperty(GPBT_LOG_STEP_TOTAL 0)
  endif()
endfunction()

# @brief Begin a log group. Groups are only shown in GitHub CI environments and are ignored locally.
# @param[in] groupName Name of the group, shown in CI logs.
function(gpbt_startGroup groupName)
  if(NOT GPBT_RUNNING_IN_CI)
    return()
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} -E echo "::group::${groupName}")
endfunction()

# @brief End a log group.
function(gpbt_endGroup)
  if(NOT GPBT_RUNNING_IN_CI)
    return()
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} -E echo "::endgroup::")
endfunction()
