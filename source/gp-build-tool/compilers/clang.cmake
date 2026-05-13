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

  gpbt_appendScopedProperty(_targetPrivateCompileOptions "-Wall" "-Wextra" "-Werror")
endfunction()

# @brief Appends build type flags to the current target based on the compiler, platform and build type.
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Debug: No optimization
    "$<$<CONFIG:Debug>:-O0>"

    # Development: Moderate optimization
    "$<$<CONFIG:Development>:-O2>"

    # Profile: Max optimization, retain frame pointers
    "$<$<CONFIG:Profile>:-O3>"
    "$<$<CONFIG:Profile>:-fno-omit-frame-pointer>"

    # Shipping: Max optimization, fast math
    "$<$<CONFIG:Shipping>:-O3>"
    "$<$<CONFIG:Shipping>:-ffast-math>"
  )
endfunction()
