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
endfunction()
