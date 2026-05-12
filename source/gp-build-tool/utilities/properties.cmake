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
# @param[in] propertyValue The value to append.
function(gpbt_appendProperty propertyName propertyValue)
  get_property(_set GLOBAL PROPERTY ${propertyName} SET)
  if(_set)
    get_property(_current GLOBAL PROPERTY ${propertyName})
  else()
    set(_current "")
  endif()
  if(NOT "${_current}" STREQUAL "")
    set_property(GLOBAL PROPERTY ${propertyName} "${_current};${propertyValue}")
  else()
    set_property(GLOBAL PROPERTY ${propertyName} "${propertyValue}")
  endif()
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
