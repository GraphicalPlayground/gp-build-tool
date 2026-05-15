# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# List of available string case formats for validation
set(GPBT_AVAILABLE_STRING_CASES "UPPERCASE;lowercase;PascalCase;camelCase;snake_case;SNAKE_CASE;kebab-case;KEBAB-CASE")

# @brief Converts a string to the specified case format.
# @param caseType The desired case format (e.g., "UPPERCASE", "lowercase", "PascalCase", "camelCase", "snake_case", "SNAKE_CASE", "kebab-case", "KEBAB-CASE").
# @param inputString The string to be converted.
# @param outputString The variable name where the converted string will be stored (passed by reference).
function(gpbt_convertCase caseType inputString outputString)
  # Check if the provided case type is valid
  if(NOT caseType IN_LIST GPBT_AVAILABLE_STRING_CASES)
    message(FATAL_ERROR "Invalid case type: ${caseType}. Available cases are: ${GPBT_AVAILABLE_STRING_CASES}")
  endif()

  # If the input string is empty, return an empty string
  if(inputString STREQUAL "")
    set(${outputString} "" PARENT_SCOPE)
    return()
  endif()

  # Tokenize the input string based on case transitions and delimiters
  string(REGEX REPLACE "([a-z0-9])([A-Z])" "\\1;\\2" words "${inputString}")
  string(REGEX REPLACE "([A-Z]+)([A-Z][a-z])" "\\1;\\2" words "${words}")
  string(REGEX REPLACE "[-_]+" ";" words "${words}")
  string(REGEX REPLACE "[ \t\r\n]+" ";" words "${words}")
  string(TOLOWER "${words}" words)
  list(REMOVE_ITEM words "")

  # Convert the tokenized words to the desired case format
  set(result "")
  if(caseType STREQUAL "UPPERCASE")
    string(REPLACE ";" "" result "${words}")
    string(TOUPPER "${result}" result)
  elseif(caseType STREQUAL "lowercase")
    string(REPLACE ";" "" result "${words}")
    string(TOLOWER "${result}" result)
  elseif(caseType STREQUAL "PascalCase")
    foreach(word IN LISTS words)
      string(SUBSTRING "${word}" 0 1 firstChar)
      string(TOUPPER "${firstChar}" firstChar)
      string(SUBSTRING "${word}" 1 -1 rest)
      string(APPEND result "${firstChar}${rest}")
    endforeach()
  elseif(caseType STREQUAL "camelCase")
    list(LENGTH words len)
    if(len GREATER 0)
      list(GET words 0 firstWord)
      set(result "${firstWord}")
      list(REMOVE_AT words 0)
      foreach(word IN LISTS words)
        string(SUBSTRING "${word}" 0 1 firstChar)
        string(TOUPPER "${firstChar}" firstChar)
        string(SUBSTRING "${word}" 1 -1 rest)
        string(APPEND result "${firstChar}${rest}")
      endforeach()
    endif()
  elseif(caseType STREQUAL "snake_case")
    string(REPLACE ";" "_" result "${words}")
    string(TOLOWER "${result}" result)
  elseif(caseType STREQUAL "SNAKE_CASE")
    string(REPLACE ";" "_" result "${words}")
    string(TOUPPER "${result}" result)
  elseif(caseType STREQUAL "kebab-case")
    string(REPLACE ";" "-" result "${words}")
    string(TOLOWER "${result}" result)
  elseif(caseType STREQUAL "KEBAB-CASE")
    string(REPLACE ";" "-" result "${words}")
    string(TOUPPER "${result}" result)
  endif()

  # Export the result to the parent scope
  set(${outputString} "${result}" PARENT_SCOPE)
endfunction()

# @brief Checks if a string is in the specified case format.
# @param caseType The case format to check against (e.g., "UPPERCASE", "lowercase", "PascalCase", "camelCase", "snake_case", "SNAKE_CASE", "kebab-case", "KEBAB-CASE").
# @param inputString The string to be checked.
# @param outputBoolean The variable name where the result (TRUE or FALSE) will be stored (passed by reference).
function(gpbt_checkCase caseType inputString outputBoolean)
  # Check if the provided case type is valid
  if(NOT caseType IN_LIST GPBT_AVAILABLE_STRING_CASES)
    message(FATAL_ERROR "Invalid case type: ${caseType}. Available cases are: ${GPBT_AVAILABLE_STRING_CASES}")
  endif()

  # If the input string is empty, consider it as valid for any case type
  if(inputString STREQUAL "")
    set(${outputBoolean} TRUE PARENT_SCOPE)
    return()
  endif()

# Define regex patterns for each case type
  set(CASE_REGEX_EXPR "")
  if(caseType STREQUAL "UPPERCASE")
    set(CASE_REGEX_EXPR "^[A-Z0-9]+$")
  elseif(caseType STREQUAL "lowercase")
    set(CASE_REGEX_EXPR "^[a-z0-9]+$")
  elseif(caseType STREQUAL "PascalCase")
    set(CASE_REGEX_EXPR "^([A-Z][a-z0-9]+)+$")
  elseif(caseType STREQUAL "camelCase")
    set(CASE_REGEX_EXPR "^[a-z0-9]+([A-Z][a-z0-9]+)*$")
  elseif(caseType STREQUAL "snake_case")
    set(CASE_REGEX_EXPR "^[a-z0-9]+(_[a-z0-9]+)*$")
  elseif(caseType STREQUAL "SNAKE_CASE")
    set(CASE_REGEX_EXPR "^[A-Z0-9]+(_[A-Z0-9]+)*$")
  elseif(caseType STREQUAL "kebab-case")
    set(CASE_REGEX_EXPR "^[a-z0-9]+(-[a-z0-9]+)*$")
  elseif(caseType STREQUAL "KEBAB-CASE")
    set(CASE_REGEX_EXPR "^[A-Z0-9]+(-[A-Z0-9]+)*$")
  endif()

  # Use regex to check if the input string matches the expected case pattern
  string(REGEX MATCH "${CASE_REGEX_EXPR}" MATCH_RESULT "${inputString}")
  if(MATCH_RESULT)
    set(${outputBoolean} TRUE PARENT_SCOPE)
  else()
    set(${outputBoolean} FALSE PARENT_SCOPE)
  endif()
endfunction()
