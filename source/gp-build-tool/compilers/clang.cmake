# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com
# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/compilers/default)

# @brief Clang specialization of gpbt_applyBuildTypeFlags.
#
# Covers both clang (Linux/macOS/Android) and clang-cl (MSVC driver on Windows).
# clang-cl differences are gated on GP_COMPILER_CLANG_CL defined by the GPBT
# toolchain detection layer.
#
# Minimum supported Clang: 17 (full C++23, <expected>, deducing-this)
#
# Flag contract
#   -Wall -Wextra -Werror + curated set  – diagnostics
#   -fvisibility=hidden                  – default hidden ELF/Mach-O visibility
#   -ffunction-sections -fdata-sections  – per-symbol sections
#   -flto=thin                           – Shipping: ThinLTO (parallel, ~same quality as full)
#   -fwhole-program-vtables              – Shipping: devirtualize across TU boundaries
#
# Linker pairing
#   All configs  : -fuse-ld=lld (required for ThinLTO and -fwhole-program-vtables)
#   Shipping     : -Wl,--gc-sections -Wl,-O3 -Wl,--as-needed (ELF)
#                  -Wl,-dead_strip (Mach-O / Apple)
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
    "$<$<BOOL:${enableStrictWarnings}>:-Wnon-virtual-dtor>"
    "$<$<BOOL:${enableStrictWarnings}>:-Woverloaded-virtual>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wold-style-cast>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wabstract-vbase-init>"    # Clang: warn on virtual base init in abstract class

    # Type-safety & implicit conversions
    "$<$<BOOL:${enableStrictWarnings}>:-Wconversion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wsign-conversion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wdouble-promotion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wcast-align>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wshorten-64-to-32>"       # Clang: explicit 64→32 truncation

    # UB / correctness
    "$<$<BOOL:${enableStrictWarnings}>:-Wnull-dereference>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wshadow>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunused>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wimplicit-fallthrough>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wformat=2>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunreachable-code>"       # Clang: dead code after return/throw
    "$<$<BOOL:${enableStrictWarnings}>:-Wunreachable-code-loop-increment>" # Clang: dead loop increment
    "$<$<BOOL:${enableStrictWarnings}>:-Wloop-analysis>"          # Clang: suspicious loop patterns
    "$<$<BOOL:${enableStrictWarnings}>:-Wmove>"                   # Clang: redundant / self std::move
    "$<$<BOOL:${enableStrictWarnings}>:-Wrange-loop-analysis>"    # Clang: range-for copies/binds
    "$<$<BOOL:${enableStrictWarnings}>:-Wreturn-std-move>"        # Clang: NRVO blocked; should std::move

    # C++23 best-practice
    "$<$<BOOL:${enableStrictWarnings}>:-Wno-c++98-compat>"        # Suppress compat noise; we target C++23
    "$<$<BOOL:${enableStrictWarnings}>:-Wno-c++98-compat-pedantic>"

    # Readability / tooling
    "-fcolor-diagnostics"     # Force ANSI color even when stdout is piped to Ninja/cmake

    # Code Generation
    "-fstrict-aliasing"
    "-fvisibility=hidden"
    "-fvisibility-inlines-hidden"
    "-ffunction-sections"
    "-fdata-sections"
    "-fno-common"
    "-pipe"

    # Debug
    "$<$<CONFIG:Debug>:-O0>"
    "$<$<CONFIG:Debug>:-g3>"                          # Full DWARF + macro info
    "$<$<CONFIG:Debug>:-fno-omit-frame-pointer>"
    "$<$<CONFIG:Debug>:-fno-inline>"
    "$<$<CONFIG:Debug>:-fno-optimize-sibling-calls>"
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"
    # Clang's own run-time instrumentation
    # ASan + UBSan: catches most memory bugs and UB at ~2× overhead.
    # Gated on a separate GPBT property (GP_ENABLE_SANITIZERS) rather than
    # always-on Debug so developers can opt in without rebuilding everything.
    # Uncomment or wire via gpbt_getScopedProperty if desired:
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fsanitize=address,undefined>"
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fsanitize-recover=undefined>"
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fno-sanitize-recover=address>"
    "$<$<CONFIG:Debug>:-D_LIBCPP_DEBUG=1>"            # libc++ bounds checking (Clang's stdlib)
    "$<$<CONFIG:Debug>:-DDEBUG>"
    "$<$<CONFIG:Debug>:-D_DEBUG>"

    # Development
    "$<$<CONFIG:Development>:-O2>"
    "$<$<CONFIG:Development>:-g>"
    "$<$<CONFIG:Development>:-fno-omit-frame-pointer>"
    "$<$<CONFIG:Development>:-fstack-protector>"
    "$<$<CONFIG:Development>:-DNDEBUG>"

    # Profile
    "$<$<CONFIG:Profile>:-O3>"
    "$<$<CONFIG:Profile>:-g>"
    "$<$<CONFIG:Profile>:-fno-omit-frame-pointer>"    # Mandatory for perf/Instruments/Tracy/Optick
    "$<$<CONFIG:Profile>:-fno-inline-functions>"      # Accurate hot-path attribution
    # Clang's own profiling instrumentation, generates .profraw for PGO feedback:
    # "$<$<AND:$<CONFIG:Profile>,$<BOOL:${enablePGOInstrument}>>:-fprofile-instr-generate>"
    "$<$<CONFIG:Profile>:-DNDEBUG>"
    "$<$<CONFIG:Profile>:-DGPBT_PROFILE=1>"

    # Shipping
    "$<$<CONFIG:Shipping>:-O3>"
    "$<$<CONFIG:Shipping>:-ffast-math>"
    "$<$<CONFIG:Shipping>:-fomit-frame-pointer>"
    "$<$<CONFIG:Shipping>:-flto=thin>"                      # ThinLTO: parallel, scales to 100k-TU codebases
    "$<$<CONFIG:Shipping>:-fwhole-program-vtables>"         # Cross-TU devirtualization (requires ThinLTO/LTO)
    "$<$<CONFIG:Shipping>:-fvirtual-function-elimination>"  # Remove vtable slots provably never called
    "$<$<CONFIG:Shipping>:-fno-semantic-interposition>"     # Elide PLT for within-DSO direct calls (Clang 11+)
    "$<$<CONFIG:Shipping>:-fmerge-all-constants>"
    "$<$<CONFIG:Shipping>:-fno-stack-protector>"
    "$<$<CONFIG:Shipping>:-fno-unwind-tables>"
    "$<$<CONFIG:Shipping>:-fno-asynchronous-unwind-tables>"
    # PGO use, wire via gpbt_getScopedProperty if a .profdata file is present:
    # "$<$<AND:$<CONFIG:Shipping>,$<BOOL:${enablePGOUse}>>:-fprofile-instr-use=${GP_PGO_PROFILE_PATH}>"
    "$<$<CONFIG:Shipping>:-DNDEBUG>"
    "$<$<CONFIG:Shipping>:-DGPBT_SHIPPING=1>"
  )
endfunction()
