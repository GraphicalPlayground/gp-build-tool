# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/target-props)
include(gp-build-tool/targets/utilities/validation)
include(gp-build-tool/targets/executable)
include(gp-build-tool/targets/module)
include(gp-build-tool/targets/plugin)
if(GPBT_DUMP_TARGETS_PROPERTIES)
  include(gp-build-tool/targets/utilities/dump)
endif()

include(gp-build-tool/compilers/default)
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  include(gp-build-tool/compilers/msvc)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    include(gp-build-tool/compilers/msvc)
  else()
    include(gp-build-tool/compilers/clang)
  endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  include(gp-build-tool/compilers/gcc)
else()
  gpbt_log(WARNING "Unsupported compiler: ${CMAKE_CXX_COMPILER_ID}. Default compiler settings will be used, which may lead to suboptimal builds or compatibility issues.")
endif()

# Linker selection.
# The active linker is detected from the compiler + platform combination and may be
# overridden with -DGPBT_LINKER=<name> (ld | lld | ld64 | msvc-link).
# Valid values: "ld", "lld", "ld64", "msvc-link", "default".
if(NOT GPBT_LINKER)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(GPBT_LINKER "msvc-link")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND APPLE)
    set(GPBT_LINKER "ld64")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # clang.cmake forces -fuse-ld=lld on non-Darwin, so lld is the active linker.
    set(GPBT_LINKER "lld")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(GPBT_LINKER "ld")
  else()
    set(GPBT_LINKER "default")
  endif()
endif()

include(gp-build-tool/linkers/default)
if(GPBT_LINKER STREQUAL "msvc-link")
  include(gp-build-tool/linkers/msvc-link)
elseif(GPBT_LINKER STREQUAL "ld64")
  include(gp-build-tool/linkers/ld64)
elseif(GPBT_LINKER STREQUAL "lld")
  include(gp-build-tool/linkers/lld)
elseif(GPBT_LINKER STREQUAL "ld")
  include(gp-build-tool/linkers/ld)
else()
  gpbt_log(INFO "Linker '${GPBT_LINKER}' has no specific flag set. Using default (no additional linker flags).")
endif()

gpbt_log(INFO "Selected compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION} | linker: ${GPBT_LINKER}")

include(gp-build-tool/platforms/default)
# Platform detection: more-specific checks must come before generic catch-alls.
# Android sets CMAKE_SYSTEM_NAME = "Android" but also sets UNIX, so it must be tested first.
# iOS sets CMAKE_SYSTEM_NAME = "iOS" but also sets APPLE, so it must be tested before APPLE.
if(WIN32)
  include(gp-build-tool/platforms/windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
  include(gp-build-tool/platforms/android)
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
  include(gp-build-tool/platforms/ios)
elseif(APPLE)
  include(gp-build-tool/platforms/macos)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
  include(gp-build-tool/platforms/freebsd)
elseif(UNIX)
  include(gp-build-tool/platforms/linux)
else()
  gpbt_log(WARNING "Unsupported platform: ${CMAKE_SYSTEM_NAME}. Default platform settings will be used.")
endif()

set(GPBT_AVAILABLE_TARGET_TYPES "executable;module;plugin")

# @brief Internal function to set up the properties for a new target definition.
# @param[in] inTargetType The type of the target (e.g., "executable", "module", "plugin").
# @param[in] inTargetName The name of the target.
# @param[in] inTargetLocation The file system location of the target (used for generating a unique guid and finding source files).
# @param[in] inCleanTargetName Pre-computed clean target name (already regex-replaced and lowercased by gpbt_startTarget).
# @remarks This function only run on the REGISTRATION phase.
function(gpbt_setupTargetProperties inTargetType inTargetName inTargetLocation inCleanTargetName)
  gpbt_checkInTargetDefinition("gpbt_setupTargetProperties")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  # Check if the provided target type is valid
  string(TOLOWER "${inTargetType}" inTargetType)
  if(NOT inTargetType IN_LIST GPBT_AVAILABLE_TARGET_TYPES)
    gpbt_log(FATAL "Invalid target type: ${inTargetType}")
  endif()

  # Use the pre-computed clean name passed by gpbt_startTarget (avoids recomputing).
  set(cleanTargetName "${inCleanTargetName}")

  # Generate the alias name
  string(REPLACE "_" "::" defaultAliasName "${cleanTargetName}")

  # Generate the output name
  gpbt_convertCase("kebab-case" "${cleanTargetName}" targetOutputName)

  # Convert the target location to a MD5 guid
  string(MD5 targetGuid "${inTargetLocation}")

  # Discover C/C++ sources in private/ and internal/ subdirectories.
  # CONFIGURE_DEPENDS triggers a reconfigure when files are added/removed; disable it with
  # GPBT_CONFIGURE_DEPENDS=OFF in environments where filesystem polling is expensive (e.g. large CI farms).
  set(_glob_extra_args "")
  if(GPBT_CONFIGURE_DEPENDS)
    list(APPEND _glob_extra_args CONFIGURE_DEPENDS)
  endif()

  file(GLOB_RECURSE targetSources FOLLOW_SYMLINKS ${_glob_extra_args}
    "${inTargetLocation}/private/*.c"
    "${inTargetLocation}/private/*.cc"
    "${inTargetLocation}/private/*.cpp"
    "${inTargetLocation}/private/*.cxx"
    "${inTargetLocation}/internal/*.c"
    "${inTargetLocation}/internal/*.cc"
    "${inTargetLocation}/internal/*.cpp"
    "${inTargetLocation}/internal/*.cxx"
  )

  gpbt_setBulkScopedProperties(
    _targetName "${inTargetName}"
    _targetCleanName "${cleanTargetName}"
    _targetGuid "${targetGuid}"
    _targetType "${inTargetType}"
    _targetOutputName "gp-${targetOutputName}"
    _targetExportName "gp_${cleanTargetName}"
    _targetAliases "gp::${defaultAliasName}"
    _targetLocation "${inTargetLocation}"
    _targetCustomFolder ""

    _targetPreCompiledHeaders ""

    _targetPublicIncludeDirectories "${inTargetLocation}/public"
    _targetInternalIncludeDirectories "${inTargetLocation}/internal"
    _targetPrivateIncludeDirectories "${inTargetLocation}/private"

    _targetPublicDependencies ""
    _targetInternalDependencies ""
    _targetPrivateDependencies ""
    _targetDynamicDependencies ""

    _targetPublicCompileDefinitions ""
    _targetInternalCompileDefinitions ""
    _targetPrivateCompileDefinitions ""

    _targetPublicCompileOptions ""
    _targetInternalCompileOptions ""
    _targetPrivateCompileOptions ""

    _targetPublicLinkOptions ""
    _targetInternalLinkOptions ""
    _targetPrivateLinkOptions ""

    # LTO coupling: compiler file sets this property; linker file reads it and
    # appends the same flag to link options so LTO works at both compile and link time.
    _targetLTOFlag ""

    _targetIsHeaderOnly FALSE
    _targetEnableTests FALSE
    _targetEnableBenchmarks FALSE
    _targetEnableExamples FALSE
    _targetEnableISPC FALSE
    _targetEnableStrictWarnings TRUE
    _targetEnableUnityBuild FALSE
    _targetIsBuildShared TRUE

    _targetExecutableResourceFiles ""
    _targetExecutableEntryPoint ""
    _targetExecutableHasGui FALSE
  )

  # If we're in a monolithic build, we need to set the target to be built as static.
  if(GPBT_IS_MONOLITHIC)
    gpbt_setScopedProperty("_targetIsBuildShared" FALSE)
  endif()

  # Set separately to avoid ARGN list-flattening in gpbt_setBulkScopedProperties
  gpbt_setScopedProperty("_targetSources" "${targetSources}")

  # Check if the target doesn't already exist to prevent duplicate targets from being registered
  gpbt_getProperty(GPBT_TARGETS existingTargets)
  if("${cleanTargetName}" IN_LIST existingTargets)
    gpbt_log(FATAL "Target already exists: ${inTargetName}")
  endif()

  # Add the target to the global list of targets
  gpbt_appendProperty(GPBT_TARGETS "${cleanTargetName}")

  # Set default IDE Folder based on the target type
  if("${inTargetType}" STREQUAL "executable")
    gpbt_setScopedProperty("_targetCustomFolder" "executables")
  elseif("${inTargetType}" STREQUAL "module")
    gpbt_setScopedProperty("_targetCustomFolder" "modules")
  elseif("${inTargetType}" STREQUAL "plugin")
    gpbt_setScopedProperty("_targetCustomFolder" "plugins")
  endif()

  # Set basic compile definitions
  gpbt_appendScopedProperty(_targetPrivateCompileDefinitions
    "$<$<CONFIG:Debug>:GP_BUILD_DEBUG=1>"
    "$<$<CONFIG:Development>:GP_BUILD_DEVELOPMENT=1>"
    "$<$<CONFIG:Profile>:GP_BUILD_PROFILE=1>"
    "$<$<CONFIG:Shipping>:GP_BUILD_SHIPPING=1>"
  )

  # Simple log about the target registration
  gpbt_log(INFO "Registered target: ${inTargetName} (Type: ${inTargetType})")
endfunction()

# @brief Start the definition of a new target.
# @param[in] inTargetType The type of the target (e.g., "executable", "module", "plugin").
# @param[in] inTargetName The name of the target.
# @param[in] inTargetLocation The file system location of the target (used for generating a unique guid and finding source files).
# @remarks This function must be called at the beginning of a target definition and will set up the initial properties for the target.
# @remarks It must be paired with a corresponding gpbt_endTarget() call to properly close the target definition.
function(gpbt_startTarget inTargetType inTargetName inTargetLocation)
  # Check if we're already in a target definition
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION isInTargetDefinition)
  if(isInTargetDefinition)
    gpbt_log(FATAL "gpbt_startTarget called while already in a target definition")
  endif()

  # Set the flag to indicate we're now in a target definition
  gpbt_setProperty(GPBT_IS_IN_TARGET_DEFINITION TRUE)

  # Compute the clean name once here; it is passed to gpbt_setupTargetProperties to avoid
  # computing it a second time and to guarantee the scope key and the registered name match.
  string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanTargetName "${inTargetName}")
  string(TOLOWER "${cleanTargetName}" cleanTargetName)

  # Push a specific scope for the target properties
  gpbt_pushScope("${cleanTargetName}")

  # Set up the initial properties for the target.
  # Will only run during the REGISTRATION phase
  gpbt_setupTargetProperties("${inTargetType}" "${inTargetName}" "${inTargetLocation}" "${cleanTargetName}")
endfunction()

# @brief End the definition of the current target.
# @remarks This function must be called at the end of a target definition to properly close it and perform any necessary finalization steps.
# @remarks If GPBT_DUMP_TARGETS_PROPERTIES is enabled, this function will also dump all properties of the target to the log for debugging purposes.
# @remarks It must be called after a gpbt_startTarget() call to properly close the target definition.
function(gpbt_endTarget)
  gpbt_checkInTargetDefinition("gpbt_endTarget")

  # Append compiler/platform/build-type flags (CONFIGURATION phase only; returns early in REGISTRATION).
  gpbt_applyBuildTypeFlags()

  # Validate no duplicate flags were accumulated from compiler modules (CONFIGURATION phase only).
  gpbt_checkAllDuplicateFlags()

  # Ensure the target has at least one source file (CONFIGURATION phase only).
  gpbt_checkForEmptySources()

  if(GPBT_DUMP_TARGETS_PROPERTIES)
    gpbt_dumpTargetProperties()
  endif()

  # Generate the actual CMake target (CONFIGURATION phase only; each sub-function guards itself).
  gpbt_getScopedProperty(_targetType targetType)
  if(targetType STREQUAL "executable")
    gpbt_defineCMakeExecutableTarget()
  elseif(targetType STREQUAL "module")
    gpbt_defineCMakeModuleTarget()
  elseif(targetType STREQUAL "plugin")
    gpbt_defineCMakePluginTarget()
  else()
    gpbt_log(FATAL "Unknown target type: ${targetType}")
  endif()

  gpbt_popScope()
  gpbt_setProperty(GPBT_IS_IN_TARGET_DEFINITION FALSE)
endfunction()
