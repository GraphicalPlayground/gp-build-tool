# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/targets/utilities/shared)

# @brief Add source file(s) to the current target.
# @param[in] ... The source file(s) to add. Can be a single file or a list of files.
# @remarks This function can be called multiple times to add more source files to the current target.
function(gpbt_addSourceFile)
  gpbt_checkInTargetDefinition("gpbt_addSourceFile")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(sourceFile IN LISTS ARGN)
    file(RELATIVE_PATH relativeSourceFile "${targetLocation}" "${sourceFile}")
    gpbt_appendScopedProperty(_targetSources "${relativeSourceFile}")
  endforeach()
endfunction()

# @brief Add source files from a directory to the current target.
# @param[in] directory The directory to search for source files. Can be a relative or absolute path.
# @remarks This function can be called multiple times to add more source files from different directories to the current target.
function(gpbt_addSourceDirectory)
  gpbt_checkInTargetDefinition("gpbt_addSourceDirectory")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(directory IN LIST ARGN)
    file(RELATIVE_PATH relativeDirectory "${targetLocation}" "${directory}")
    file(GLOB_RECURSE sourceFiles "${directory}/*.cpp" "${directory}/*.c" "${directory}/*.cxx" "${directory}/*.cc")
    foreach(sourceFile IN LISTS sourceFiles)
      file(RELATIVE_PATH relativeSourceFile "${targetLocation}" "${sourceFile}")
      gpbt_appendScopedProperty(_targetSources "${relativeSourceFile}")
    endforeach()
  endforeach()
endfunction()

# @brief Add source files to the current target using a glob pattern.
# @param[in] pattern The glob pattern to match source files. Can include wildcards (e.g., "*.cpp") and can be a relative or absolute path.
# @remarks This function can be called multiple times to add more source files from different patterns to the current target.
function(gpbt_addSourcePattern)
  gpbt_checkInTargetDefinition("gpbt_addSourcePattern")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  gpbt_getScopedProperty(_targetLocation targetLocation)
  foreach(pattern IN LIST ARGN)
    file(RELATIVE_PATH relativePattern "${targetLocation}" "${pattern}")
    file(GLOB_RECURSE sourceFiles "${pattern}")
    foreach(sourceFile IN LISTS sourceFiles)
      file(RELATIVE_PATH relativeSourceFile "${targetLocation}" "${sourceFile}")
      gpbt_appendScopedProperty(_targetSources "${relativeSourceFile}")
    endforeach()
  endforeach()
endfunction()

# @brief Exclude source file(s) from the current target.
# @param[in] ... The source file(s) to exclude. Can be a single file or a list of files.
# @remarks This function can be called multiple times to exclude more source files from the current target.
function(gpbt_excludeSourceFile)
  gpbt_checkInTargetDefinition("gpbt_excludeSourceFile")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
endfunction()

# @brief Exclude source files from a directory from the current target.
# @param[in] directory The directory to exclude source files from. Can be a relative or absolute path.
# @remarks This function can be called multiple times to exclude more source files from different directories from the current target.
function(gpbt_excludeSourceDirectory)
  gpbt_checkInTargetDefinition("gpbt_excludeSourceDirectory")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
endfunction()

# @brief Exclude source files from the current target using a glob pattern.
# @param[in] pattern The glob pattern to match source files to exclude. Can include wildcards (e.g., "*.cpp") and can be a relative or absolute path.
# @remarks This function can be called multiple times to exclude more source files from different patterns from the current target.
function(gpbt_excludeSourcePattern)
  gpbt_checkInTargetDefinition("gpbt_excludeSourcePattern")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
endfunction()
