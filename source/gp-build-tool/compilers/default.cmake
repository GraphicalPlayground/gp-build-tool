# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/utilities/logger)
include(gp-build-tool/targets/utilities/target-props)

# @brief Stub compile-flag function overridden by each compiler specialization.
#        Compiler files (gcc.cmake, clang.cmake, msvc.cmake) override this function
#        with compiler-specific compile flags. They also set _targetLTOFlag if LTO
#        is enabled so the linker file can add the matching link-time flag.
function(gpbt_applyCompileFlags)
  gpbt_checkInTargetDefinition("gpbt_applyCompileFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
  # Default: no-op. Overridden by compiler-specific files.
endfunction()

# @brief Stub linker-flag function overridden by each linker specialization.
#        Linker files (ld.cmake, lld.cmake, ld64.cmake, msvc-link.cmake) override
#        this function with linker-specific flags. They read _targetLTOFlag to
#        append the matching LTO pass-through flag at link time.
function(gpbt_applyLinkerFlags)
  gpbt_checkInTargetDefinition("gpbt_applyLinkerFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
  # Default: no-op. Overridden by linker-specific files.
endfunction()

# @brief Validate that no incompatible sanitizer combination is enabled.
#        ASan/TSan/MSan are mutually exclusive at runtime; mixing them produces
#        undefined behavior or build failures.
function(gpbt_validateSanitizerOptions)
  if(GPBT_SANITIZER_ADDRESS AND GPBT_SANITIZER_THREAD)
    gpbt_log(FATAL "GPBT_SANITIZER_ADDRESS and GPBT_SANITIZER_THREAD are mutually exclusive.")
  endif()
  if(GPBT_SANITIZER_ADDRESS AND GPBT_SANITIZER_MEMORY)
    gpbt_log(FATAL "GPBT_SANITIZER_ADDRESS and GPBT_SANITIZER_MEMORY are mutually exclusive.")
  endif()
  if(GPBT_SANITIZER_THREAD AND GPBT_SANITIZER_MEMORY)
    gpbt_log(FATAL "GPBT_SANITIZER_THREAD and GPBT_SANITIZER_MEMORY are mutually exclusive.")
  endif()
endfunction()

# @brief Orchestrator called from gpbt_endTarget. Invokes both the compiler and linker
#        flag functions so each target receives consistent compile+link flags.
function(gpbt_applyBuildTypeFlags)
  gpbt_checkInTargetDefinition("gpbt_applyBuildTypeFlags")
  gpbt_runOnlyDuringPhase("CONFIGURATION")
  gpbt_validateSanitizerOptions()
  gpbt_applyCompileFlags()
  gpbt_applyLinkerFlags()
endfunction()
