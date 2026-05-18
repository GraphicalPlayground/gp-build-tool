# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/compilers/default)

# @brief Clang-CL specialization of gpbt_applyBuildTypeFlags.
#
# clang-cl is the MSVC-compatible driver for Clang on Windows.
# It supports both MSVC-style flags (/W4, /O2, /Zi) and Clang-style flags (-Wextra, -fcolor-diagnostics).
#
# Minimum supported Clang: 17 (full C++23, <expected>, deducing-this)
#
# Flag contract
#   /W4 /WX /permissive- + -Wextra       – diagnostics
#   /EHsc /GS /Gy /GF                    – universal code-gen baseline
#   /Zc:*                                – conformance fixes required for C++23
#   /GL + /Gw                            – Shipping: WPO (requires /LTCG in the linker step)
#
# Linker pairing
#   All configs  : lld-link (via msvc-link.cmake)
#   Shipping     : /LTCG /OPT:REF /OPT:ICF
function(gpbt_applyCompileFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Enforce minimum Clang version: 17 is required for full C++23 support.
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "17.0")
    gpbt_log(FATAL "Clang-CL ${CMAKE_CXX_COMPILER_VERSION} is not supported. Minimum required version is Clang 17.")
  endif()

  gpbt_getScopedProperty(_targetEnableStrictWarnings enableStrictWarnings)

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Core MSVC-compatible strict-warning triad
    "$<$<BOOL:${enableStrictWarnings}>:/W4>"
    "$<$<BOOL:${enableStrictWarnings}>:/WX>"
    "$<$<BOOL:${enableStrictWarnings}>:/permissive->"

    # Suppress warnings originating in third-party headers pulled via <>
    "/external:anglebrackets"
    "/external:W0"

    # Clang-specific enhancements (clang-cl supports many -W flags directly)
    "$<$<BOOL:${enableStrictWarnings}>:-Wextra>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wpedantic>"
    
    # OOP / virtual-dispatch correctness
    "$<$<BOOL:${enableStrictWarnings}>:-Wnon-virtual-dtor>"
    "$<$<BOOL:${enableStrictWarnings}>:-Woverloaded-virtual>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wold-style-cast>"

    # Type-safety & implicit conversions
    "$<$<BOOL:${enableStrictWarnings}>:-Wconversion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wsign-conversion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wdouble-promotion>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wcast-align>"

    # UB / correctness
    "$<$<BOOL:${enableStrictWarnings}>:-Wnull-dereference>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wshadow>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wunused>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wimplicit-fallthrough>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wformat=2>"

    # Suppress noise
    "-Wno-unknown-argument"              # Avoid fatal errors on unknown flags from other tools
    "-Wno-unused-command-line-argument"  # Avoid noise from flags clang-cl doesn't consume
    "$<$<BOOL:${enableStrictWarnings}>:-Wno-c++98-compat>"
    "$<$<BOOL:${enableStrictWarnings}>:-Wno-c++98-compat-pedantic>"

    # Readability / tooling
    "-fcolor-diagnostics"     # Force ANSI color even when stdout is piped to Ninja/cmake

    # Code Generation (universal baseline)
    "/EHsc"                   # C++ exceptions
    "/GS"                     # Buffer-security check
    "/Gy"                     # Function-level linking
    "/GF"                     # String pooling
    
    # C++23 conformance fixes
    "/Zc:__cplusplus"
    "/Zc:preprocessor"
    "/Zc:inline"
    "/Zc:lambda"
    "/Zc:externConstexpr"
    "/Zc:throwingNew"

    # Debug, zero optimization, maximum diagnostic fidelity, runtime safety nets
    "$<$<CONFIG:Debug>:/Od>"
    "$<$<CONFIG:Debug>:/Zi>"
    "$<$<CONFIG:Debug>:/MDd>"
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"

    # Development, ship-class speed with debuggable PDB output
    "$<$<CONFIG:Development>:/O2>"
    "$<$<CONFIG:Development>:/Zi>"
    "$<$<CONFIG:Development>:/MD>"

    # Profile, shipping-equivalent performance; instrumentation-friendly call stacks
    "$<$<CONFIG:Profile>:/O2>"
    "$<$<CONFIG:Profile>:/Zi>"
    "$<$<CONFIG:Profile>:/MD>"
    "/Oy-"                    # Retain frame pointers for PIX, VTune, Optick, Tracy

    # Shipping, maximum throughput, minimal binary size, link-time optimization
    "$<$<CONFIG:Shipping>:/O2>"
    "$<$<CONFIG:Shipping>:/GL>"   # Whole-Program Optimization (WPO), requires /LTCG at link
    "$<$<CONFIG:Shipping>:/Gw>"   # Package globals as individual COMDATs
    "$<$<CONFIG:Shipping>:/MD>"
    "$<$<CONFIG:Shipping>:-flto=thin>" # Clang-CL maps /GL to ThinLTO when using lld-link
  )

  # Preprocessor definitions are routed through compile_definitions (not compile_options) so
  # they are visible to CMake's definition management and IDE generators.
  gpbt_appendScopedProperty(_targetPrivateCompileDefinitions
    "$<$<CONFIG:Debug>:DEBUG>"
    "$<$<CONFIG:Debug>:_DEBUG>"

    # Development / Profile / Shipping, disable assert guards
    "$<$<CONFIG:Development>:NDEBUG>"
    "$<$<CONFIG:Profile>:NDEBUG>"
    "$<$<CONFIG:Profile>:GPBT_PROFILE=1>"
    "$<$<CONFIG:Shipping>:NDEBUG>"
    "$<$<CONFIG:Shipping>:GPBT_SHIPPING=1>"
  )

  # MSVC WPO coupling: /GL (set above in compile options) requires /LTCG at link time.
  # msvc-link.cmake handles the /LTCG /OPT:REF /OPT:ICF flags.
  gpbt_setScopedProperty(_targetLTOFlag "")
endfunction()
