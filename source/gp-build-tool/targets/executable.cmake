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

  gpbt_getScopedProperty(_targetType targetType)
  gpbt_getScopedProperty(_targetName targetName)
  gpbt_log(INFO "Configuration of cmake target for: ${targetName} (Type: ${targetType})")
endfunction()
