# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/shared)

# @brief Appends strict warning flags to the current target based on the compiler and platform.
function(gpbt_appendStrictWarnings)
  gpbt_checkInTargetDefinition("gpbt_appendStrictWarnings")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
  # Default implementation does nothing.
endfunction()
