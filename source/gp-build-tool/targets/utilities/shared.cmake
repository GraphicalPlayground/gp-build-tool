# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# @brief Check if the current function is being called within a target definition.
# @param[in] functionName The name of the function to check (for error messages).
macro(gpbt_checkInTargetDefinition functionName)
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION isInTargetDefinition)
  if(NOT isInTargetDefinition)
    gpbt_log(FATAL "${functionName} called without a matching gpbt_startTarget")
  endif()
endmacro()

# @brief Check if the current function is being called within a specific phase.
# @param[in] phaseName The name of the phase to check (e.g., "REGISTRATION", "CONFIGURATION", "GENERATION").
macro(gpbt_runOnlyDuringPhase phaseName)
  gpbt_getProperty(GPBT_CURRENT_PHASE currentPhase)
  if(NOT currentPhase STREQUAL "${phaseName}")
    return()
  endif()
endmacro()
