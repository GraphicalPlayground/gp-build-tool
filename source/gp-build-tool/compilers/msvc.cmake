# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/compilers/default)

# @brief Appends build type flags to the current target based on the compiler, platform and build type.
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")

  gpbt_getScopedProperty(_targetEnableStrictWarnings enableStrictWarnings)

  gpbt_appendScopedProperty(_targetPrivateCompileOptions
    # Core strict-warning triad
    "$<$<BOOL:${enableStrictWarnings}>:/W4>"
    "$<$<BOOL:${enableStrictWarnings}>:/WX>"          # Warnings as errors
    "$<$<BOOL:${enableStrictWarnings}>:/permissive->" # ISO C++ conformance

    # Suppress warnings originating in third-party headers pulled via <>
    # Requires MSVC 16.10 (VS 2019 16.10+)
    "/external:anglebrackets"
    "/external:W0"

    # High-value opt-in warnings absent from /W4
    # Narrowing / sign conversions
    "$<$<BOOL:${enableStrictWarnings}>:/w14242>" # 'id': conversion, possible loss of data
    "$<$<BOOL:${enableStrictWarnings}>:/w14254>" # bitfield conversion, possible loss of data
    "$<$<BOOL:${enableStrictWarnings}>:/w14826>" # conversion is sign-extended
    # Virtual / OOP correctness
    "$<$<BOOL:${enableStrictWarnings}>:/w14263>" # member function does not override base virtual
    "$<$<BOOL:${enableStrictWarnings}>:/w14265>" # class has virtuals but non-virtual destructor
    # Concurrency / static-init hazards
    "$<$<BOOL:${enableStrictWarnings}>:/w14640>" # thread-unsafe static member init
    # Expression correctness
    "$<$<BOOL:${enableStrictWarnings}>:/w14287>" # unsigned/negative constant mismatch
    "$<$<BOOL:${enableStrictWarnings}>:/w14296>" # expression always evaluates to bool constant
    "$<$<BOOL:${enableStrictWarnings}>:/w14545>" # expression before comma missing argument list
    "$<$<BOOL:${enableStrictWarnings}>:/w14546>" # function call before comma missing argument list
    "$<$<BOOL:${enableStrictWarnings}>:/w14547>" # operator before comma has no effect
    "$<$<BOOL:${enableStrictWarnings}>:/w14549>" # operator before comma has no effect
    "$<$<BOOL:${enableStrictWarnings}>:/w14555>" # expression has no side-effect
    # Pointer / cast traps
    "$<$<BOOL:${enableStrictWarnings}>:/w14311>" # pointer truncation between types
    "$<$<BOOL:${enableStrictWarnings}>:/w14905>" # wide string literal cast to LPSTR
    "$<$<BOOL:${enableStrictWarnings}>:/w14906>" # string literal cast to LPWSTR
    "$<$<BOOL:${enableStrictWarnings}>:/w14928>" # illegal copy-init: multiple implicit conversions
    # Pragma hygiene
    "$<$<BOOL:${enableStrictWarnings}>:/w14619>" # pragma warning: unknown warning number

    # Code Generation
    "/MP"           # Parallel .obj compilation (use all logical cores)
    "/EHsc"         # C++ exceptions + extern "C" assumed non-throwing
    "/GS"           # Buffer-security check (stack canary); negligible overhead
    "/Gy"           # Function-level linking (COMDAT); enables /OPT:REF at link
    "/GF"           # String pooling: merge identical literals into .rdata
    "/fp:except-"   # Suppress floating-point exceptions globally (re-enabled per-config if needed)

    # C++23 conformance fixes
    "/Zc:__cplusplus"     # Report correct __cplusplus value (else stuck at 199711L)
    "/Zc:preprocessor"    # Enable conformant C99/C++20 preprocessor (__VA_OPT__ etc.)
    "/Zc:inline"          # Strip unreferenced COMDAT symbols before LTO
    "/Zc:templateHead"    # Fix template-head parsing for C++20/23 concepts
    "/Zc:lambda"          # Fix lambda capture scoping per C++23 spec
    "/Zc:externConstexpr" # extern constexpr has external linkage (ISO C++17+)
    "/Zc:throwingNew"     # operator new throws on failure (don't swallow OOM silently)

    # Debug
    # Goal: zero optimization, maximum diagnostic fidelity, runtime safety nets
    "$<$<CONFIG:Debug>:/Od>"    # Disable all optimizations
    "$<$<CONFIG:Debug>:/Ob0>"   # Disable inlining (clean call stacks)
    "$<$<CONFIG:Debug>:/Oi->"   # Disable intrinsics (force library calls; easier to step)
    "$<$<CONFIG:Debug>:/Zi>"    # Full PDB with edit-and-continue support
    "$<$<CONFIG:Debug>:/RTC1>"  # Stack-frame integrity + uninitialized variable checks
    "$<$<CONFIG:Debug>:/sdl>"   # Additional SDL: stricter type checks, zero-init locals
    "$<$<CONFIG:Debug>:/MDd>"   # Dynamic debug CRT (links to ucrtbased.dll)
    "$<$<CONFIG:Debug>:/GS>"    # Redundant but explicit: buffer security check on
    "$<$<CONFIG:Debug>:/DDEBUG>"
    "$<$<CONFIG:Debug>:/D_DEBUG>"

    # Development
    # Goal: ship-class speed with debuggable PDB output; mirrors what devs run day-to-day
    "$<$<CONFIG:Development>:/O2>"    # Maximize speed (/Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy)
    "$<$<CONFIG:Development>:/Ob2>"   # Inline any suitable function (explicit; /O2 implies it)
    "$<$<CONFIG:Development>:/Oi>"    # Replace calls with intrinsic equivalents
    "$<$<CONFIG:Development>:/Ot>"    # Favor fast code over small code
    "$<$<CONFIG:Development>:/Zi>"    # Full PDB (needed for crash dump symbolication)
    "$<$<CONFIG:Development>:/MD>"    # Dynamic release CRT
    "$<$<CONFIG:Development>:/DNDEBUG>"

    # Profile
    # Goal: shipping-equivalent performance; instrumentation-friendly call stacks
    "$<$<CONFIG:Profile>:/O2>"
    "$<$<CONFIG:Profile>:/Ob2>"
    "$<$<CONFIG:Profile>:/Oi>"
    "$<$<CONFIG:Profile>:/Ot>"
    "$<$<CONFIG:Profile>:/Oy->"   # RETAIN frame pointers — mandatory for PIX, VTune, Optick, Tracy
    "$<$<CONFIG:Profile>:/Zi>"    # PDB for symbol resolution in profilers
    "$<$<CONFIG:Profile>:/MD>"
    "$<$<CONFIG:Profile>:/DNDEBUG>"
    "$<$<CONFIG:Profile>:/DGPBT_PROFILE=1>"

    # Shipping
    # Goal: maximum throughput, minimal binary size, link-time optimization
    "$<$<CONFIG:Shipping>:/O2>"
    "$<$<CONFIG:Shipping>:/Ob3>"      # Aggressive inlining beyond /O2 (MSVC 2019 16.4+)
    "$<$<CONFIG:Shipping>:/Oi>"       # Intrinsic substitution
    "$<$<CONFIG:Shipping>:/Ot>"       # Favor speed
    "$<$<CONFIG:Shipping>:/GL>"       # Whole-Program Optimization (WPO) — requires /LTCG at link
    "$<$<CONFIG:Shipping>:/Gw>"       # Package globals as individual COMDATs (enables /OPT:REF on data)
    "$<$<CONFIG:Shipping>:/GS->"      # Disable stack canary (10-15ns saved per call on hot paths)
    "$<$<CONFIG:Shipping>:/fp:fast>"  # Relax IEEE-754: reassociate, contract, omit NaN/Inf checks
    "$<$<CONFIG:Shipping>:/MD>"
    "$<$<CONFIG:Shipping>:/DNDEBUG>"
    "$<$<CONFIG:Shipping>:/DGPBT_SHIPPING=1>"
  )
endfunction()
