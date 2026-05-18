# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

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
function(gpbt_applyCompileFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Enforce minimum Clang version: 17 is required for full C++23 support.
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "17.0")
    gpbt_log(FATAL "Clang ${CMAKE_CXX_COMPILER_VERSION} is not supported. Minimum required version is Clang 17.")
  endif()

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
    "$<$<BOOL:${enableStrictWarnings}>:-Wshorten-64-to-32>"       # Clang: explicit 64->32 truncation

    # UB / correctness
    "$<$<BOOL:${enableStrictWarnings}>:-Wnull-dereference>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wshadow>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunused>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wimplicit-fallthrough>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wformat=2>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunreachable-code>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunreachable-code-loop-increment>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wloop-analysis>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wmove>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wrange-loop-analysis>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wreturn-std-move>"

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
    "$<$<CONFIG:Debug>:-g3>"
    "$<$<CONFIG:Debug>:-fno-omit-frame-pointer>"
    "$<$<CONFIG:Debug>:-fno-inline>"
    "$<$<CONFIG:Debug>:-fno-optimize-sibling-calls>"
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"
    # ASan + UBSan: catches most memory bugs and UB at ~2x overhead.
    # Wire via a GPBT_ENABLE_SANITIZERS option when that feature is implemented.
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fsanitize=address,undefined>"
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fsanitize-recover=undefined>"
    # "$<$<AND:$<CONFIG:Debug>,$<BOOL:${enableSanitizers}>>:-fno-sanitize-recover=address>"

    # Development
    "$<$<CONFIG:Development>:-O2>"
    "$<$<CONFIG:Development>:-g>"
    "$<$<CONFIG:Development>:-fno-omit-frame-pointer>"
    "$<$<CONFIG:Development>:-fstack-protector>"

    # Profile
    "$<$<CONFIG:Profile>:-O3>"
    "$<$<CONFIG:Profile>:-g>"
    "$<$<CONFIG:Profile>:-fno-omit-frame-pointer>"
    "$<$<CONFIG:Profile>:-fno-inline-functions>"
    # PGO instrumentation, wire via gpbt_getScopedProperty when a .profdata file is present:
    # "$<$<AND:$<CONFIG:Profile>,$<BOOL:${enablePGOInstrument}>>:-fprofile-instr-generate>"

    # Shipping
    "$<$<CONFIG:Shipping>:-O3>"
    "$<$<CONFIG:Shipping>:-ffast-math>"
    "$<$<CONFIG:Shipping>:-fomit-frame-pointer>"
    "$<$<CONFIG:Shipping>:-flto=thin>"
    "$<$<CONFIG:Shipping>:-fwhole-program-vtables>"
    "$<$<CONFIG:Shipping>:-fvirtual-function-elimination>"
    "$<$<CONFIG:Shipping>:-fno-semantic-interposition>"
    "$<$<CONFIG:Shipping>:-fmerge-all-constants>"
    "$<$<CONFIG:Shipping>:-fno-stack-protector>"
    "$<$<CONFIG:Shipping>:-fno-unwind-tables>"
    "$<$<CONFIG:Shipping>:-fno-asynchronous-unwind-tables>"
    # PGO use, wire via gpbt_getScopedProperty if a .profdata file is present:
    # "$<$<AND:$<CONFIG:Shipping>,$<BOOL:${enablePGOUse}>>:-fprofile-instr-use=${GP_PGO_PROFILE_PATH}>"
  )

  # Preprocessor definitions are routed through compile_definitions (not compile_options) so
  # they are visible to CMake's definition management and IDE generators.
  gpbt_appendScopedProperty(_targetPrivateCompileDefinitions
    # Debug, libc++ bounds checking (Clang's stdlib)
    "$<$<CONFIG:Debug>:DEBUG>"
    "$<$<CONFIG:Debug>:_DEBUG>"
    "$<$<CONFIG:Debug>:_LIBCPP_DEBUG=1>"

    # Development / Profile / Shipping, disable assert guards
    "$<$<CONFIG:Development>:NDEBUG>"
    "$<$<CONFIG:Profile>:NDEBUG>"
    "$<$<CONFIG:Profile>:GPBT_PROFILE=1>"
    "$<$<CONFIG:Shipping>:NDEBUG>"
    "$<$<CONFIG:Shipping>:GPBT_SHIPPING=1>"
  )

  # Linker selection: force lld on non-Darwin targets (required for ThinLTO and
  # -fwhole-program-vtables). This is a compiler-driver flag so it lives here,
  # not in the linker file.
  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    "$<$<NOT:$<PLATFORM_ID:Darwin>>:-fuse-ld=lld>"
  )

  # Store the ThinLTO flag so the active linker file can append it to link options.
  # lld.cmake and ld64.cmake read _targetLTOFlag to complete the LTO setup.
  gpbt_setScopedProperty(_targetLTOFlag "$<$<CONFIG:Shipping>:-flto=thin>")
endfunction()
