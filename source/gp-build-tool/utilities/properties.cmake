# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# @brief Get a global property value.
# @param[in] propertyName The name of the property to retrieve.
# @param[out] outputVariable The variable to store the retrieved property value.
function(gpbt_getProperty propertyName outputVariable)
  get_property(propertyValue GLOBAL PROPERTY ${propertyName})
  set(${outputVariable} "${propertyValue}" PARENT_SCOPE)
endfunction()

# @brief Set a global property value.
# @param[in] propertyName The name of the property to set.
# @param[in] propertyValue The value to set for the property.
function(gpbt_setProperty propertyName propertyValue)
  set_property(GLOBAL PROPERTY ${propertyName} "${propertyValue}")
endfunction()

# @brief Append a value to a global property.
# @param[in] propertyName The name of the property to append to.
# @param[in] propertyValue The value to append.
function(gpbt_appendProperty propertyName propertyValue)
  get_property(currentValue GLOBAL PROPERTY ${propertyName})
  if(currentValue STREQUAL "")
    set(newValue "${propertyValue}")
  else()
    set(newValue "${currentValue};${propertyValue}")
  endif()
  set_property(GLOBAL PROPERTY ${propertyName} "${newValue}")
endfunction()

# @brief Increment a global property value (assumes the property value is an integer).
# @param[in] propertyName The name of the property to increment.
function(gpbt_incrementProperty propertyName)
  get_property(currentValue GLOBAL PROPERTY ${propertyName})
  if(currentValue STREQUAL "")
    set(newValue 1)
  else()
    math(EXPR newValue "${currentValue} + 1")
  endif()
  set_property(GLOBAL PROPERTY ${propertyName} "${newValue}")
endfunction()

# @brief Decrement a global property value (assumes the property value is an integer).
# @param[in] propertyName The name of the property to decrement.
function(gpbt_decrementProperty propertyName)
  get_property(currentValue GLOBAL PROPERTY ${propertyName})
  if(currentValue STREQUAL "")
    set(newValue -1)
  else()
    math(EXPR newValue "${currentValue} - 1")
  endif()
  set_property(GLOBAL PROPERTY ${propertyName} "${newValue}")
endfunction()
