# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/config)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/colors)

gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${GPBT_LOG_PREFIX_ENABLED}")
gpbt_setProperty(GPBT_PREVIOUS_LOG_PREFIX_ENABLED "${GPBT_CURRENT_LOG_PREFIX_ENABLED}")
gpbt_setProperty(GPBT_LOG_STEP_CURRENT 0)
gpbt_setProperty(GPBT_LOG_STEP_TOTAL 0)

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
# @param[in] enabled  Boolean — FALSE suppresses the tag.
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
# @param[in] severity ERROR | FATAL | WARNING | INFO | SUCCESS | DEBUG | VERBOSE | LOG
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
function(gpbt_logBanner)
  if(NOT GPBT_LOG_BANNER_ENABLED)
    return()
  endif()
  _gpbt_buildPrefix(_prefix)
  set(_border "${GPBT_COLOR_FG_HI_WHITE}================================================================${GPBT_COLOR_RESET}")
  set(_name   "${GPBT_COLOR_FG_HI_BOLD_WHITE}Graphical Playground Build Tool${GPBT_COLOR_RESET}")
  set(_ver    "${GPBT_COLOR_FG_HI_BLACK}v${GPBT_CURRENT_VERSION}${GPBT_COLOR_RESET}")
  message(STATUS "")
  message(STATUS "${_prefix}${_border}")
  message(STATUS "${_prefix}           ${_name}  ${_ver}")
  message(STATUS "${_prefix}${_border}")
  message(STATUS "")
endfunction()

# @brief Print a named section header.
# @param[in] title Label shown in the header.
function(gpbt_logSection title)
  _gpbt_buildPrefix(_prefix)
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

# @brief Print a plain horizontal separator.
function(gpbt_logSeparator)
  _gpbt_buildPrefix(_prefix)
  message(STATUS "${_prefix}${GPBT_COLOR_FG_HI_BLACK}----------------------------------------------------------------${GPBT_COLOR_RESET}")
endfunction()

# @brief Begin a step-counter block. Must be paired with gpbt_logEndSteps.
# @param[in] total  Total number of steps expected in this block.
function(gpbt_logBeginSteps total)
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

# @brief End a step-counter block and reset the counter.
function(gpbt_logEndSteps)
  gpbt_setProperty(GPBT_LOG_STEP_CURRENT 0)
  gpbt_setProperty(GPBT_LOG_STEP_TOTAL 0)
endfunction()
