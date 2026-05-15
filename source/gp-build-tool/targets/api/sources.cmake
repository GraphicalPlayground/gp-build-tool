# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Add source file(s) to the current target.
# @param[in] ... Absolute paths or paths relative to the target location.
# @remarks Paths are normalized to absolute before storage so that add_library/add_executable
#          receives correct paths regardless of CMAKE_CURRENT_SOURCE_DIR at configuration time.
function(gpbt_addSourceFile)
  gpbt_checkInTargetDefinition("gpbt_addSourceFile")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(sourceFile IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${sourceFile}")
      set(sourceFile "${targetLocation}/${sourceFile}")
    endif()
    get_filename_component(sourceFile "${sourceFile}" ABSOLUTE)
    gpbt_appendScopedProperty(_targetSources "${sourceFile}")
  endforeach()
endfunction()

# @brief Add source files from a directory to the current target.
# @param[in] ... The directory (or directories) to search. Can be absolute or relative to the target location.
function(gpbt_addSourceDirectory)
  gpbt_checkInTargetDefinition("gpbt_addSourceDirectory")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(directory IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${directory}")
      set(directory "${targetLocation}/${directory}")
    endif()
    get_filename_component(directory "${directory}" ABSOLUTE)
    file(GLOB_RECURSE sourceFiles
      "${directory}/*.cpp" "${directory}/*.c"
      "${directory}/*.cxx" "${directory}/*.cc")
    foreach(sourceFile IN LISTS sourceFiles)
      gpbt_appendScopedProperty(_targetSources "${sourceFile}")
    endforeach()
  endforeach()
endfunction()

# @brief Add source files to the current target using a glob pattern.
# @param[in] ... Glob pattern(s). Relative patterns are resolved against the target location.
function(gpbt_addSourcePattern)
  gpbt_checkInTargetDefinition("gpbt_addSourcePattern")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(pattern IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${pattern}" AND NOT "${pattern}" MATCHES "^\\*")
      set(pattern "${targetLocation}/${pattern}")
    endif()
    file(GLOB_RECURSE sourceFiles ${pattern})
    foreach(sourceFile IN LISTS sourceFiles)
      gpbt_appendScopedProperty(_targetSources "${sourceFile}")
    endforeach()
  endforeach()
endfunction()

# @brief Exclude source file(s) from the current target's source list.
# @param[in] ... Absolute paths or paths relative to the target location.
# @remarks Exclusion happens during REGISTRATION so the list passed to add_library/add_executable
#          at CONFIGURATION time is already correct.
function(gpbt_excludeSourceFile)
  gpbt_checkInTargetDefinition("gpbt_excludeSourceFile")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  gpbt_getScopedProperty(_targetSources currentSources)
  foreach(sourceFile IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${sourceFile}")
      set(sourceFile "${targetLocation}/${sourceFile}")
    endif()
    get_filename_component(sourceFile "${sourceFile}" ABSOLUTE)
    list(REMOVE_ITEM currentSources "${sourceFile}")
  endforeach()
  gpbt_setScopedProperty(_targetSources "${currentSources}")
endfunction()

# @brief Exclude all source files found under the given directory from the current target.
# @param[in] ... The directory (or directories) to exclude. Can be absolute or relative.
function(gpbt_excludeSourceDirectory)
  gpbt_checkInTargetDefinition("gpbt_excludeSourceDirectory")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  gpbt_getScopedProperty(_targetSources currentSources)
  foreach(directory IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${directory}")
      set(directory "${targetLocation}/${directory}")
    endif()
    get_filename_component(directory "${directory}" ABSOLUTE)
    file(GLOB_RECURSE filesToRemove
      "${directory}/*.cpp" "${directory}/*.c"
      "${directory}/*.cxx" "${directory}/*.cc")
    foreach(fileToRemove IN LISTS filesToRemove)
      list(REMOVE_ITEM currentSources "${fileToRemove}")
    endforeach()
  endforeach()
  gpbt_setScopedProperty(_targetSources "${currentSources}")
endfunction()

# @brief Exclude source files matching a glob pattern from the current target.
# @param[in] ... Glob pattern(s). Relative patterns are resolved against the target location.
function(gpbt_excludeSourcePattern)
  gpbt_checkInTargetDefinition("gpbt_excludeSourcePattern")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  gpbt_getScopedProperty(_targetSources currentSources)
  foreach(pattern IN LISTS ARGN)
    if(NOT IS_ABSOLUTE "${pattern}" AND NOT "${pattern}" MATCHES "^\\*")
      set(pattern "${targetLocation}/${pattern}")
    endif()
    file(GLOB_RECURSE filesToRemove ${pattern})
    foreach(fileToRemove IN LISTS filesToRemove)
      list(REMOVE_ITEM currentSources "${fileToRemove}")
    endforeach()
  endforeach()
  gpbt_setScopedProperty(_targetSources "${currentSources}")
endfunction()
