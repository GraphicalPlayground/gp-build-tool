# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/linkers/default)

# @brief GNU ld linker flag specialization of gpbt_applyLinkerFlags.
#
# Applies to: GCC + ld.bfd / gold on Linux.
#
# Flag contract
#   --gc-sections          – prune unreferenced code/data sections (all configs)
#   -O3                    – link-time optimization level (Shipping)
#   --as-needed            – only pull in libraries with unresolved references (Shipping)
#   <LTO flag>             – mirrors the -flto=auto compile flag set by gcc.cmake (Shipping)
function(gpbt_applyLinkerFlags)
  gpbt_checkInTargetDefinition("gpbt_applyLinkerFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetLTOFlag ltoFlag)

  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    # All configurations: prune dead code sections (pairs with -ffunction/data-sections)
    "-Wl,--gc-sections"

    # Shipping: link-time optimization and symbol pruning
    "$<$<CONFIG:Shipping>:-Wl,-O3>"
    "$<$<CONFIG:Shipping>:-Wl,--as-needed>"
    # Pass the LTO flag at link time to activate the LTO plugin (set by compiler file).
    "$<$<AND:$<CONFIG:Shipping>,$<BOOL:${ltoFlag}>>:${ltoFlag}>"
  )

  # Sanitizer runtimes: pass -fsanitize=... at link time so gcc resolves the correct
  # runtime library (-lasan, -ltsan, -lubsan). MSan is not supported with GCC/GNU ld.
  if(GPBT_SANITIZER_ADDRESS)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<NOT:$<CONFIG:Shipping>>:-fsanitize=address>"
    )
  endif()
  if(GPBT_SANITIZER_THREAD)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<NOT:$<CONFIG:Shipping>>:-fsanitize=thread>"
    )
  endif()
  if(GPBT_SANITIZER_UNDEFINED_BEHAVIOR)
    gpbt_appendScopedProperty(_targetPrivateLinkOptions
      "$<$<NOT:$<CONFIG:Shipping>>:-fsanitize=undefined>"
    )
  endif()
endfunction()
