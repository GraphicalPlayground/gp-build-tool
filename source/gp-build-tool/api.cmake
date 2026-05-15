# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/default)
include(gp-build-tool/targets/api/autoscan)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/api/compile-definitions)
include(gp-build-tool/targets/api/compile-options)
include(gp-build-tool/targets/api/dependencies)
include(gp-build-tool/targets/api/link-options)
include(gp-build-tool/targets/api/metadata)
include(gp-build-tool/targets/api/options)
include(gp-build-tool/targets/api/sources)

# Build Tool Lifecycle

# @brief Initialize the build tool. Call once before any target definitions.
# @remarks Must be paired with gpEndBuildTool().
macro(gpStartBuildTool)
  gpbt_startBuildTool()
endmacro()

# @brief Finalize the build tool: sort targets, configure them, and write the install export.
# @remarks Must be called after gpStartBuildTool().
macro(gpEndBuildTool)
  gpbt_endBuildTool()
endmacro()

# @brief Recursively scan directories for CMakeLists.txt files and register their targets.
# @param[in] ... Directories to scan (relative to caller or absolute).
# @remarks Must be called inside gpStartBuildTool/gpEndBuildTool.
macro(gpBuildToolAutoScan)
  gpbt_autoScanTargets(${ARGN})
endmacro()

# Target Definition

# @brief Start a target definition.
# @param[in] targetType "executable" | "module" | "plugin"
# @param[in] targetName Name of the target. Supports "/" for hierarchies (e.g. "rhi/d3d12").
# @remarks Must be paired with gpEndTarget().
macro(gpStartTarget targetType targetName)
  gpbt_startTarget("${targetType}" "${targetName}" "${CMAKE_CURRENT_LIST_DIR}")
endmacro()

# @brief Close the current target definition.
macro(gpEndTarget)
  gpbt_endTarget()
endmacro()

# @brief Start a module (library) target definition.
macro(gpStartModule moduleName)
  gpStartTarget("module" "${moduleName}")
endmacro()

# @brief Close the current module target definition.
macro(gpEndModule)
  gpEndTarget()
endmacro()

# @brief Start a plugin target definition.
macro(gpStartPlugin pluginName)
  gpStartTarget("plugin" "${pluginName}")
endmacro()

# @brief Close the current plugin target definition.
macro(gpEndPlugin)
  gpEndTarget()
endmacro()

# @brief Start an executable target definition.
macro(gpStartExecutable executableName)
  gpStartTarget("executable" "${executableName}")
endmacro()

# @brief Close the current executable target definition.
macro(gpEndExecutable)
  gpEndTarget()
endmacro()

# Sources

# @brief Add source file(s) to the current target (absolute or relative to target directory).
macro(gpAddSourceFile)
  gpbt_addSourceFile(${ARGN})
endmacro()

# @brief Add all C/C++ sources found recursively under a directory.
macro(gpAddSourceDirectory)
  gpbt_addSourceDirectory(${ARGN})
endmacro()

# @brief Add sources matching a glob pattern.
macro(gpAddSourcePattern)
  gpbt_addSourcePattern(${ARGN})
endmacro()

# @brief Exclude source file(s) from the current target.
macro(gpExcludeSourceFile)
  gpbt_excludeSourceFile(${ARGN})
endmacro()

# @brief Exclude all sources under a directory from the current target.
macro(gpExcludeSourceDirectory)
  gpbt_excludeSourceDirectory(${ARGN})
endmacro()

# @brief Exclude sources matching a glob pattern from the current target.
macro(gpExcludeSourcePattern)
  gpbt_excludeSourcePattern(${ARGN})
endmacro()

# Dependencies

# @brief Add a dependency to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL | DYNAMIC
#   INTERNAL  — like PRIVATE but headers are also accessible to other modules in the graph.
#   DYNAMIC   — affects build order only; the dependency is loaded at runtime via dlopen/LoadLibrary.
# @param[in] ... Target name(s). Internal GP targets are resolved by name; others pass through.
macro(gpAddDependency visibility)
  gpbt_addDependency("${visibility}" ${ARGN})
endmacro()

# Compile Definitions

# @brief Add preprocessor definition(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
# @param[in] ... Definition(s): "FOO", "FOO=1", "$<$<CONFIG:Debug>:FLAG=1>".
macro(gpAddCompileDefinition visibility)
  gpbt_addCompileDefinition("${visibility}" ${ARGN})
endmacro()

# Compile Options

# @brief Add compiler flag(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
# @param[in] ... Flag(s): "-march=native", "/favor:INTEL64".
macro(gpAddCompileOption visibility)
  gpbt_addCompileOption("${visibility}" ${ARGN})
endmacro()

# Link Options

# @brief Add linker flag(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
# @param[in] ... Flag(s): "-Wl,--version-script=foo.map", "/SUBSYSTEM:CONSOLE".
macro(gpAddLinkOption visibility)
  gpbt_addLinkOption("${visibility}" ${ARGN})
endmacro()

# Target Options

# @brief Mark the current module as header-only (creates an INTERFACE library).
macro(gpSetHeaderOnly)
  gpbt_setHeaderOnly()
endmacro()

# @brief Enable Unity Build (batch-compile TUs for faster builds).
macro(gpEnableUnityBuild)
  gpbt_enableUnityBuild()
endmacro()

# @brief Disable strict warnings (-Wall/-Werror / /W4/WX) for the current target.
macro(gpDisableStrictWarnings)
  gpbt_disableStrictWarnings()
endmacro()

# @brief Force the current module to link as a static library.
macro(gpSetStatic)
  gpbt_setStatic()
endmacro()

# @brief Force the current module to link as a shared library.
macro(gpSetShared)
  gpbt_setShared()
endmacro()

# @brief Enable per-target test infrastructure (reserved).
macro(gpEnableTests)
  gpbt_enableTests()
endmacro()

# @brief Enable per-target benchmark infrastructure (reserved).
macro(gpEnableBenchmarks)
  gpbt_enableBenchmarks()
endmacro()

# @brief Enable per-target example infrastructure (reserved).
macro(gpEnableExamples)
  gpbt_enableExamples()
endmacro()

# @brief Add a precompiled header to the current target.
# @param[in] headerFile Path to the header (absolute or relative to target directory).
macro(gpAddPrecompiledHeader headerFile)
  gpbt_addPrecompiledHeader("${headerFile}")
endmacro()

# Target Metadata

# @brief Override the IDE folder for the current target.
# @param[in] folderName Folder path in the IDE (e.g., "engine/runtime").
macro(gpSetFolder folderName)
  gpbt_setFolder("${folderName}")
endmacro()

# @brief Add an additional CMake alias to the current target.
# @param[in] aliasName Alias name (e.g., "mylib::v2").
macro(gpAddAlias aliasName)
  gpbt_addAlias("${aliasName}")
endmacro()

# @brief Mark the current executable as a GUI application on Windows (WinMain, no console window).
macro(gpSetGuiExecutable)
  gpbt_setGuiExecutable()
endmacro()

# @brief Set a custom entry point source file for the current executable.
# @param[in] entryPointFile Path to the entry point source (absolute or relative).
macro(gpSetEntryPoint entryPointFile)
  gpbt_setEntryPoint("${entryPointFile}")
endmacro()

# @brief Add a platform resource file to the current executable (e.g., a .rc file on Windows).
# @param[in] resourceFile Path to the resource file (absolute or relative).
macro(gpAddResourceFile resourceFile)
  gpbt_addResourceFile("${resourceFile}")
endmacro()
