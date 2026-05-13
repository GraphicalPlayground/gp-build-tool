# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/shared)
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
  include(gp-build-tool/compilers/clang)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  include(gp-build-tool/compilers/gcc)
else()
  gpbt_log(WARNING "Unsupported compiler: ${CMAKE_CXX_COMPILER_ID}. Default compiler settings will be used, which may lead to suboptimal builds or compatibility issues.")
endif()

include(gp-build-tool/platforms/default)
if(WIN32)
  include(gp-build-tool/platforms/windows)
elseif(APPLE)
  include(gp-build-tool/platforms/macos)
elseif(UNIX)
  include(gp-build-tool/platforms/linux)
else()
  gpbt_log(WARNING "Unsupported platform: ${CMAKE_SYSTEM_NAME}. Default platform settings will be used, which may lead to suboptimal builds or compatibility issues.")
endif()

set(GPBT_AVAILABLE_TARGET_TYPES "executable;module;plugin")

# @brief Internal function to set up the properties for a new target definition.
# @param[in] inTargetType The type of the target (e.g., "executable", "module", "plugin").
# @param[in] inTargetName The name of the target.
# @param[in] inTargetLocation The file system location of the target (used for generating a unique guid and finding source files).
# @remarks This function only run on the REGISTRATION phase.
function(gpbt_setupTargetProperties inTargetType inTargetName inTargetLocation)
  gpbt_checkInTargetDefinition("gpbt_setupTargetProperties")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  # Check if the provided target type is valid
  string(TOLOWER "${inTargetType}" inTargetType)
  if(NOT inTargetType IN_LIST GPBT_AVAILABLE_TARGET_TYPES)
    gpbt_log(FATAL "Invalid target type: ${inTargetType}")
  endif()

  # Clean the target name
  string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanTargetName "${inTargetName}")
  string(TOLOWER cleanTargetName "${cleanTargetName}")

  # Generate the alias name
  string(REPLACE "_" "::" defaultAliasName "${cleanTargetName}")

  # Generate the output name
  gpbt_convertCase("kebab-case" "${cleanTargetName}" targetOutputName)

  # Convert the target location to a MD5 guid
  string(MD5 targetGuid "${inTargetLocation}")

  # Find C/C++ sources in the `/private` and `/internal` folders
  file(GLOB_RECURSE targetSources FOLLOW_SYMLINKS CONFIGURE_DEPENDS
    # Private folder
    "${inTargetLocation}/private/*.c"
    "${inTargetLocation}/private/*.cc"
    "${inTargetLocation}/private/*.cpp"
    "${inTargetLocation}/private/*.cxx"

    # Internal folder
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

    _targetIsHeaderOnly FALSE
    _targetEnableTests FALSE
    _targetEnableBenchmarks FALSE
    _targetEnableExamples FALSE
    _targetEnableISPC FALSE
    _targetEnableStrictWarnings TRUE
    _targetEnableUnityBuild FALSE
  )

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

  # Clean the target name
  string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanTargetName "${inTargetName}")
  string(TOLOWER cleanTargetName "${cleanTargetName}")

  # Push a specific scope for the target properties
  gpbt_pushScope("${cleanTargetName}")

  # Set up the initial properties for the target.
  # Will only run during the REGISTRATION phase
  gpbt_setupTargetProperties("${inTargetType}" "${inTargetName}" "${inTargetLocation}")
endfunction()

# @brief End the definition of the current target.
# @remarks This function must be called at the end of a target definition to properly close it and perform any necessary finalization steps.
# @remarks If GPBT_DUMP_TARGETS_PROPERTIES is enabled, this function will also dump all properties of the target to the log for debugging purposes.
# @remarks It must be called after a gpbt_startTarget() call to properly close the target definition.
function(gpbt_endTarget)
  gpbt_checkInTargetDefinition("gpbt_endTarget")

  # Apply build type flags based on the compiler, platform and build type.
  # This will append the appropriate compiler flags based on the current build type (Debug, Development, Profile, Shipping) and the compiler being used.
  gpbt_applyBuildTypeFlags()

  # Check for target with empty sources, which is usually a mistake and should be avoided.
  # This will log a warning to alert the user about the potential issue.
  gpbt_checkForEmptySources()

  if(GPBT_DUMP_TARGETS_PROPERTIES)
    # Will only run during the CONFIGURATION phase
    gpbt_dumpTargetProperties()
  endif()

  # Generate the actual CMake target based on the target type (executable, module, plugin).
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

  # Clean up the target properties by popping the scope and resetting the in-target-definition flag.
  gpbt_popScope()
  gpbt_setProperty(GPBT_IS_IN_TARGET_DEFINITION FALSE)
endfunction()
