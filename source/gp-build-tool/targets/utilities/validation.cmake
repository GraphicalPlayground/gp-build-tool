# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/targets/utilities/shared)

# @brief Check if the current target has any sources defined, and if not, add a dummy source file to
# prevent CMake from throwing an error about the target having no sources.
function(gpbt_checkForEmptySources)
  gpbt_checkInTargetDefinition("gpbt_checkForEmptySources")

  # Get the propertys related variables
  gpbt_getScopedProperty(_targetSources targetSources)
  gpbt_getScopedProperty(_targetName targetName)
  gpbt_getScopedProperty(_targetCleanName targetCleanName)
  gpbt_getScopedProperty(_targetIsHeaderOnly targetIsHeaderOnly)
  list(LENGTH targetSources numSources)

  # If there are no sources defined and the target is not header-only,
  # add a dummy source file to prevent CMake from throwing an error about the target having no sources.
  if(numSources EQUAL 0 AND NOT targetIsHeaderOnly)
    set(dummySource "${CMAKE_CURRENT_BINARY_DIR}/${targetCleanName}_dummy.cpp")
    if(NOT EXISTS "${dummySource}")
      file(WRITE "${dummySource}" "// Dummy source file for target '${targetName}'")
    endif()
    gpbt_appendScopedProperty(_targetSources "${dummySource}")
    gpbt_log(WARNING "Target '${targetName}' has no sources defined. Adding dummy source file: ${dummySource}")
  endif()
endfunction()
