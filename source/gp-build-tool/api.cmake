# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/targets/default)
include(gp-build-tool/targets/api/autoscan)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/api/compile-definitions)
include(gp-build-tool/targets/api/compile-options)
include(gp-build-tool/targets/api/dependencies)
include(gp-build-tool/targets/api/metadata)
include(gp-build-tool/targets/api/options)
include(gp-build-tool/targets/api/sources)

# @brief Start the build tool definition. This function should be called at the beginning of the CMakeLists.txt file to
# initialize the build tool and set up any necessary properties or configurations.
# @remarks This function must be paired with a corresponding gpEndBuildTool() call to properly close the build tool definition.
macro(gpStartBuildTool)
  gpbt_startBuildTool()
endmacro()

# @brief End the build tool definition. This function should be called at the end of the CMakeLists.txt file to
# finalize the build tool and perform any necessary cleanup or finalization steps.
# @remarks This function must be called after a gpStartBuildTool() call to properly close the build tool definition.
macro(gpEndBuildTool)
  gpbt_endBuildTool()
endmacro()

# @brief Auto-scan for targets in the specified directory and its subdirectories.
# @param[in] ... The directories or root to scan for target definitions. Can be a relative or absolute path.
# @remarks This function will recursively scan the specified directories or root for CMakeLists.txt files.
# @remarks This need to be run inside a gpStartBuildTool() / gpEndBuildTool() block to properly register the targets found during the scan.
macro(gpBuildToolAutoScan)
  gpbt_autoScanTargets(${ARGN})
endmacro()

# @brief Start a new target definition.
# @param[in] targetType The type of the target (e.g., "executable", "module", "plugin").
# @param[in] targetName The name of the target.
# @remarks This function must be paired with a corresponding gpEndTarget() call to properly close the target definition.
macro(gpStartTarget targetType targetName)
  gpbt_startTarget("${targetType}" "${targetName}" "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

# @brief End the current target definition.
# @remarks This function must be called after a gpStartTarget() call to properly close the target definition.
macro(gpEndTarget)
  gpbt_endTarget()
endmacro()

# @brief Start a new module target definition.
# @param[in] moduleName The name of the module target.
# @remarks This function must be paired with a corresponding gpEndModule() call to properly close the module target definition.
macro(gpStartModule moduleName)
  gpStartTarget("module" "${moduleName}")
endmacro()

# @brief End the current module target definition.
# @remarks This function must be called after a gpStartModule() call to properly close the module target definition.
macro(gpEndModule)
  gpEndTarget()
endmacro()

# @brief Start a new plugin target definition.
# @param[in] pluginName The name of the plugin target.
# @remarks This function must be paired with a corresponding gpEndPlugin() call to properly close the plugin target definition.
macro(gpStartPlugin pluginName)
  gpStartTarget("plugin" "${pluginName}")
endmacro()

# @brief End the current plugin target definition.
# @remarks This function must be called after a gpStartPlugin() call to properly close the plugin target definition.
macro(gpEndPlugin)
  gpEndTarget()
endmacro()

# @brief Start a new executable target definition.
# @param[in] executableName The name of the executable target.
# @remarks This function must be paired with a corresponding gpEndExecutable() call to properly close the executable target definition.
macro(gpStartExecutable executableName)
  gpStartTarget("executable" "${executableName}")
endmacro()

# @brief End the current executable target definition.
# @remarks This function must be called after a gpStartExecutable() call to properly close the executable target definition.
macro(gpEndExecutable)
  gpEndTarget()
endmacro()

# @brief Add source file(s) to the current target.
# @param[in] ... The source file(s) to add. Can be a single file or a list of files.
# @remarks This function can be called multiple times to add more source files to the current target.
macro(gpAddSourceFile)
  gpbt_addSourceFile(${ARGN})
endmacro()

# @brief Add source files from a directory to the current target.
# @param[in] directory The directory to search for source files. Can be a relative or absolute path.
# @remarks This function can be called multiple times to add more source files from different directories to the current target.
macro(gpAddSourceDirectory)
  gpbt_addSourceDirectory(${ARGN})
endmacro()

# @brief Add source files to the current target using a glob pattern.
# @param[in] pattern The glob pattern to match source files. Can include wildcards (e.g., "*.cpp") and can be a relative or absolute path.
# @remarks This function can be called multiple times to add more source files from different patterns to the current target.
macro(gpAddSourcePattern)
  gpbt_addSourcePattern(${ARGN})
endmacro()

# @brief Exclude source file(s) from the current target.
# @param[in] ... The source file(s) to exclude. Can be a single file or a list of files.
# @remarks This function can be called multiple times to exclude more source files from the current target.
macro(gpExcludeSourceFile)
  gpbt_excludeSourceFile(${ARGN})
endmacro()

# @brief Exclude source files from a directory from the current target.
# @param[in] directory The directory to exclude source files from. Can be a relative or absolute path.
# @remarks This function can be called multiple times to exclude more source files from different directories from the current target.
macro(gpExcludeSourceDirectory)
  gpbt_excludeSourceDirectory(${ARGN})
endmacro()

# @brief Exclude source files from the current target using a glob pattern.
# @param[in] pattern The glob pattern to match source files to exclude. Can include wildcards (e.g., "*.cpp") and can be a relative or absolute path.
# @remarks This function can be called multiple times to exclude more source files from different patterns from the current target.
macro(gpExcludeSourcePattern)
  gpbt_excludeSourcePattern(${ARGN})
endmacro()

# @brief Add a dependency to the current target.
# @param[in] visibility The visibility of the dependency (e.g., "PUBLIC", "PRIVATE", "INTERNAL", "DYNAMIC").
# @param[in] ... The dependency target(s) to add. Can be a single target or a list of targets.
# @remarks This function can be called multiple times to add more dependencies to the current target.
macro(gpAddDependency visibility)
  gpbt_addDependency("${visibility}" ${ARGN})
endmacro()
