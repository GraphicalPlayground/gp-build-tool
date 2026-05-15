# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/linkers/default)

# @brief MSVC link.exe linker flag specialization of gpbt_applyLinkerFlags.
#
# Applies to: MSVC toolchain on Windows (link.exe invoked by cl.exe).
#
# Flag contract
#   /LTCG                  – Link-Time Code Generation; required to pair with /GL in msvc.cmake (Shipping)
#   /OPT:REF               – Remove unreferenced functions and data (Shipping; requires /Gy in compile step)
#   /OPT:ICF               – Identical COMDAT folding: merge duplicate function bodies (Shipping)
#
# Note: /LTCG must pair with /GL (Whole-Program Optimization) set in msvc.cmake.
#       The LTO coupling here uses _targetLTOFlag but MSVC uses a different mechanism
#       (/GL at compile + /LTCG at link) so we apply /LTCG directly rather than re-using the flag.
function(gpbt_applyLinkerFlags)
  gpbt_checkInTargetDefinition("gpbt_applyLinkerFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    "$<$<CONFIG:Shipping>:/LTCG>"
    "$<$<CONFIG:Shipping>:/OPT:REF>"
    "$<$<CONFIG:Shipping>:/OPT:ICF>"
  )
endfunction()
