# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Mark the current thirdparty package so that error-promotion flags are stripped
#        from CMAKE_CXX_FLAGS / CMAKE_C_FLAGS before its source build runs.
# @remarks Use this for any external package whose own source code does not cleanly
#          compile under -Werror / /WX. The flags are stripped only for the duration of
#          the FetchContent_MakeAvailable call and are automatically restored afterwards
#          (CMake function-scope shadowing of the cache variable).
#
#          Flags stripped when this is set:
#            /WX           - MSVC / Clang-CL treat-warnings-as-errors
#            -WX           - Clang-CL alternate form
#            -Werror       - GCC / Clang treat-warnings-as-errors
#            -Werror=<x>   - Clang specific-warning-as-error
function(gpbt_thirdpartyDisableStrictWarnings)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyDisableStrictWarnings")
  gpbt_setScopedProperty(_packageStripStrictWarnings TRUE)
  gpbt_log(VERBOSE "Thirdparty package: strict warnings will be stripped for source build")
endfunction()
