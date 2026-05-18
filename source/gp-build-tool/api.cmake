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
include(gp-build-tool/thirdparty/core)

# @brief Apply the default policies and configurations for Graphical Playground targets.
macro(gpApplyGraphicalPlaygroundDefaultPolicy)
  # Enforce C++23 globally
  set(CMAKE_CXX_STANDARD 23)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF) # Forces standard C++ (no GCC extensions)

  # Change the default output directories for all targets to be under the "binaries" folder in the source directory.
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/binaries/lib)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/binaries/lib)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/binaries/bin)

  # Put Debug/Release in subfolders (Bin/Debug, Bin/Release)
  foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/binaries/bin/${OUTPUTCONFIG})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/binaries/lib/${OUTPUTCONFIG})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/binaries/lib/${OUTPUTCONFIG})
  endforeach()

  # Enable Position Independent Code (PIC) for static libraries to allow linking into shared libraries on all platforms
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endmacro()

# @brief Start the build tool definition. This function should be called at the beginning of the CMakeLists.txt file to
# initialize the build tool and set up any necessary properties or configurations.
# @remarks This function must be paired with a corresponding gpEndBuildTool() call to properly close the build tool definition.
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
#   INTERNAL  - like PRIVATE but headers are also accessible to other modules in the graph.
#   DYNAMIC   - affects build order only; the dependency is loaded at runtime via dlopen/LoadLibrary.
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

# Thirdparty Package Management

# @brief Open a thirdparty package definition.
# @param[in] packageName  Name of the package (e.g. "sdl2", "physx", "nlohmann-json").
# @param[in] VERSION      Version string (e.g. "2.30.3"). Used for logging and cache keys.
# @remarks Must be paired with gpEndThirdparty(). Call from thirdparty/<name>/CMakeLists.txt.
macro(gpStartThirdparty packageName)
  gpbt_startThirdparty("${packageName}" ${ARGN})
endmacro()

# @brief Close the current thirdparty package definition.
macro(gpEndThirdparty)
  gpbt_endThirdparty()
endmacro()

# @brief Declare the source archive for this package (no git, no submodules).
# @param[in] URL     Archive URL (tar.gz or zip).
# @param[in] HASH    CMake hash string (e.g. "SHA256=abc123...").
# @param[in] TARGET  (Optional) CMake target name the subproject exports. Defaults to "<name>::<name>".
macro(gpThirdpartySource)
  gpbt_thirdpartySource(${ARGN})
endmacro()

# @brief Declare a prebuilt binary archive for a specific platform / compiler combination.
# @param[in] PLATFORMS  GP platform tokens to match: Windows | macOS | iOS | Android | Linux | FreeBSD
# @param[in] COMPILERS  GP compiler tokens to match: MSVC | Clang | GCC  (empty = any)
# @param[in] URL        Download URL of the prebuilt archive.
# @param[in] HASH       CMake hash string (e.g. "SHA256=abc123...").
macro(gpThirdpartyBinary)
  gpbt_thirdpartyBinary(${ARGN})
endmacro()

# @brief Declare that this package should be resolved from the host system.
# @param[in] FIND_PACKAGE <name>   Use CMake find_package(). Combine with TARGET and COMPONENTS.
# @param[in] TARGET <target>       Imported target name produced by find_package() (optional).
# @param[in] COMPONENTS <comp...>  Components passed to find_package() (optional).
# @param[in] FRAMEWORK <name...>   Apple system frameworks: creates -framework <name> link flags.
# @param[in] WINDOWS_SDK LIBS <lib...>  Windows SDK libraries (d3d12, dxgi, d3dcompiler, ...).
macro(gpThirdpartySystem)
  gpbt_thirdpartySystem(${ARGN})
endmacro()

# @brief Restrict this package to specific platforms; silently skipped on all others.
# @param[in] ... GP platform tokens: Windows | macOS | iOS | Android | Linux | FreeBSD
macro(gpThirdpartyRequiresPlatforms)
  gpbt_thirdpartyRequiresPlatforms(${ARGN})
endmacro()

# @brief Restrict this package to specific compilers; silently skipped on all others.
# @param[in] ... GP compiler tokens: MSVC | Clang | GCC
macro(gpThirdpartyRequiresCompilers)
  gpbt_thirdpartyRequiresCompilers(${ARGN})
endmacro()

# @brief Pass extra CMake cache variables when building this package from source.
# @param[in] ... KEY=VALUE pairs forwarded to the subproject's CMake configuration.
macro(gpThirdpartySetCMakeArgs)
  gpbt_thirdpartySetCMakeArgs(${ARGN})
endmacro()

# @brief Override the thirdparty resolution mode.
# @param[in] mode  AUTO (binary-first) | SOURCE (always build from source) | BINARY (prebuilt only)
# @remarks Inside a gpStartThirdparty block: applies only to that package.
#          Outside any block: sets the project-wide default (all packages).
macro(gpSetThirdpartyMode mode)
  gpbt_setThirdpartyMode("${mode}")
endmacro()
