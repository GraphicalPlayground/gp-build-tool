# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Add preprocessor definition(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
#   PUBLIC   - definition is set on this target AND propagated to consumers.
#   PRIVATE  - definition is set only on this target's compilation units.
#   INTERNAL - definition is set on this target; cross-module propagation is
#              handled by the INTERNAL include directory mechanism when implemented.
# @param[in] ... The definition(s) to add. Accepted forms: "FOO", "FOO=1", "FOO=bar".
#              Generator expressions are supported: "$<$<CONFIG:Debug>:MY_DEBUG_FLAG=1>".
function(gpbt_addCompileDefinition visibility)
  gpbt_checkInTargetDefinition("gpbt_addCompileDefinition")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  set(_allowedVis "PUBLIC;PRIVATE;INTERNAL")
  if(NOT visibility IN_LIST _allowedVis)
    gpbt_log(FATAL "gpbt_addCompileDefinition: invalid visibility '${visibility}'. Allowed values: ${_allowedVis}")
  endif()

  foreach(def IN LISTS ARGN)
    if("${visibility}" STREQUAL "PUBLIC")
      gpbt_appendScopedProperty(_targetPublicCompileDefinitions "${def}")
    elseif("${visibility}" STREQUAL "INTERNAL")
      gpbt_appendScopedProperty(_targetInternalCompileDefinitions "${def}")
    else()
      gpbt_appendScopedProperty(_targetPrivateCompileDefinitions "${def}")
    endif()
    gpbt_log(VERBOSE "Added ${visibility} compile definition: ${def}")
  endforeach()
endfunction()
