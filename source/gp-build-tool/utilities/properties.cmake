# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# @brief Get a global property value.
# @param[in] propertyName The name of the property to retrieve.
# @param[out] outputVariable The variable to store the retrieved property value.
function(gpbt_getProperty propertyName outputVariable)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)
  if(_set)
    get_property(_val GLOBAL PROPERTY ${propertyName})
    set(${outputVariable} "${_val}" PARENT_SCOPE)
  else()
    set(${outputVariable} "" PARENT_SCOPE)
  endif()
endfunction()

# @brief Set a global property value.
# @param[in] propertyName The name of the property to set.
# @param[in] propertyValue The value to set for the property.
function(gpbt_setProperty propertyName propertyValue)
  set_property(GLOBAL PROPERTY ${propertyName} "${propertyValue}")
endfunction()

# @brief Append a value to a global property treated as a list.
# @param[in] propertyName The name of the property to append to.
# @param[in] ... The values to append.
function(gpbt_appendProperty propertyName)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)

  if(_set)
    get_property(_current GLOBAL PROPERTY ${propertyName})
  else()
    set(_current "")
  endif()

  # Create a local copy of the current property list
  set(_new_list "${_current}")

  # Safely append ALL remaining arguments passed to this function (${ARGN})
  # list(APPEND) automatically handles semicolons and empty states correctly
  list(APPEND _new_list ${ARGN})

  # Save the new list back to the global property
  set_property(GLOBAL PROPERTY ${propertyName} "${_new_list}")
endfunction()

# @brief Pop the last value from a global property treated as a list.
# @param[in] propertyName The name of the property to pop from.
# @param[out] outValue The variable to store the popped value.
function(gpbt_popProperty propertyName outValue)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)
  if(NOT _set)
    set(${outValue} "" PARENT_SCOPE)
    return()
  endif()
  get_property(_current GLOBAL PROPERTY ${propertyName})
  if("${_current}" STREQUAL "")
    set(${outValue} "" PARENT_SCOPE)
    return()
  endif()
  list(GET _current -1 _last)
  list(POP_BACK _current)
  set_property(GLOBAL PROPERTY ${propertyName} "${_current}")
  set(${outValue} "${_last}" PARENT_SCOPE)
endfunction()

# @brief Increment a global property value (assumes integer).
# @param[in] propertyName The name of the property to increment.
function(gpbt_incrementProperty propertyName)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)
  if(_set)
    get_property(_current GLOBAL PROPERTY ${propertyName})
    math(EXPR _new "${_current} + 1")
  else()
    set(_new 1)
  endif()
  set_property(GLOBAL PROPERTY ${propertyName} "${_new}")
endfunction()

# @brief Decrement a global property value (assumes integer).
# @param[in] propertyName The name of the property to decrement.
function(gpbt_decrementProperty propertyName)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)
  if(_set)
    get_property(_current GLOBAL PROPERTY ${propertyName})
    math(EXPR _new "${_current} - 1")
  else()
    set(_new -1)
  endif()
  set_property(GLOBAL PROPERTY ${propertyName} "${_new}")
endfunction()

# @brief Push a scope name onto the scope stack.
# @param[in] scopeName The name of the scope to enter.
function(gpbt_pushScope scopeName)
  gpbt_appendProperty("__GPBT_SCOPE_STACK__" "${scopeName}")
endfunction()

# @brief Pop the current scope from the scope stack.
function(gpbt_popScope)
  gpbt_popProperty("__GPBT_SCOPE_STACK__" _gpbt_unused)
endfunction()

# @brief Get the current (top) scope name.
# @param[out] outVal The variable to store the current scope name, empty if no active scope.
function(gpbt_currentScope outVal)
  gpbt_getProperty("__GPBT_SCOPE_STACK__" _stack)
  if(NOT "${_stack}" STREQUAL "")
    list(GET _stack -1 _top)
    set(${outVal} "${_top}" PARENT_SCOPE)
  else()
    set(${outVal} "" PARENT_SCOPE)
  endif()
endfunction()

# @brief Check whether a scope name appears anywhere in the current scope stack.
# @param[in] scopeName The scope name to search for.
# @param[out] outVal Set to TRUE if found, FALSE otherwise.
function(gpbt_isInScope scopeName outVal)
  gpbt_getProperty("__GPBT_SCOPE_STACK__" _stack)
  list(FIND _stack "${scopeName}" _idx)
  if(_idx GREATER_EQUAL 0)
    set(${outVal} TRUE PARENT_SCOPE)
  else()
    set(${outVal} FALSE PARENT_SCOPE)
  endif()
endfunction()

# @brief Set a property namespaced to the current scope.
# @param[in] key The property key.
# @param[in] value The value to set.
function(gpbt_setScopedProperty key value)
  gpbt_currentScope(_scope)
  gpbt_setProperty("__GPBT_SCOPED_${_scope}__${key}" "${value}")
endfunction()

# @brief Set multiple properties in the current scope from alternating key-value pairs.
# @param[in] ARGN Alternating key value pairs.
function(gpbt_setBulkScopedProperties)
  list(LENGTH ARGN _len)
  math(EXPR _pairs "${_len} / 2")
  set(_i 0)
  while(_i LESS _pairs)
    math(EXPR _ki "${_i} * 2")
    math(EXPR _vi "${_ki} + 1")
    list(GET ARGN ${_ki} _key)
    list(GET ARGN ${_vi} _val)
    gpbt_setScopedProperty("${_key}" "${_val}")
    math(EXPR _i "${_i} + 1")
  endwhile()
endfunction()

# @brief Get a property namespaced to the current scope.
# @param[in] key The property key.
# @param[out] outVar The variable to store the retrieved value.
function(gpbt_getScopedProperty key outVar)
  gpbt_currentScope(_scope)
  gpbt_getProperty("__GPBT_SCOPED_${_scope}__${key}" _val)
  set(${outVar} "${_val}" PARENT_SCOPE)
endfunction()

# @brief Append a value to a scoped property treated as a list.
# @param[in] key The property key.
# @param[in] ... The values to append.
function(gpbt_appendScopedProperty key)
  gpbt_currentScope(_scope)
  gpbt_appendProperty("__GPBT_SCOPED_${_scope}__${key}" ${ARGN})
endfunction()

# @brief Pop the last value from a scoped property treated as a list.
# @param[in] key The property key.
# @param[out] outVar The variable to store the popped value.
function(gpbt_popScopedProperty key outVar)
  gpbt_currentScope(_scope)
  gpbt_popProperty("__GPBT_SCOPED_${_scope}__${key}" _val)
  set(${outVar} "${_val}" PARENT_SCOPE)
endfunction()
