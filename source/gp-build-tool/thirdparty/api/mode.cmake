# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# Available resolution modes
set(GPBT_THIRDPARTY_AVAILABLE_MODES "AUTO;SOURCE;BINARY")

# @brief Override the thirdparty resolution mode.
# @param[in] mode  AUTO | SOURCE | BINARY
# @remarks
#   When called INSIDE a gpStartThirdparty / gpEndThirdparty block, the override applies only to
#   that single package (package-local override).
#
#   When called OUTSIDE any block (e.g. at project top-level), it overrides the global default
#   for ALL packages in this build, equivalent to setting -DGPBT_THIRDPARTY_MODE=<mode> on the
#   CMake command line.
#
#   Resolution priority: AUTO = SYSTEM (if declared) → BINARY → SOURCE
#                        BINARY = BINARY only (FATAL if no prebuilt matches)
#                        SOURCE = SOURCE only (SYSTEM and BINARY are skipped)
function(gpbt_setThirdpartyMode mode)
  if(NOT mode IN_LIST GPBT_THIRDPARTY_AVAILABLE_MODES)
    gpbt_log(FATAL "gpSetThirdpartyMode: invalid mode '${mode}'. Valid values: ${GPBT_THIRDPARTY_AVAILABLE_MODES}")
  endif()

  gpbt_getProperty(GPBT_IS_IN_THIRDPARTY_DEFINITION _inThirdparty)
  if(_inThirdparty)
    gpbt_setScopedProperty(_packageMode "${mode}")
    gpbt_log(VERBOSE "  Mode override: ${mode} (package-local)")
  else()
    set(GPBT_THIRDPARTY_MODE "${mode}" CACHE STRING "Thirdparty resolution mode" FORCE)
    gpbt_log(VERBOSE "Thirdparty global mode set to: ${mode}")
  endif()
endfunction()
