# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com
# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/compilers/default)

# @brief Appends strict warning flags to the current target based on the compiler and platform.
function(gpbt_appendStrictWarnings)
  gpbt_checkInTargetDefinition("gpbt_appendStrictWarnings")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_appendScopedProperty(_targetPrivateCompileOptions "-Wall")
  gpbt_appendScopedProperty(_targetPrivateCompileOptions "-Wextra")
  gpbt_appendScopedProperty(_targetPrivateCompileOptions "-Werror")
endfunction()
