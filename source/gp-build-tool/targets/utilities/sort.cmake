# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Internal function to perform a topological sort of the registered targets based on their dependencies. This is used to determine the correct build order of the targets.
#        It uses a depth-first search approach to sort the targets. If it detects a circular dependency, it will report an error and stop the configuration process.
# @param[out] outSortedList The output variable where the sorted list of targets will be stored.
function(gpbt_sortTargets outSortedList)
  # Retrieve the master list of all registered targets
  gpbt_getProperty(GPBT_TARGETS registeredTargets)

  # Clean the target names to ensure they are valid CMake variable names.
  set(cleanRegisteredTargets "")
  foreach(target IN LISTS registeredTargets)
    string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanTargetName "${target}")
    string(TOLOWER cleanTargetName "${cleanTargetName}")
    list(APPEND cleanRegisteredTargets "${cleanTargetName}")
  endforeach()

  # unsorted starts with all targets. sorted starts empty.
  set(unsorted ${cleanRegisteredTargets})
  set(sorted "")

  # Loop as long as we have unsorted targets AND we are making progress
  set(progressMade TRUE)
  while(unsorted AND progressMade)
    set(progressMade FALSE)
    set(nextUnsorted "")

    foreach(target IN LISTS unsorted)
      # Fetch the combined dependencies for the current target
      gpbt_pushScope("${target}")
      gpbt_getProperty(_targetPublicDependencies publicDependencies)
      gpbt_getProperty(_targetInternalDependencies internalDependencies)
      gpbt_getProperty(_targetPrivateDependencies privateDependencies)
      gpbt_getProperty(_targetDynamicDependencies dynamicDependencies)
      gpbt_popScope()

      set(allDependencies ${publicDependencies} ${internalDependencies} ${privateDependencies} ${dynamicDependencies})

      # Check if all of this target's dependencies are already in the sorted list
      set(allDependenciesMet TRUE)
      foreach(dependency IN LISTS allDependencies)
        # We ONLY care about resolving dependencies that are registered GP targets.
        # (This prevents the script from freezing if a target depends on an external OS library).
        if(dependency IN_LIST cleanRegisteredTargets)
          if(NOT dependency IN_LIST sorted)
            set(allDependenciesMet FALSE)
            break() # Stop checking, we already know we can't sort this target yet
          endif()
        endif()
      endforeach()

      if(allDependenciesMet)
        # Success! All internal dependencies are met. Add to the sorted list.
        list(APPEND sorted ${target})
        set(progressMade TRUE) # We successfully processed at least one target
      else()
        # Not ready yet. Push it to the next pass.
        list(APPEND nextUnsorted ${target})
      endif()
    endforeach()

    # Update the unsorted list for the next iteration of the while loop
    set(unsorted ${nextUnsorted})
  endwhile()

  # Dependency validation: distinguish unresolved deps from true circular deps.
  # An unresolved dep is one that was never registered at all (typo, missing module).
  # A circular dep means every remaining target has at least one dep still in unsorted.
  if(unsorted)
    foreach(target IN LISTS unsorted)
      gpbt_pushScope("${target}")
      gpbt_getProperty(_targetPublicDependencies publicDependencies)
      gpbt_getProperty(_targetInternalDependencies internalDependencies)
      gpbt_getProperty(_targetPrivateDependencies privateDependencies)
      gpbt_getProperty(_targetDynamicDependencies dynamicDependencies)
      gpbt_popScope()

      set(allDependencies ${publicDependencies} ${internalDependencies} ${privateDependencies} ${dynamicDependencies})

      foreach(dependency IN LISTS allDependencies)
        if(NOT dependency IN_LIST cleanRegisteredTargets AND NOT dependency IN_LIST sorted)
          gpbt_log(WARNING "Target '${target}' depends on '${dependency}' which is not a registered GP target. Check for typos or a missing add_subdirectory().")
        endif()
      endforeach()
    endforeach()
    gpbt_log(FATAL "Circular dependency detected! The following targets form an infinite dependency loop and cannot be ordered: ${unsorted}")
  endif()

  # Return the sorted list to the caller's scope
  set(${outSortedList} "${sorted}" PARENT_SCOPE)
endfunction()
