# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/compilers/default)

# @brief Appends strict warning flags to the current target based on the compiler and platform.
function(gpbt_appendStrictWarnings)
  gpbt_checkInTargetDefinition("gpbt_appendStrictWarnings")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_appendScopedProperty(_targetPrivateCompileOptions "/W4" "/WX" "/Wpermissive-")
endfunction()

# @brief Appends build type flags to the current target based on the compiler, platform and build type.
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Debug: Disable all optimizations for stepping through code
    "$<$<CONFIG:Debug>:/Od>"

    # Development: Fast execution, reasonable compile times
    "$<$<CONFIG:Development>:/O2>"

    # Profile: Max speed, but explicitly disable frame-pointer omission (/Oy-) for profilers
    "$<$<CONFIG:Profile>:/O2>"
    "$<$<CONFIG:Profile>:/Oy->"

    # Shipping: Max speed, enable intrinsic functions (/Oi), and fast floating-point math
    "$<$<CONFIG:Shipping>:/O2>"
    "$<$<CONFIG:Shipping>:/Oi>"
    "$<$<CONFIG:Shipping>:/fp:fast>"
  )
endfunction()
