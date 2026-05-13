# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# @brief Check if the current function is being called within a target definition.
# @param[in] functionName The name of the function to check (for error messages).
macro(gpbt_checkInTargetDefinition functionName)
  gpbt_getProperty(GPBT_IS_IN_TARGET_DEFINITION isInTargetDefinition)
  if(NOT isInTargetDefinition)
    gpbt_log(FATAL "${functionName} called without a matching gpbt_startTarget")
  endif()
endmacro()

# @brief Check if the current function is being called within a specific phase.
# @param[in] phaseName The name of the phase to check (e.g., "REGISTRATION", "CONFIGURATION", "GENERATION").
macro(gpbt_runOnlyDuringPhase phaseName)
  gpbt_getProperty(GPBT_CURRENT_PHASE currentPhase)
  if(NOT currentPhase STREQUAL "${phaseName}")
    return()
  endif()
endmacro()

# @brief Retreive all properties of the current target and store them in local variables for easier access.
macro(gpbt_getAllScopedTargetProperty)
  gpbt_checkInTargetDefinition("gpbt_getAllScopedTargetProperty")

  gpbt_getScopedProperty(_targetName targetName)
  gpbt_getScopedProperty(_targetCleanName targetCleanName)
  gpbt_getScopedProperty(_targetGuid targetGuid)
  gpbt_getScopedProperty(_targetType targetType)
  gpbt_getScopedProperty(_targetOutputName targetOutputName)
  gpbt_getScopedProperty(_targetExportName targetExportName)
  gpbt_getScopedProperty(_targetAliases targetAliases)
  gpbt_getScopedProperty(_targetLocation targetLocation)
  gpbt_getScopedProperty(_targetCustomFolder targetCustomFolder)
  gpbt_getScopedProperty(_targetSources targetSources)
  gpbt_getScopedProperty(_targetPreCompiledHeaders targetPreCompiledHeaders)
  gpbt_getScopedProperty(_targetPublicIncludeDirectories targetPublicIncludeDirectories)
  gpbt_getScopedProperty(_targetInternalIncludeDirectories targetInternalIncludeDirectories)
  gpbt_getScopedProperty(_targetPrivateIncludeDirectories targetPrivateIncludeDirectories)
  gpbt_getScopedProperty(_targetPublicDependencies targetPublicDependencies)
  gpbt_getScopedProperty(_targetInternalDependencies targetInternalDependencies)
  gpbt_getScopedProperty(_targetPrivateDependencies targetPrivateDependencies)
  gpbt_getScopedProperty(_targetDynamicDependencies targetDynamicDependencies)
  gpbt_getScopedProperty(_targetPublicCompileDefinitions targetPublicCompileDefinitions)
  gpbt_getScopedProperty(_targetInternalCompileDefinitions targetInternalCompileDefinitions)
  gpbt_getScopedProperty(_targetPrivateCompileDefinitions targetPrivateCompileDefinitions)
  gpbt_getScopedProperty(_targetPublicCompileOptions targetPublicCompileOptions)
  gpbt_getScopedProperty(_targetInternalCompileOptions targetInternalCompileOptions)
  gpbt_getScopedProperty(_targetPrivateCompileOptions targetPrivateCompileOptions)
  gpbt_getScopedProperty(_targetIsHeaderOnly targetIsHeaderOnly)
  gpbt_getScopedProperty(_targetEnableTests targetEnableTests)
  gpbt_getScopedProperty(_targetEnableBenchmarks targetEnableBenchmarks)
  gpbt_getScopedProperty(_targetEnableExamples targetEnableExamples)
  gpbt_getScopedProperty(_targetEnableISPC targetEnableISPC)
  gpbt_getScopedProperty(_targetEnableStrictWarnings targetEnableStrictWarnings)
  gpbt_getScopedProperty(_targetEnableUnityBuild targetEnableUnityBuild)
endmacro()
