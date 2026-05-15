# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/shared)

macro(gpbt_applyTargetProperties)
  gpbt_checkInTargetDefinition("gpbt_applyTargetProperties")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Convert the clean name to uppercase for use in the export macro definition
  string(TOUPPER "${targetCleanName}" targetCleanNameUpper)

  # Log the application of properties for better visibility in the build output.
  gpbt_log(INFO "Applying properties for target: ${targetName} (Type: ${targetType})")

  # Set the target properties based on the collected information.
  set_target_properties(${targetExportName} PROPERTIES
    OUTPUT_NAME "${targetOutputName}"
    DEFINE_SYMBOL "GP_${targetCleanNameUpper}_EXPORTS"
    CXX_VISIBILITY_PRESET default
    VISIBILITY_INLINES_HIDDEN OFF
    POSITION_INDEPENDENT_CODE ON
    FOLDER "${targetCustomFolder}"
  )

  # On Windows, if the target is a shared library, we need to ensure that all symbols are exported.
  if(WIN32 AND targetIsBuildShared)
    set_target_properties(${targetExportName} PROPERTIES
      WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
    gpbt_log(VERBOSE "Enabled WINDOWS_EXPORT_ALL_SYMBOLS for target ${targetName} since it's a shared library on Windows")
  endif()

  # If Unity Build is enabled for this target, set the appropriate properties to enable it in CMake.
  if(targetEnableUnityBuild)
    set_target_properties(${targetExportName} PROPERTIES
      UNITY_BUILD ON
      UNITY_BUILD_BATCH_SIZE 16
    )
    gpbt_log(VERBOSE "Enabled Unity Build for target ${targetName} with batch size 16")
  endif()
endmacro()

macro(gpbt_applyIncludeDirectories)
  gpbt_checkInTargetDefinition("gpbt_applyIncludeDirectories")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply public include directories
  target_include_directories(${targetExportName}
    PUBLIC
      $<BUILD_INTERFACE:${targetPublicIncludeDirectories}>
      $<INSTALL_INTERFACE:include/${targetName}>
    PRIVATE
      ${targetPrivateIncludeDirectories}
      ${targetInternalIncludeDirectories} # TODO: Internal need to be fixed.
  )
endmacro()

macro(gpbt_applyPreCompiledHeaders)
  gpbt_checkInTargetDefinition("gpbt_applyPreCompiledHeaders")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply precompiled headers if any are specified for this target.
  list(LENGTH targetPreCompiledHeaders numPCH)
  if(numPCH GREATER 0)
    target_precompile_headers(${targetExportName} PRIVATE ${targetPreCompiledHeaders})
    gpbt_log(VERBOSE "Added precompiled headers to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyCompileDefinitions)
  gpbt_checkInTargetDefinition("gpbt_applyCompileDefinitions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply compile definitions based on their public visibility.
  list(LENGTH targetPublicCompileDefinitions numPublicDefs)
  if(numPublicDefs GREATER 0)
    target_compile_definitions(${targetExportName} PUBLIC ${targetPublicCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numPublicDefs} public compile definitions to target ${targetName}")
  endif()

  # Apply compile definitions based on their internal visibility.
  list(LENGTH targetInternalCompileDefinitions numInternalDefs)
  if(numInternalDefs GREATER 0)
    target_compile_definitions(${targetExportName} PRIVATE ${targetInternalCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numInternalDefs} internal compile definitions to target ${targetName}")
  endif()

  # Apply compile definitions based on their private visibility.
  list(LENGTH targetPrivateCompileDefinitions numPrivateDefs)
  if(numPrivateDefs GREATER 0)
    target_compile_definitions(${targetExportName} PRIVATE ${targetPrivateCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numPrivateDefs} private compile definitions to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyCompileFeatures)
  gpbt_checkInTargetDefinition("gpbt_applyCompileFeatures")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply compile features to enforce C++23 standard for this target.
  target_compile_features(${targetExportName} PUBLIC cxx_std_23)
  gpbt_log(VERBOSE "Enforced C++23 standard for target ${targetName}")
endmacro()

macro(gpbt_applyCompileOptions)
  gpbt_checkInTargetDefinition("gpbt_applyCompileOptions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply compile options based on their public visibility.
  list(LENGTH targetPublicCompileOptions numPublicOpts)
  if(numPublicOpts GREATER 0)
    target_compile_options(${targetExportName} PUBLIC ${targetPublicCompileOptions})
    gpbt_log(VERBOSE "Added ${numPublicOpts} public compile options to target ${targetName}")
  endif()

  # Apply compile options based on their internal visibility.
  list(LENGTH targetInternalCompileOptions numInternalOpts)
  if(numInternalOpts GREATER 0)
    target_compile_options(${targetExportName} PRIVATE ${targetInternalCompileOptions})
    gpbt_log(VERBOSE "Added ${numInternalOpts} internal compile options to target ${targetName}")
  endif()

  # Apply compile options based on their private visibility.
  list(LENGTH targetPrivateCompileOptions numPrivateOpts)
  if(numPrivateOpts GREATER 0)
    target_compile_options(${targetExportName} PRIVATE ${targetPrivateCompileOptions})
    gpbt_log(VERBOSE "Added ${numPrivateOpts} private compile options to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyLinkOptions)
  gpbt_checkInTargetDefinition("gpbt_applyLinkOptions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Apply link options based on their public visibility.
  list(LENGTH targetPublicLinkOptions numPublicOpts)
  if(numPublicOpts GREATER 0)
    target_link_options(${targetExportName} PUBLIC ${targetPublicLinkOptions})
    gpbt_log(VERBOSE "Added ${numPublicOpts} public link options to target ${targetName}")
  endif()

  # Apply link options based on their internal visibility.
  list(LENGTH targetInternalLinkOptions numInternalOpts)
  if(numInternalOpts GREATER 0)
    target_link_options(${targetExportName} PRIVATE ${targetInternalLinkOptions})
    gpbt_log(VERBOSE "Added ${numInternalOpts} internal link options to target ${targetName}")
  endif()

  # Apply link options based on their private visibility.
  list(LENGTH targetPrivateLinkOptions numPrivateOpts)
  if(numPrivateOpts GREATER 0)
    target_link_options(${targetExportName} PRIVATE ${targetPrivateLinkOptions})
    gpbt_log(VERBOSE "Added ${numPrivateOpts} private link options to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyDependencies)
  gpbt_checkInTargetDefinition("gpbt_applyDependencies")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Resolve and link public dependencies, which will be propagated to consumers of this target.
  gpbt_resolveDependencyList(targetPublicDependencies resolvedPublicDependencies)
  list(LENGTH resolvedPublicDependencies numPublicDeps)
  if(numPublicDeps GREATER 0)
    target_link_libraries(${targetExportName} PUBLIC ${resolvedPublicDependencies})
    gpbt_log(VERBOSE "Linked ${numPublicDeps} public dependencies to target ${targetName}")
  endif()

  # Resolve and link internal dependencies, which will not be propagated to consumers of this target.
  gpbt_resolveDependencyList(targetInternalDependencies resolvedInternalDependencies)
  list(LENGTH resolvedInternalDependencies numInternalDeps)
  if(numInternalDeps GREATER 0)
    target_link_libraries(${targetExportName} PRIVATE ${resolvedInternalDependencies})
    gpbt_log(VERBOSE "Linked ${numInternalDeps} internal dependencies to target ${targetName}")
  endif()

  # Resolve and link private dependencies, which will not be propagated to consumers of this target.
  gpbt_resolveDependencyList(targetPrivateDependencies resolvedPrivateDependencies)
  list(LENGTH resolvedPrivateDependencies numPrivateDeps)
  if(numPrivateDeps GREATER 0)
    target_link_libraries(${targetExportName} PRIVATE ${resolvedPrivateDependencies})
    gpbt_log(VERBOSE "Linked ${numPrivateDeps} private dependencies to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyTargetInstallation)
  gpbt_checkInTargetDefinition("gpbt_applyTargetInstallation")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Setup installation rules for the target (optional, but common for libraries)
  install(TARGETS ${targetExportName}
    EXPORT GPEngineTargets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
  )

  # Install public headers to the appropriate location under include/ for this target.
  foreach(_dir IN LISTS ${targetPublicIncludeDirectories})
    install(DIRECTORY ${_dir}/
      DESTINATION include/${targetName}
      FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hh" PATTERN "*.hxx"
    )
  endforeach()

  # Log the installation setup for better visibility in the build output.
  gpbt_log(VERBOSE "Setup installation rules for target ${targetName}")
endmacro()
