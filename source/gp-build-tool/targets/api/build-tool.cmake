# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/sort)
include(gp-build-tool/targets/utilities/graph)

# @brief Initialize the build tool. Must be called before any target registrations.
# @remarks Resets GPBT_TARGETS so that repeated gpStartBuildTool/gpEndBuildTool blocks within
#          the same CMake run do not see stale targets from a previous block.
function(gpbt_startBuildTool)
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED hasBuildToolStarted)
  if(hasBuildToolStarted)
    gpbt_log(FATAL "gpbt_startBuildTool called multiple times. Nested build tools are not supported.")
  endif()
  gpbt_setProperty(GPBT_HAS_BUILD_TOOL_STARTED TRUE)

  # Reset target list so a second gpStartBuildTool/gpEndBuildTool call in the same run starts clean.
  gpbt_setProperty(GPBT_TARGETS "")
  gpbt_setProperty(GPBT_CURRENT_PHASE "REGISTRATION")
  gpbt_logSection("Starting REGISTRATION phase")

  # Specifically add libc++ as compile and link option for Clang on non-Apple platforms.
  if (CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT MSVC AND NOT APPLE)
    if (GP_USE_LIBCXX)
      add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>")
      add_link_options("$<$<LINK_LANGUAGE:CXX>:-stdlib=libc++>")
      gpbt_log(INFO "GP_USE_LIBCXX is ON: Forcing Clang to use libc++")
    endif()
  endif()
endfunction()

# @brief Finalize the build tool: sort targets, configure them, and write the install export file.
# @remarks Must be paired with gpbt_startBuildTool.
function(gpbt_endBuildTool)
  gpbt_getProperty(GPBT_HAS_BUILD_TOOL_STARTED hasBuildToolStarted)
  if(NOT hasBuildToolStarted)
    gpbt_log(FATAL "gpbt_endBuildTool called without a matching gpbt_startBuildTool")
  endif()

  gpbt_setProperty(GPBT_CURRENT_PHASE "CONFIGURATION")
  gpbt_logSection("Starting CONFIGURATION phase")

  gpbt_initTestingSystem()
  gpbt_resolveThirdpartyPackages()

  gpbt_log(INFO "Sorting registered targets...")
  gpbt_sortTargets(sortedTargets)

  gpbt_log(SUCCESS "Successfully sorted targets!")
  gpbt_log(INFO "Targets sorted in the following order based on dependencies:")
  foreach(target IN LISTS sortedTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetName targetName)
    gpbt_popScope()
    gpbt_log(BULLET "${targetName}")
  endforeach()

  # Export the dependency graph before instantiating targets so the graph reflects the
  # registered topology regardless of whether any target fails to configure.
  if(GPBT_EXPORT_DEPENDENCY_GRAPH)
    gpbt_exportDependencyGraph("${GPBT_DEPENDENCY_GRAPH_FILE}")
  endif()

  foreach(target IN LISTS sortedTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetLocation targetLocation)
    gpbt_popScope()
    include("${targetLocation}/CMakeLists.txt")
  endforeach()

  # Write the CMake package config export file so downstream projects can use find_package().
  install(
    EXPORT "${GPBT_INSTALL_EXPORT_NAME}"
    FILE "${GPBT_INSTALL_EXPORT_NAME}.cmake"
    NAMESPACE gp::
    DESTINATION "lib/cmake/${GPBT_INSTALL_EXPORT_NAME}"
  )
  gpbt_log(VERBOSE "Wrote install export '${GPBT_INSTALL_EXPORT_NAME}' to lib/cmake/${GPBT_INSTALL_EXPORT_NAME}/")

  gpbt_setProperty(GPBT_HAS_BUILD_TOOL_STARTED FALSE)
endfunction()
