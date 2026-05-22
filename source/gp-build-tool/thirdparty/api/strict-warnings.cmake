# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Mark the current thirdparty package so that treat-warnings-as-errors is
#        disabled for every compiled target the subproject creates.
# @remarks Use this for any external package whose own sources do not compile cleanly
#          when the project has /WX or -Werror in CMAKE_CXX_FLAGS.
#
#          Mechanism: after FetchContent_MakeAvailable the resolver walks all compiled
#          targets under the subproject's source directory (recursively through
#          subdirectories) and appends:
#            /WX-      on MSVC / Clang-CL  (disables treat-warnings-as-errors)
#            -Wno-error on GCC / Clang     (same effect)
#          These flags appear after the project-wide /WX or -Werror in the build command
#          and therefore take precedence for the subproject targets only.  No global
#          state is modified.
function(gpbt_thirdpartyDisableStrictWarnings)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyDisableStrictWarnings")
  gpbt_setScopedProperty(_packageStripStrictWarnings TRUE)
  gpbt_log(VERBOSE "Thirdparty package: strict warnings will be stripped for source build")
endfunction()
