# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/linkers/default)

# @brief LLVM lld linker flag specialization of gpbt_applyLinkerFlags.
#
# Applies to: Clang + lld on Linux/Android (selected via -fuse-ld=lld in clang.cmake).
# lld is required for ThinLTO (-flto=thin) and -fwhole-program-vtables.
#
# Flag contract (ELF targets, Linux, Android)
#   --gc-sections          – prune unreferenced code/data sections (Shipping)
#   -O3                    – link-time optimization level (Shipping)
#   --as-needed            – only pull in libraries with unresolved references (Shipping)
#   <LTO flag>             – mirrors the -flto=thin compile flag set by clang.cmake (Shipping)
#
# Note: -fuse-ld=lld itself is set in clang.cmake (it is a compiler-driver flag, not a linker flag).
function(gpbt_applyLinkerFlags)
  gpbt_checkInTargetDefinition("gpbt_applyLinkerFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetLTOFlag ltoFlag)

  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    # ELF Shipping flags: dead-strip + LTO
    "$<$<AND:$<NOT:$<PLATFORM_ID:Darwin>>,$<CONFIG:Shipping>>:-Wl,--gc-sections>"
    "$<$<AND:$<NOT:$<PLATFORM_ID:Darwin>>,$<CONFIG:Shipping>>:-Wl,-O3>"
    "$<$<AND:$<NOT:$<PLATFORM_ID:Darwin>>,$<CONFIG:Shipping>>:-Wl,--as-needed>"
    "$<$<AND:$<NOT:$<PLATFORM_ID:Darwin>>,$<CONFIG:Shipping>,$<BOOL:${ltoFlag}>>:${ltoFlag}>"
  )
endfunction()
