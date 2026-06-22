# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/linkers/default)

# @brief Apple ld64 linker flag specialization of gpbt_applyLinkerFlags.
#
# Applies to: Clang on macOS/iOS using Apple's ld64 (the default on Darwin).
# Apple's ld64 does not support --gc-sections; -dead_strip is the equivalent.
#
# Flag contract (Mach-O targets, macOS, iOS)
#   -dead_strip            – remove unreferenced code/data (Shipping; Mach-O equivalent of --gc-sections)
#   <LTO flag>             – mirrors -flto=thin set by clang.cmake (Shipping)
function(gpbt_applyLinkerFlags)
  gpbt_checkInTargetDefinition("gpbt_applyLinkerFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetLTOFlag ltoFlag)

  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    # Mach-O dead-strip (Apple's --gc-sections equivalent)
    "$<$<AND:$<PLATFORM_ID:Darwin>,$<CONFIG:Shipping>>:-Wl,-dead_strip>"
    "$<$<AND:$<PLATFORM_ID:Darwin>,$<CONFIG:Shipping>,$<BOOL:${ltoFlag}>>:${ltoFlag}>"
  )

  # Sanitizer runtimes: pass -fsanitize=... at link time so ld64/clang resolves the correct
  # runtime dylib. MSan is not supported on Darwin (Apple libc is not instrumented).
  if(GPBT_SANITIZER_ADDRESS)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<AND:$<PLATFORM_ID:Darwin>,$<NOT:$<CONFIG:Shipping>>>:-fsanitize=address>"
    )
  endif()
  if(GPBT_SANITIZER_THREAD)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<AND:$<PLATFORM_ID:Darwin>,$<NOT:$<CONFIG:Shipping>>>:-fsanitize=thread>"
    )
  endif()
  if(GPBT_SANITIZER_UNDEFINED_BEHAVIOR)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<AND:$<PLATFORM_ID:Darwin>,$<NOT:$<CONFIG:Shipping>>>:-fsanitize=undefined>"
    )
  endif()
endfunction()
