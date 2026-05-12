# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)

if(GPBT_DUMP_TARGETS_PROPERTIES)
  include(gp-build-tool/targets/utilities/dump)
endif()

set(GPBT_AVAILABLE_TARGET_TYPES "executable;module;plugin")

function(gpbt_startTarget inTargetType inTargetName inTargetLocation)
  # Check if we're already in a target definition
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION isInTargetDefinition)
  if(isInTargetDefinition)
    gpbt_log(FATAL "gpbt_startTarget called while already in a target definition")
  endif()

  # Set the flag to indicate we're now in a target definition
  gpbt_setProperty(GPBT_IS_IN_TARGET_DEFINITION TRUE)

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

  # Push a specific scope for the target properties
  gpbt_pushScope("${cleanTargetName}")

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
endfunction()

function(gpbt_endTarget)
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION isInTargetDefinition)
  if(NOT isInTargetDefinition)
    gpbt_log(FATAL "gpbt_endTarget called without a matching gpbt_startTarget")
  endif()

  if(GPBT_DUMP_TARGETS_PROPERTIES)
    gpbt_dumpTargetProperties()
  endif()

  gpbt_popScope()

  gpbt_setProperty(GPBT_IS_IN_TARGET_DEFINITION FALSE)
endfunction()
