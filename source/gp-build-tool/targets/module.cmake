# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/target-props)
include(gp-build-tool/targets/shared)

function(gpbt_defineCMakeModuleTarget)
  gpbt_checkInTargetDefinition("gpbt_defineCMakeModuleTarget")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getAllScopedTargetProperty()

  gpbt_log(INFO "Configuration of cmake target for: ${targetName} (Type: ${targetType})")

  # Gather header files from all include directories for IDE visibility.
  set(targetHeaders "")
  foreach(includeDir IN LISTS targetPublicIncludeDirectories targetInternalIncludeDirectories targetPrivateIncludeDirectories)
    file(GLOB_RECURSE includeFiles
      "${includeDir}/*.h" "${includeDir}/*.hpp"
      "${includeDir}/*.hh" "${includeDir}/*.hxx")
    list(APPEND targetHeaders ${includeFiles})
  endforeach()

  list(LENGTH targetSources numSources)
  list(LENGTH targetHeaders numHeaders)
  gpbt_log(VERBOSE "Found ${numSources} source files and ${numHeaders} header files for target ${targetName}")

  if(targetIsHeaderOnly)
    # Header-only targets must be INTERFACE libraries: no compilation, all usage requirements
    # are INTERFACE-propagated. Sources are intentionally not passed to add_library.
    add_library(${targetExportName} INTERFACE)
    gpbt_log(VERBOSE "Created CMake INTERFACE library target: ${targetExportName}")
    foreach(alias IN LISTS targetAliases)
      add_library(${alias} ALIAS ${targetExportName})
      gpbt_log(VERBOSE "Created CMake alias target: ${alias} -> ${targetExportName}")
    endforeach()

    # For INTERFACE targets only INTERFACE-scoped commands are valid.
    target_include_directories(${targetExportName}
      INTERFACE
        $<BUILD_INTERFACE:${targetPublicIncludeDirectories}>
        $<INSTALL_INTERFACE:include/${targetName}>
    )
    target_compile_features(${targetExportName} INTERFACE cxx_std_23)
    gpbt_applyTargetInstallation()
  else()
    # Regular (compiled) library target.
    if(targetIsBuildShared)
      add_library(${targetExportName} SHARED ${targetSources} ${targetHeaders})
      gpbt_log(VERBOSE "Created CMake shared library target: ${targetExportName}")
    else()
      add_library(${targetExportName} STATIC ${targetSources} ${targetHeaders})
      gpbt_log(VERBOSE "Created CMake static library target: ${targetExportName}")
    endif()
    foreach(alias IN LISTS targetAliases)
      add_library(${alias} ALIAS ${targetExportName})
      gpbt_log(VERBOSE "Created CMake alias target: ${alias} -> ${targetExportName}")
    endforeach()

    gpbt_applyTargetProperties()
    gpbt_applyIncludeDirectories()
    gpbt_applyPreCompiledHeaders()
    gpbt_applyCompileDefinitions()
    gpbt_applyCompileFeatures()
    gpbt_applyCompileOptions()
    gpbt_applyLinkOptions()
    gpbt_applyDependencies()
    gpbt_applyTargetInstallation()
  endif()
endfunction()
