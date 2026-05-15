# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Check that the target has at least one source file. If not, generate a stub .cpp so
#        CMake does not error out. A WARNING is logged because an empty source list almost always
#        indicates a misconfigured target (wrong directory layout, naming mismatch in private/ or internal/).
# @remarks This check only runs during CONFIGURATION, after auto-scan has collected all sources,
#          so the dummy file is added exactly once and not regenerated on subsequent reconfigures.
function(gpbt_checkForEmptySources)
  gpbt_checkInTargetDefinition("gpbt_checkForEmptySources")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetSources targetSources)
  gpbt_getScopedProperty(_targetName targetName)
  gpbt_getScopedProperty(_targetCleanName targetCleanName)
  gpbt_getScopedProperty(_targetIsHeaderOnly targetIsHeaderOnly)
  list(LENGTH targetSources numSources)

  if(numSources EQUAL 0 AND NOT targetIsHeaderOnly)
    set(dummySource "${CMAKE_CURRENT_BINARY_DIR}/${targetCleanName}_dummy.cpp")
    if(NOT EXISTS "${dummySource}")
      file(WRITE "${dummySource}" "// Auto-generated stub for target '${targetName}' which has no source files.\n")
    endif()
    gpbt_appendScopedProperty(_targetSources "${dummySource}")
    gpbt_log(WARNING "Target '${targetName}' has no sources. A dummy source was generated at '${dummySource}'. Check that source files exist under private/ or internal/, or that gpAddSourceFile/Directory was called.")
  endif()
endfunction()

# @brief Scan a list of flags for exact-string duplicates and warn on each one found.
#        Generator expressions are compared as opaque strings, so "$<$<CONFIG:Debug>:-O0>"
#        appearing twice will be caught. This is called automatically from gpbt_endTarget.
# @param[in] listVarName The name of the scoped property list to check (e.g. "_targetPrivateCompileOptions").
# @param[in] contextLabel Human-readable label for error messages (e.g. "private compile options").
function(gpbt_checkDuplicateFlags listVarName contextLabel)
  gpbt_checkInTargetDefinition("gpbt_checkDuplicateFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty("${listVarName}" flagList)
  gpbt_getScopedProperty(_targetName targetName)

  set(seen "")
  foreach(flag IN LISTS flagList)
    if("${flag}" IN_LIST seen)
      gpbt_log(WARNING "Duplicate ${contextLabel} flag '${flag}' detected in target '${targetName}'. Check compiler modules for redundant entries.")
    else()
      list(APPEND seen "${flag}")
    endif()
  endforeach()
endfunction()

# @brief Run all duplicate-flag checks for the current target across all flag lists.
#        Called from gpbt_endTarget during CONFIGURATION.
function(gpbt_checkAllDuplicateFlags)
  gpbt_checkInTargetDefinition("gpbt_checkAllDuplicateFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_checkDuplicateFlags(_targetPublicCompileOptions    "public compile options")
  gpbt_checkDuplicateFlags(_targetPrivateCompileOptions   "private compile options")
  gpbt_checkDuplicateFlags(_targetInternalCompileOptions  "internal compile options")
  gpbt_checkDuplicateFlags(_targetPublicCompileDefinitions   "public compile definitions")
  gpbt_checkDuplicateFlags(_targetPrivateCompileDefinitions  "private compile definitions")
  gpbt_checkDuplicateFlags(_targetInternalCompileDefinitions "internal compile definitions")
  gpbt_checkDuplicateFlags(_targetPublicLinkOptions   "public link options")
  gpbt_checkDuplicateFlags(_targetPrivateLinkOptions  "private link options")
  gpbt_checkDuplicateFlags(_targetInternalLinkOptions "internal link options")
endfunction()
