# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/compilers/default)

# @brief GCC specialization of gpbt_applyBuildTypeFlags.
#
# Minimum supported GCC: 13 (full C++23, <stacktrace>, std::expected)
#
# Flag contract
#   -Wall -Wextra -Werror + curated set  – diagnostics
#   -fvisibility=hidden                  – default hidden ELF visibility
#   -ffunction-sections -fdata-sections  – per-symbol sections (pairs with --gc-sections)
#   -flto=auto                           – Shipping: parallel full LTO
#   -fno-semantic-interposition          – Shipping: elide PLT trampolines within a DSO
#
# Linker pairing
#   Debug/Development/Profile : -Wl,--gc-sections (prune dead code)
#   Shipping                  : -Wl,--gc-sections -Wl,-O3 -Wl,--as-needed + LTO plugin
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetEnableStrictWarnings enableStrictWarnings)

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Standard triad
    "$<$<BOOL:${enableStrictWarnings}>:-Wall>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wextra>"
    "$<$<BOOL:${enableStrictWarnings}>:-Werror>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wpedantic>"

    # OOP / virtual-dispatch correctness
    "$<$<BOOL:${enableStrictWarnings}>:-Wnon-virtual-dtor>"      # Missing virtual dtor
    "$<$<BOOL:${enableStrictWarnings}>:-Woverloaded-virtual>"    # Hides base virtual
    "$<$<BOOL:${enableStrictWarnings}>:-Wold-style-cast>"        # C-style cast in C++ code

    # Type-safety & implicit conversions
    "$<$<BOOL:${enableStrictWarnings}>:-Wconversion>"            # Implicit narrowing
    "$<$<BOOL:${enableStrictWarnings}>:-Wsign-conversion>"       # Signed↔unsigned implicit
    "$<$<BOOL:${enableStrictWarnings}>:-Wdouble-promotion>"      # float→double implicit
    "$<$<BOOL:${enableStrictWarnings}>:-Wcast-align>"            # Alignment-unsafe cast

    # Undefined / unspecified behaviour triggers
    "$<$<BOOL:${enableStrictWarnings}>:-Wnull-dereference>"      # Provable null deref
    "$<$<BOOL:${enableStrictWarnings}>:-Wshadow>"                # Variable shadowing
    "$<$<BOOL:${enableStrictWarnings}>:-Wunused>"                # Any unused entity
    "$<$<BOOL:${enableStrictWarnings}>:-Wimplicit-fallthrough>"  # Missing [[fallthrough]]
    "$<$<BOOL:${enableStrictWarnings}>:-Wformat=2>"              # printf/scanf format security

    # GCC-exclusive high-value warnings
    "$<$<BOOL:${enableStrictWarnings}>:-Wlogical-op>"             # Suspicious logical ops on integral
    "$<$<BOOL:${enableStrictWarnings}>:-Wduplicated-cond>"        # Duplicate if/else-if conditions (GCC 6+)
    "$<$<BOOL:${enableStrictWarnings}>:-Wduplicated-branches>"    # Identical if/else bodies (GCC 7+)
    "$<$<BOOL:${enableStrictWarnings}>:-Wrestrict>"               # restrict-aliasing violations (GCC 7+)
    "$<$<BOOL:${enableStrictWarnings}>:-Wmisleading-indentation>" # Dangling-else style issues (GCC 6+)
    "$<$<BOOL:${enableStrictWarnings}>:-Wuseless-cast>"           # Cast to the same type

    # Code Generation
    "-fstrict-aliasing"           # Enable strict aliasing analysis (explicit even though O2+ implies it)
    "-fvisibility=hidden"         # ELF default: all symbols hidden; exports need GP_API attribute
    "-fvisibility-inlines-hidden" # Inline function definitions also hidden
    "-ffunction-sections"         # One ELF section per function (dead-strip with --gc-sections)
    "-fdata-sections"             # One ELF section per data object
    "-fno-common"                 # Prohibit tentative (COMMON) definitions; catches missing externs
    "-pipe"                       # Use pipes between cc1/as stages; faster on machines with fast RAM

    # Debug
    "$<$<CONFIG:Debug>:-O0>"
    "$<$<CONFIG:Debug>:-g3>"                          # Max DWARF info including macro tables
    "$<$<CONFIG:Debug>:-fno-omit-frame-pointer>"      # Reliable stack unwinding
    "$<$<CONFIG:Debug>:-fno-inline>"                  # No inlining: every call appears in the stack
    "$<$<CONFIG:Debug>:-fno-optimize-sibling-calls>"  # Disable tail-call opt (preserve call frames)
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"     # Canaries on all functions with buffers/VLAs
    "$<$<CONFIG:Debug>:-D_GLIBCXX_DEBUG>"             # libstdc++ bounds & iterator validity checks
    "$<$<CONFIG:Debug>:-D_GLIBCXX_DEBUG_PEDANTIC>"    # Strict libstdc++ pedantic mode
    "$<$<CONFIG:Debug>:-DDEBUG>"
    "$<$<CONFIG:Debug>:-D_DEBUG>"

    # Development
    "$<$<CONFIG:Development>:-O2>"
    "$<$<CONFIG:Development>:-g>"                       # DWARF for crash dump symbolication
    "$<$<CONFIG:Development>:-fno-omit-frame-pointer>"  # Keep frame pointers for devtools
    "$<$<CONFIG:Development>:-fstack-protector>"        # Lighter canary vs -strong
    "$<$<CONFIG:Development>:-DNDEBUG>"

    # Profile
    "$<$<CONFIG:Profile>:-O3>"
    "$<$<CONFIG:Profile>:-g>"                                 # Symbols for perf/callgrind/Tracy
    "$<$<CONFIG:Profile>:-fno-omit-frame-pointer>"            # Mandatory for perf record / gprof / Valgrind
    "$<$<CONFIG:Profile>:-fno-inline-functions-called-once>"  # Prevent single-caller collapse: more accurate hot-path attribution
    "$<$<CONFIG:Profile>:-DNDEBUG>"
    "$<$<CONFIG:Profile>:-DGPBT_PROFILE=1>"

    # Shipping
    "$<$<CONFIG:Shipping>:-O3>"
    "$<$<CONFIG:Shipping>:-ffast-math>"                     # Relax IEEE-754: reassoc, no NaN/Inf, fused ops
    "$<$<CONFIG:Shipping>:-fomit-frame-pointer>"            # Reclaim RBP/X29 as a GPR on x64/ARM64
    "$<$<CONFIG:Shipping>:-flto=auto>"                      # Full LTO, threads = nproc
    "$<$<CONFIG:Shipping>:-fno-semantic-interposition>"     # Elide PLT indirection for within-DSO calls (GCC 8+)
    "$<$<CONFIG:Shipping>:-fmerge-all-constants>"           # Merge identical constants across TUs
    "$<$<CONFIG:Shipping>:-fno-stack-protector>"            # Remove canaries from hot paths
    "$<$<CONFIG:Shipping>:-fno-unwind-tables>"              # Strip .eh_frame/.ARM.exidx if exceptions disabled
    "$<$<CONFIG:Shipping>:-fno-asynchronous-unwind-tables>" # Strip async-unwind metadata
    "$<$<CONFIG:Shipping>:-DNDEBUG>"
    "$<$<CONFIG:Shipping>:-DGPBT_SHIPPING=1>"
  )

  # Add Linker Options
  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    # All configurations
    "-Wl,--gc-sections"            # Prune dead code (pairs with -ffunction-sections / -fdata-sections)

    # Shipping
    "$<$<CONFIG:Shipping>:-Wl,-O3>"           # Link-time optimization level
    "$<$<CONFIG:Shipping>:-Wl,--as-needed>"   # Only link libraries that actually satisfy unresolved references
    "$<$<CONFIG:Shipping>:-flto=auto>"        # GCC requires the LTO flag at link-time as well
  )
endfunction()
