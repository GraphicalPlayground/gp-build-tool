# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/shared)

function(gpbt_defineCMakeExecutableTarget)
  gpbt_checkInTargetDefinition("gpbt_defineCMakeExecutableTarget")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Get all the properties of the current target and store them in local variables.
  gpbt_getAllScopedTargetProperty()

  # Log the configuration of the target for better visibility in the build output.
  gpbt_log(INFO "Configuration of cmake target for: ${targetName} (Type: ${targetType})")

  # Gather all the headers files
  set(targetHeaders "")
  foreach(includeDir IN_LIST ${targetPublicIncludeDirectories} ${targetInternalIncludeDirectories} ${targetPrivateIncludeDirectories})
    file(GLOB_RECURSE includeFiles "${includeDir}/*.h" "${includeDir}/*.hpp" "${includeDir}/*.hh" "${includeDir}/*.hxx")
    list(APPEND targetHeaders ${includeFiles})
  endforeach()

  # Verbose logging number of source and header files found for the target
  list(LENGTH targetSources numSources)
  list(LENGTH targetHeaders numHeaders)
  gpbt_log(VERBOSE "Found ${numSources} source files and ${numHeaders} header files for target ${targetName}")

  # Create the executable
  add_executable(${targetExportName} ${targetSources} ${targetHeaders} ${targetExecutableResourceFiles} ${targetExecutableEntryPoint})
  gpbt_log(VERBOSE "Created CMake executable target: ${targetExportName}")
  foreach(alias IN LISTS targetAliases)
    add_executable(${alias} ALIAS ${targetExportName})
    gpbt_log(VERBOSE "Created CMake alias target: ${alias} -> ${targetExportName}")
  endforeach()

  # Set the WIN32_EXECUTABLE property if the target is a GUI application on Windows
  if(WIN32)
    set_target_properties(${targetExportName} PROPERTIES WIN32_EXECUTABLE ${targetExecutableHasGui})
    gpbt_log(VERBOSE "Set WIN32_EXECUTABLE to ${targetExecutableHasGui} for target ${targetName} on Windows")
  endif()

  # Apply all options and properties to the target
  gpbt_applyTargetProperties()
  gpbt_applyIncludeDirectories()
  gpbt_applyPreCompiledHeaders()
  gpbt_applyCompileDefinitions()
  gpbt_applyCompileFeatures()
  gpbt_applyCompileOptions()
  gpbt_applyLinkOptions()
  gpbt_applyDependencies()
  gpbt_applyTargetInstallation()
endfunction()
