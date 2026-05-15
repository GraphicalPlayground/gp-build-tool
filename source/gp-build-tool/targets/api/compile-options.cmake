# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

set(GPBT_COMPILE_AVAILABLE_VISIBILITIES "PUBLIC;PRIVATE;INTERNAL")

# @brief Add compile option(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
#   PUBLIC   - flag is passed to this target's compilation AND propagated to consumers.
#   PRIVATE  - flag is passed only to this target's compilation.
#   INTERNAL - flag is passed to this target's compilation; cross-module propagation
#              will be handled by the INTERNAL dependency mechanism when implemented.
# @param[in] ... The compile option(s) to add (e.g., "-march=native", "/favor:INTEL64").
function(gpbt_addCompileOption visibility)
  gpbt_checkInTargetDefinition("gpbt_addCompileOption")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  if(NOT visibility IN_LIST GPBT_COMPILE_AVAILABLE_VISIBILITIES)
    gpbt_log(FATAL "gpbt_addCompileOption: invalid visibility '${visibility}'. Allowed values: ${GPBT_COMPILE_AVAILABLE_VISIBILITIES}")
  endif()

  foreach(opt IN LISTS ARGN)
    if("${visibility}" STREQUAL "PUBLIC")
      gpbt_appendScopedProperty(_targetPublicCompileOptions "${opt}")
    elseif("${visibility}" STREQUAL "INTERNAL")
      gpbt_appendScopedProperty(_targetInternalCompileOptions "${opt}")
    else()
      gpbt_appendScopedProperty(_targetPrivateCompileOptions "${opt}")
    endif()
    gpbt_log(VERBOSE "Added ${visibility} compile option: ${opt}")
  endforeach()
endfunction()
