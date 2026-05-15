# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/logger)

# @brief Automatically scan the specified directories for CMakeLists.txt files and register them as targets.
# @param[in] ... A list of directories to recursively scan for CMakeLists.txt files. If empty, the current directory will be scanned.
# @remarks This function should be called within a gpbt_startBuildTool() / gpbt_endBuildTool() block to properly register the targets found during the scan.
# @remarks The scanning process will look for CMakeLists.txt files in the specified directories and their subdirectories.
function(gpbt_autoScanTargets)
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED hasBuildToolStarted)
  if(NOT hasBuildToolStarted)
    gpbt_log(FATAL "gpbt_autoScanTargets called without a matching gpbt_startBuildTool")
  endif()

  # Auto-scan must run during REGISTRATION so that targets are discovered before gpbt_endBuildTool
  # transitions to CONFIGURATION and begins configuring them.
  gpbt_getProperty(GPBT_CURRENT_PHASE currentPhase)
  if(NOT currentPhase STREQUAL "REGISTRATION")
    gpbt_log(FATAL "gpbt_autoScanTargets must be called during the REGISTRATION phase (inside gpStartBuildTool/gpEndBuildTool).")
  endif()

  set(directoriesToScan "${ARGN}")
  list(LENGTH directoriesToScan numDirectories)
  if(numDirectories EQUAL 0)
    list(APPEND directoriesToScan "${CMAKE_CURRENT_LIST_DIR}")
    gpbt_log(WARNING "gpbt_autoScanTargets called without any directories to scan. Defaulting to current directory: ${CMAKE_CURRENT_LIST_DIR}")
  endif()

  # Set up a queue for breadth-first scanning of directories and a list to track visited directories to avoid infinite loops
  set(queue "${directoriesToScan}")
  set(visitedDirectories "")

  # Log all directories that will be scanned
  gpbt_log(INFO "Starting auto-scan for targets in the following directories:")
  foreach(dir IN LISTS directoriesToScan)
    gpbt_log(BULLET "${dir}")
  endforeach()

  while(queue)
    list(POP_FRONT queue currentDir)

    # Resolve to absolute path to ensure accurate duplicate checking
    get_filename_component(currentDir "${currentDir}" ABSOLUTE)

    # If we've already processed this directory, skip it
    if(currentDir IN_LIST visitedDirectories)
      continue()
    endif()
    list(APPEND visitedDirectories "${currentDir}")

    # Scan the directory contents
    file(GLOB entries RELATIVE "${currentDir}" "${currentDir}/*")

    foreach(entry IN LISTS entries)
      set(fullPath "${currentDir}/${entry}")

      if(IS_DIRECTORY "${fullPath}")
        get_filename_component(fullPath "${fullPath}" ABSOLUTE)

        if(EXISTS "${fullPath}/CMakeLists.txt")
          # Found a module! Make sure we haven't already registered it
          if(NOT fullPath IN_LIST visitedDirectories)
            file(RELATIVE_PATH relativePath "${CMAKE_CURRENT_SOURCE_DIR}" "${fullPath}")
            add_subdirectory("${relativePath}")

            # Mark it as visited so it doesn't get processed again
            # if it also happened to be in the ARGN list
            list(APPEND visitedDirectories "${fullPath}")
          endif()
        else()
          # No CMakeLists here, queue it up to scan its subfolders
          if(NOT fullPath IN_LIST visitedDirectories)
            list(APPEND queue "${fullPath}")
          endif()
        endif()
      endif()
    endforeach()
  endwhile()
endfunction()
