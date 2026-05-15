# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/target-props)

macro(gpbt_applyTargetProperties)
  gpbt_checkInTargetDefinition("gpbt_applyTargetProperties")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Convert the clean name to uppercase for the export macro definition (e.g. GP_CORE_EXPORTS).
  string(TOUPPER "${targetCleanName}" targetCleanNameUpper)

  gpbt_log(INFO "Applying properties for target: ${targetName} (Type: ${targetType})")

  # CXX_VISIBILITY_PRESET is set to hidden to match the -fvisibility=hidden compiler flag
  # applied by the GCC/Clang compiler modules. VISIBILITY_INLINES_HIDDEN is kept OFF here
  # because the compiler modules already handle it via -fvisibility-inlines-hidden.
  set_target_properties(${targetExportName} PROPERTIES
    OUTPUT_NAME "${targetOutputName}"
    DEFINE_SYMBOL "GP_${targetCleanNameUpper}_EXPORTS"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    POSITION_INDEPENDENT_CODE ON
    FOLDER "${targetCustomFolder}"
  )

  # On Windows shared libraries, WINDOWS_EXPORT_ALL_SYMBOLS auto-generates the __declspec(dllexport)
  # decorators so callers don't need manual GP_API annotations during early development.
  # This is intentionally mutually exclusive with -fvisibility=hidden (which only affects ELF/Mach-O).
  if(WIN32 AND targetIsBuildShared)
    set_target_properties(${targetExportName} PROPERTIES
      WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
    gpbt_log(VERBOSE "Enabled WINDOWS_EXPORT_ALL_SYMBOLS for target ${targetName} since it's a shared library on Windows")
  endif()

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

  target_include_directories(${targetExportName}
    PUBLIC
      $<BUILD_INTERFACE:${targetPublicIncludeDirectories}>
      $<INSTALL_INTERFACE:include/${targetName}>
    PRIVATE
      ${targetPrivateIncludeDirectories}
      ${targetInternalIncludeDirectories} # TODO: INTERNAL include dirs need cross-module visibility semantics.
  )
endmacro()

macro(gpbt_applyPreCompiledHeaders)
  gpbt_checkInTargetDefinition("gpbt_applyPreCompiledHeaders")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  list(LENGTH targetPreCompiledHeaders numPCH)
  if(numPCH GREATER 0)
    target_precompile_headers(${targetExportName} PRIVATE ${targetPreCompiledHeaders})
    gpbt_log(VERBOSE "Added precompiled headers to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyCompileDefinitions)
  gpbt_checkInTargetDefinition("gpbt_applyCompileDefinitions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  list(LENGTH targetPublicCompileDefinitions numPublicDefs)
  if(numPublicDefs GREATER 0)
    target_compile_definitions(${targetExportName} PUBLIC ${targetPublicCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numPublicDefs} public compile definitions to target ${targetName}")
  endif()

  # INTERNAL definitions are propagated between modules but not to end-user consumers.
  # They are mapped to PRIVATE at the CMake level for now; cross-module propagation
  # will be handled by the INTERNAL include directory mechanism when implemented.
  list(LENGTH targetInternalCompileDefinitions numInternalDefs)
  if(numInternalDefs GREATER 0)
    target_compile_definitions(${targetExportName} PRIVATE ${targetInternalCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numInternalDefs} internal compile definitions to target ${targetName}")
  endif()

  list(LENGTH targetPrivateCompileDefinitions numPrivateDefs)
  if(numPrivateDefs GREATER 0)
    target_compile_definitions(${targetExportName} PRIVATE ${targetPrivateCompileDefinitions})
    gpbt_log(VERBOSE "Added ${numPrivateDefs} private compile definitions to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyCompileFeatures)
  gpbt_checkInTargetDefinition("gpbt_applyCompileFeatures")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  target_compile_features(${targetExportName} PUBLIC cxx_std_23)
  gpbt_log(VERBOSE "Enforced C++23 standard for target ${targetName}")
endmacro()

macro(gpbt_applyCompileOptions)
  gpbt_checkInTargetDefinition("gpbt_applyCompileOptions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  list(LENGTH targetPublicCompileOptions numPublicOpts)
  if(numPublicOpts GREATER 0)
    target_compile_options(${targetExportName} PUBLIC ${targetPublicCompileOptions})
    gpbt_log(VERBOSE "Added ${numPublicOpts} public compile options to target ${targetName}")
  endif()

  list(LENGTH targetInternalCompileOptions numInternalOpts)
  if(numInternalOpts GREATER 0)
    target_compile_options(${targetExportName} PRIVATE ${targetInternalCompileOptions})
    gpbt_log(VERBOSE "Added ${numInternalOpts} internal compile options to target ${targetName}")
  endif()

  list(LENGTH targetPrivateCompileOptions numPrivateOpts)
  if(numPrivateOpts GREATER 0)
    target_compile_options(${targetExportName} PRIVATE ${targetPrivateCompileOptions})
    gpbt_log(VERBOSE "Added ${numPrivateOpts} private compile options to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyLinkOptions)
  gpbt_checkInTargetDefinition("gpbt_applyLinkOptions")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  list(LENGTH targetPublicLinkOptions numPublicOpts)
  if(numPublicOpts GREATER 0)
    target_link_options(${targetExportName} PUBLIC ${targetPublicLinkOptions})
    gpbt_log(VERBOSE "Added ${numPublicOpts} public link options to target ${targetName}")
  endif()

  list(LENGTH targetInternalLinkOptions numInternalOpts)
  if(numInternalOpts GREATER 0)
    target_link_options(${targetExportName} PRIVATE ${targetInternalLinkOptions})
    gpbt_log(VERBOSE "Added ${numInternalOpts} internal link options to target ${targetName}")
  endif()

  list(LENGTH targetPrivateLinkOptions numPrivateOpts)
  if(numPrivateOpts GREATER 0)
    target_link_options(${targetExportName} PRIVATE ${targetPrivateLinkOptions})
    gpbt_log(VERBOSE "Added ${numPrivateOpts} private link options to target ${targetName}")
  endif()
endmacro()

macro(gpbt_applyDependencies)
  gpbt_checkInTargetDefinition("gpbt_applyDependencies")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_resolveDependencyList(targetPublicDependencies resolvedPublicDependencies)
  list(LENGTH resolvedPublicDependencies numPublicDeps)
  if(numPublicDeps GREATER 0)
    target_link_libraries(${targetExportName} PUBLIC ${resolvedPublicDependencies})
    gpbt_log(VERBOSE "Linked ${numPublicDeps} public dependencies to target ${targetName}")
  endif()

  # INTERNAL dependencies: linked privately here; cross-module header access is handled
  # by the INTERNAL include directories (TODO: implement propagation mechanism).
  gpbt_resolveDependencyList(targetInternalDependencies resolvedInternalDependencies)
  list(LENGTH resolvedInternalDependencies numInternalDeps)
  if(numInternalDeps GREATER 0)
    target_link_libraries(${targetExportName} PRIVATE ${resolvedInternalDependencies})
    gpbt_log(VERBOSE "Linked ${numInternalDeps} internal dependencies to target ${targetName}")
  endif()

  gpbt_resolveDependencyList(targetPrivateDependencies resolvedPrivateDependencies)
  list(LENGTH resolvedPrivateDependencies numPrivateDeps)
  if(numPrivateDeps GREATER 0)
    target_link_libraries(${targetExportName} PRIVATE ${resolvedPrivateDependencies})
    gpbt_log(VERBOSE "Linked ${numPrivateDeps} private dependencies to target ${targetName}")
  endif()

  # DYNAMIC dependencies: listed in the dependency graph for build-order purposes but not
  # linked. They represent modules loaded at runtime via dlopen/LoadLibrary.
  # TODO: Generate a header with symbol paths for each dynamic dependency.
  list(LENGTH targetDynamicDependencies numDynamicDeps)
  if(numDynamicDeps GREATER 0)
    gpbt_log(VERBOSE "Target ${targetName} has ${numDynamicDeps} dynamic (runtime-loaded) dependencies: ${targetDynamicDependencies}")
  endif()
endmacro()

macro(gpbt_applyTargetInstallation)
  gpbt_checkInTargetDefinition("gpbt_applyTargetInstallation")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # GPBT_INSTALL_EXPORT_NAME is set in config.cmake and defaults to "GPTargets".
  install(TARGETS ${targetExportName}
    EXPORT "${GPBT_INSTALL_EXPORT_NAME}"
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
  )

  # Install public headers; iterate over the list variable (not its expansion).
  foreach(_dir IN LISTS targetPublicIncludeDirectories)
    if(EXISTS "${_dir}")
      install(DIRECTORY "${_dir}/"
        DESTINATION "include/${targetName}"
        FILES_MATCHING
          PATTERN "*.h"
          PATTERN "*.hpp"
          PATTERN "*.hh"
          PATTERN "*.hxx"
      )
    endif()
  endforeach()

  gpbt_log(VERBOSE "Setup installation rules for target ${targetName}")
endmacro()
