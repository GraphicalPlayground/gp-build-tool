# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/compilers/default)

# @brief MSVC specialization of gpbt_applyBuildTypeFlags.
#
# Minimum supported MSVC: 19.38 (VS 2022 17.8, full C++23 including <expected>)
#
# Flag contract
#   /W4 /WX /permissive-   – strict diagnostics (gated on enableStrictWarnings)
#   /MP /EHsc /GS /Gy /GF  – universal code-gen baseline
#   /Zc:*                  – conformance fixes required for C++23
#   /MDd /MD               – dynamic CRT (swap to /MTd /MT for static linking)
#   /GL + /Gw              – Shipping: WPO (requires /LTCG in the linker step)
#
# Linker pairing
#   Debug/Development/Profile : nothing extra required
#   Shipping                  : /LTCG /OPT:REF /OPT:ICF
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  # Enforce minimum MSVC version: 19.38 is required for full C++23 support.
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19.38")
    gpbt_log(FATAL "MSVC ${CMAKE_CXX_COMPILER_VERSION} is not supported. Minimum required version is MSVC 19.38 (VS 2022 17.8).")
  endif()

  gpbt_getScopedProperty(_targetEnableStrictWarnings enableStrictWarnings)

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Core strict-warning triad
    "$<$<BOOL:${enableStrictWarnings}>:/W4>"
    "$<$<BOOL:${enableStrictWarnings}>:/WX>"
    "$<$<BOOL:${enableStrictWarnings}>:/permissive->"

    # Suppress warnings originating in third-party headers pulled via <>
    # Requires MSVC 16.10 (VS 2019 16.10+)
    "/external:anglebrackets"
    "/external:W0"

    # High-value opt-in warnings absent from /W4
    # Narrowing / sign conversions
    "$<$<BOOL:${enableStrictWarnings}>:/w14242>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14254>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14826>"
    # Virtual / OOP correctness
    "$<$<BOOL:${enableStrictWarnings}>:/w14263>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14265>"
    # Concurrency / static-init hazards
    "$<$<BOOL:${enableStrictWarnings}>:/w14640>"
    # Expression correctness
    "$<$<BOOL:${enableStrictWarnings}>:/w14287>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14296>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14545>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14546>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14547>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14549>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14555>"
    # Pointer / cast traps
    "$<$<BOOL:${enableStrictWarnings}>:/w14311>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14905>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14906>"
    "$<$<BOOL:${enableStrictWarnings}>:/w14928>"
    # Pragma hygiene
    "$<$<BOOL:${enableStrictWarnings}>:/w14619>"

    # Code Generation (universal baseline)
    "/MP"           # Parallel .obj compilation (use all logical cores)
    "/EHsc"         # C++ exceptions + extern "C" assumed non-throwing
    "/GS"           # Buffer-security check (stack canary)
    "/Gy"           # Function-level linking (COMDAT); enables /OPT:REF at link
    "/GF"           # String pooling: merge identical literals into .rdata
    "/fp:except-"   # Suppress floating-point exceptions globally

    # C++23 conformance fixes
    "/Zc:__cplusplus"     # Report correct __cplusplus value (else stuck at 199711L)
    "/Zc:preprocessor"    # Enable conformant C99/C++20 preprocessor (__VA_OPT__ etc.)
    "/Zc:inline"          # Strip unreferenced COMDAT symbols before LTO
    "/Zc:templateHead"    # Fix template-head parsing for C++20/23 concepts
    "/Zc:lambda"          # Fix lambda capture scoping per C++23 spec
    "/Zc:externConstexpr" # extern constexpr has external linkage (ISO C++17+)
    "/Zc:throwingNew"     # operator new throws on failure (don't swallow OOM silently)

    # Debug, zero optimization, maximum diagnostic fidelity, runtime safety nets
    "$<$<CONFIG:Debug>:/Od>"
    "$<$<CONFIG:Debug>:/Ob0>"
    "$<$<CONFIG:Debug>:/Oi->"
    "$<$<CONFIG:Debug>:/Zi>"
    "$<$<CONFIG:Debug>:/RTC1>"
    "$<$<CONFIG:Debug>:/sdl>"
    "$<$<CONFIG:Debug>:/MDd>"

    # Development, ship-class speed with debuggable PDB output
    "$<$<CONFIG:Development>:/O2>"
    "$<$<CONFIG:Development>:/Ob2>"
    "$<$<CONFIG:Development>:/Oi>"
    "$<$<CONFIG:Development>:/Ot>"
    "$<$<CONFIG:Development>:/Zi>"
    "$<$<CONFIG:Development>:/MD>"

    # Profile, shipping-equivalent performance; instrumentation-friendly call stacks
    "$<$<CONFIG:Profile>:/O2>"
    "$<$<CONFIG:Profile>:/Ob2>"
    "$<$<CONFIG:Profile>:/Oi>"
    "$<$<CONFIG:Profile>:/Ot>"
    "$<$<CONFIG:Profile>:/Oy->"   # Retain frame pointers for PIX, VTune, Optick, Tracy
    "$<$<CONFIG:Profile>:/Zi>"
    "$<$<CONFIG:Profile>:/MD>"

    # Shipping, maximum throughput, minimal binary size, link-time optimization
    "$<$<CONFIG:Shipping>:/O2>"
    "$<$<CONFIG:Shipping>:/Ob3>"  # Aggressive inlining beyond /O2 (MSVC 2019 16.4+)
    "$<$<CONFIG:Shipping>:/Oi>"
    "$<$<CONFIG:Shipping>:/Ot>"
    "$<$<CONFIG:Shipping>:/GL>"   # Whole-Program Optimization (WPO), requires /LTCG at link
    "$<$<CONFIG:Shipping>:/Gw>"   # Package globals as individual COMDATs (enables /OPT:REF on data)
    "$<$<CONFIG:Shipping>:/GS->"  # Disable stack canary (10-15ns saved per call on hot paths)
    "$<$<CONFIG:Shipping>:/fp:fast>"
    "$<$<CONFIG:Shipping>:/MD>"
  )

  # Preprocessor definitions are routed through compile_definitions (not compile_options) so
  # they are visible to CMake's definition management and IDE generators.
  gpbt_appendScopedProperty(_targetPrivateCompileDefinitions
    "$<$<CONFIG:Debug>:DEBUG>"
    "$<$<CONFIG:Debug>:_DEBUG>"

    "$<$<CONFIG:Development>:NDEBUG>"
    "$<$<CONFIG:Profile>:NDEBUG>"
    "$<$<CONFIG:Profile>:GPBT_PROFILE=1>"
    "$<$<CONFIG:Shipping>:NDEBUG>"
    "$<$<CONFIG:Shipping>:GPBT_SHIPPING=1>"
  )

  # Linker: Shipping requires /LTCG to pair with /GL at compile time.
  gpbt_appendScopedProperty(_targetPrivateLinkOptions
    "$<$<CONFIG:Shipping>:/LTCG>"
    "$<$<CONFIG:Shipping>:/OPT:REF>"
    "$<$<CONFIG:Shipping>:/OPT:ICF>"
  )
endfunction()
