# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/config)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/colors)

gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${GPBT_LOG_PREFIX_ENABLED}")
gpbt_setProperty(GPBT_PREVIOUS_LOG_PREFIX_ENABLED "${GPBT_CURRENT_LOG_PREFIX_ENABLED}")

# @brief Sets the log prefix enabled state.
# @param[in] enabled The new log prefix enabled state.
function(gpbt_setLogPrefixEnabled enabled)
  if(NOT GPBT_LOG_PREFIX_ENABLED) # Setting the log prefix enabled state is disabled, do nothing.
    return()
  endif()

  gpbt_setProperty(GPBT_PREVIOUS_LOG_PREFIX_ENABLED "${GPBT_CURRENT_LOG_PREFIX_ENABLED}")
  gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${enabled}")
endfunction()

# @brief Restores the previous log prefix enabled state.
function(gpbt_restorePreviousLogPrefixEnabled)
  gpbt_setProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED "${GPBT_PREVIOUS_LOG_PREFIX_ENABLED}")
endfunction()

# @brief Internal function to format log messages with optional severity and prefix.
# @param[out] outVar The variable to store the formatted message in.
# @param[in] severityColor The color code for the severity level (e.g. ${GP_RED} for errors).
# @param[in] severityName The name of the severity level (e.g. "ERROR", "WARNING"). Can be empty for no severity.
macro(gpbt_formatLogMessage outVar severityColor severityName)
  set(prefix "")
  gpbt_getProperty(GPBT_CURRENT_LOG_PREFIX_ENABLED currentLogPrefixEnabled)
  if(currentLogPrefixEnabled)
    set(prefix "[GPBT] ")
  endif()

  set(messageList "${ARGN}")
  string(REPLACE ";" " " message "${messageList}")
  if("${severityName}" STREQUAL "")
    set(${outVar} "${prefix}${message}")
  else()
    set(${outVar} "${prefix}${severityColor}${severityName}:${GPBT_COLOR_RESET} ${message}")
  endif()
endmacro()

# @brief Logs a message with the specified severity level.
# @param[in] severity The severity level (e.g. "ERROR", "WARNING", "INFO", "SUCCESS", "DEBUG", "VERBOSE").
# @param[in] ... The message to log, which can be a single string or multiple arguments that will be concatenated with spaces.
function(gpbt_log severity)
  # Check if the verbose level is enabled based on the current log level settings.
  if("${severity}" STREQUAL "VERBOSE" AND NOT GPBT_LOG_VERBOSE_ENABLED)
    return()
  endif()

  # Determine the color and name for the severity level.
  set(severityColor "")
  set(severityName "")
  if("${severity}" STREQUAL "ERROR")
    set(severityColor "${GPBT_COLOR_FG_RED}")
    set(severityName "ERROR")
  elseif("${severity}" STREQUAL "FATAL")
    set(severityColor "${GPBT_COLOR_FG_HI_RED}")
    set(severityName "FATAL")
  elseif("${severity}" STREQUAL "WARNING")
    set(severityColor "${GPBT_COLOR_FG_YELLOW}")
    set(severityName "WARNING")
  elseif("${severity}" STREQUAL "INFO")
    set(severityColor "${GPBT_COLOR_FG_BLUE}")
    set(severityName "INFO")
  elseif("${severity}" STREQUAL "SUCCESS")
    set(severityColor "${GPBT_COLOR_FG_GREEN}")
    set(severityName "SUCCESS")
  elseif("${severity}" STREQUAL "DEBUG")
    set(severityColor "${GPBT_COLOR_FG_CYAN}")
    set(severityName "DEBUG")
  elseif("${severity}" STREQUAL "VERBOSE")
    set(severityColor "${GPBT_COLOR_FG_PURPLE}")
    set(severityName "VERBOSE")
  endif()

  # Format the log message with the appropriate severity color and name.
  gpbt_formatLogMessage(formattedMessage "${severityColor}" "${severityName}" "${ARGN}")
  message(STATUS "${formattedMessage}")

  # If the severity is FATAL, exit the program after logging the message.
  if("${severity}" STREQUAL "FATAL")
    message(FATAL_ERROR "Fatal error occurred. Exiting.")
  endif()
endfunction()
