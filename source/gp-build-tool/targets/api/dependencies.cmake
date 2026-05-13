# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/targets/utilities/shared)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)

# List of available dependency visibilities that can be used when adding dependencies to a target.
set(GPBT_DEPENDENCY_AVAILBLE_VISIBILITIES "PUBLIC;PRIVATE;INTERNAL;DYNAMIC")

# @brief Add a dependency to the current target.
# @param[in] visibility The visibility of the dependency (e.g., "PUBLIC", "PRIVATE", "INTERNAL", "DYNAMIC").
# @param[in] ... The dependency target(s) to add. Can be a single target or a list of targets.
# @remarks This function can be called multiple times to add more dependencies to the current target.
function(gpbt_addDependency visibility)
  gpbt_checkInTargetDefinition("gpbt_addDependency")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  # Check if the visibility is valid
  if(NOT visibility IN_LIST GPBT_DEPENDENCY_AVAILBLE_VISIBILITIES)
    gpbt_log(FATAL "Invalid dependency visibility: ${visibility}")
  endif()

  set(dependencies ${ARGN})
  foreach(dependency IN LISTS dependencies)
    if("${visibility}" STREQUAL "PUBLIC")
      gpbt_appendScopedProperty(_targetPublicDependencies "${dependency}")
    elseif("${visibility}" STREQUAL "PRIVATE")
      gpbt_appendScopedProperty(_targetPrivateDependencies "${dependency}")
    elseif("${visibility}" STREQUAL "INTERNAL")
      gpbt_appendScopedProperty(_targetInternalDependencies "${dependency}")
    elseif("${visibility}" STREQUAL "DYNAMIC")
      gpbt_appendScopedProperty(_targetDynamicDependencies "${dependency}")
    endif()

    gpbt_log(VERBOSE "Added ${visibility} dependency: ${dependency}")
  endforeach()
endfunction()
