# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Override the IDE folder for the current target.
# @param[in] folderName The folder path shown in the IDE (e.g., "engine/runtime", "tools").
#            By default targets are grouped by type: "modules", "executables", "plugins".
function(gpbt_setFolder folderName)
  gpbt_checkInTargetDefinition("gpbt_setFolder")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetCustomFolder "${folderName}")
  gpbt_log(VERBOSE "Set IDE folder to '${folderName}'")
endfunction()

# @brief Add an additional CMake alias for the current target.
# @param[in] aliasName The alias name (e.g., "mylib::v2"). Must be a valid CMake target name.
# @remarks A default alias "gp::<clean_name>" is always created automatically.
function(gpbt_addAlias aliasName)
  gpbt_checkInTargetDefinition("gpbt_addAlias")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_appendScopedProperty(_targetAliases "${aliasName}")
  gpbt_log(VERBOSE "Added alias '${aliasName}'")
endfunction()

# @brief Mark the current executable target as a GUI application on Windows.
# @remarks Sets WIN32_EXECUTABLE=ON so the entry point is WinMain instead of main,
#          and the console window is not created. No effect on non-Windows platforms.
function(gpbt_setGuiExecutable)
  gpbt_checkInTargetDefinition("gpbt_setGuiExecutable")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_setScopedProperty(_targetExecutableHasGui TRUE)
  gpbt_log(VERBOSE "Marked target as GUI executable (WIN32_EXECUTABLE=ON on Windows)")
endfunction()

# @brief Set a custom entry point source file for an executable target.
# @param[in] entryPointFile Path to the entry point source file (absolute or relative to target location).
# @remarks The file is added to the executable separately from the regular source scan so it can
#          be a platform-specific stub (e.g., WinMain wrapper).
function(gpbt_setEntryPoint entryPointFile)
  gpbt_checkInTargetDefinition("gpbt_setEntryPoint")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_getScopedProperty(_targetLocation targetLocation)
  if(NOT IS_ABSOLUTE "${entryPointFile}")
    set(entryPointFile "${targetLocation}/${entryPointFile}")
  endif()
  get_filename_component(entryPointFile "${entryPointFile}" ABSOLUTE)
  gpbt_setScopedProperty(_targetExecutableEntryPoint "${entryPointFile}")
  gpbt_log(VERBOSE "Set entry point to '${entryPointFile}'")
endfunction()

# @brief Add a platform resource file to an executable target (e.g., a .rc file on Windows).
# @param[in] resourceFile Path to the resource file (absolute or relative to target location).
function(gpbt_addResourceFile resourceFile)
  gpbt_checkInTargetDefinition("gpbt_addResourceFile")
  gpbt_runOnlyDuringPhase("REGISTRATION")
  gpbt_getScopedProperty(_targetLocation targetLocation)
  if(NOT IS_ABSOLUTE "${resourceFile}")
    set(resourceFile "${targetLocation}/${resourceFile}")
  endif()
  get_filename_component(resourceFile "${resourceFile}" ABSOLUTE)
  gpbt_appendScopedProperty(_targetExecutableResourceFiles "${resourceFile}")
  gpbt_log(VERBOSE "Added resource file '${resourceFile}'")
endfunction()
