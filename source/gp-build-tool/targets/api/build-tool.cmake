# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/sort)

# @brief The main entry point to start the build tool. This function initializes the build tool's internal state and prepares it for target registration.
#        It should be called at the very beginning of the build tool's execution before any targets are registered.
# @remarks This function must be paired with a call to gpbt_endBuildTool at the end of the build tool's execution to properly finalize the build process.
function(gpbt_startBuildTool)
  # Check if the build tool has already been started to prevent nested calls which are not supported.
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED hasBuildToolStarted)
  if(hasBuildToolStarted)
    gpbt_log(FATAL "gpbt_startBuildTool called multiple times. Nested build tools are not supported.")
  endif()
  gpbt_setProperty(GPBT_HAS_BUILD_TOOL_STARTED TRUE)

  # Initialize the global list of targets to an empty list at the start of the build tool execution.
  gpbt_setProperty(GPBT_TARGETS "")

  # Set the current phase to REGISTRATION at the start of the build tool execution.
  gpbt_setProperty(GPBT_CURRENT_PHASE "REGISTRATION")
  gpbt_logSection("Starting REGISTRATION phase")
endfunction()

# @brief The main entry point to end the build tool. This function finalizes the build tool's execution by sorting the registered targets based on their dependencies and including their CMakeLists.txt files in the correct order.
#        It should be called at the very end of the build tool's execution after all targets have been registered and configured.
# @remarks This function must be paired with a call to gpbt_startBuildTool at the beginning of the build tool's execution to properly initialize the build process.
function(gpbt_endBuildTool)
  # Check if the build tool was started before trying to end it to ensure proper usage and prevent errors.
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED hasBuildToolStarted)
  if(NOT hasBuildToolStarted)
    gpbt_log(FATAL "gpbt_endBuildTool called without a matching gpbt_startBuildTool")
  endif()

  # Set the current phase to CONFIGURATION before including the target CMakeLists.txt files to properly configure the targets.
  gpbt_setProperty(GPBT_CURRENT_PHASE "CONFIGURATION")
  gpbt_logSection("Starting CONFIGURATION phase")

  # Log the number of registered targets before sorting to provide insight into the build process.
  gpbt_log(INFO "Sorting registered targets...")

  # Sort the targets based on their dependencies to ensure correct configuration and generation order.
  gpbt_sortTargets(sortedTargets)

  # Log Sorted Targets
  gpbt_log(SUCCESS "Successfully sorted targets!")
  gpbt_log(INFO "Targets sorted in the following order based on dependencies:")
  foreach(target IN LISTS sortedTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetName targetName)
    gpbt_popScope()
    gpbt_log(BULLET "${targetName}")
  endforeach()

  # Include the CMakeLists.txt file for each registered target in the correct order. This will allow each target to be properly configured based on its dependencies.

  foreach(target IN LISTS sortedTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetLocation targetLocation)
    gpbt_popScope()
    include("${targetLocation}/CMakeLists.txt")
  endforeach()

  # Exit the build tool by resetting the hasBuildToolStarted property to FALSE to allow for potential future build tool executions.
  gpbt_setProperty(GPBT_HAS_BUILD_TOOL_STARTED FALSE)
endfunction()
