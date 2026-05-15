# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/targets/utilities/target-props)

# @brief Add linker option(s) to the current target.
# @param[in] visibility PUBLIC | PRIVATE | INTERNAL
#   PUBLIC   - flag is passed to this target's link step AND to consumers that link against it.
#   PRIVATE  - flag is passed only to this target's link step.
#   INTERNAL - flag is passed to this target's link step; cross-module propagation will
#              be handled by the INTERNAL dependency mechanism when implemented.
# @param[in] ... The linker option(s) to add (e.g., "-Wl,--version-script=foo.map", "/SUBSYSTEM:CONSOLE").
function(gpbt_addLinkOption visibility)
  gpbt_checkInTargetDefinition("gpbt_addLinkOption")
  gpbt_runOnlyDuringPhase("REGISTRATION")

  set(_allowedVis "PUBLIC;PRIVATE;INTERNAL")
  if(NOT visibility IN_LIST _allowedVis)
    gpbt_log(FATAL "gpbt_addLinkOption: invalid visibility '${visibility}'. Allowed values: ${_allowedVis}")
  endif()

  foreach(opt IN LISTS ARGN)
    if("${visibility}" STREQUAL "PUBLIC")
      gpbt_appendScopedProperty(_targetPublicLinkOptions "${opt}")
    elseif("${visibility}" STREQUAL "INTERNAL")
      gpbt_appendScopedProperty(_targetInternalLinkOptions "${opt}")
    else()
      gpbt_appendScopedProperty(_targetPrivateLinkOptions "${opt}")
    endif()
    gpbt_log(VERBOSE "Added ${visibility} link option: ${opt}")
  endforeach()
endfunction()
