# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# Supported CMake library types for GPBT-managed thirdparty targets.
set(GPBT_THIRDPARTY_AVAILABLE_LIBRARY_TYPES "STATIC;SHARED;MODULE;OBJECT;INTERFACE")

# @brief Internal helper: partition an argument list by optional PUBLIC / PRIVATE / INTERFACE keywords.
# @param[in]  defaultVisibility Visibility bucket used for arguments before any visibility keyword.
# @param[out] outPublic         Output variable receiving PUBLIC arguments.
# @param[out] outPrivate        Output variable receiving PRIVATE arguments.
# @param[out] outInterface      Output variable receiving INTERFACE arguments.
# @param[in]  ...               Arguments to partition.
function(gpbt_parseThirdpartyVisibilityArgs defaultVisibility outPublic outPrivate outInterface)
  set(_currentVis "${defaultVisibility}")
  set(_pub "")
  set(_priv "")
  set(_iface "")

  foreach(_arg IN LISTS ARGN)
    if(_arg STREQUAL "PUBLIC" OR _arg STREQUAL "PRIVATE" OR _arg STREQUAL "INTERFACE")
      set(_currentVis "${_arg}")
    else()
      if(_currentVis STREQUAL "PUBLIC")
        list(APPEND _pub "${_arg}")
      elseif(_currentVis STREQUAL "PRIVATE")
        list(APPEND _priv "${_arg}")
      elseif(_currentVis STREQUAL "INTERFACE")
        list(APPEND _iface "${_arg}")
      endif()
    endif()
  endforeach()

  set(${outPublic}    "${_pub}"   PARENT_SCOPE)
  set(${outPrivate}   "${_priv}"  PARENT_SCOPE)
  set(${outInterface} "${_iface}" PARENT_SCOPE)
endfunction()

# @brief Internal helper: append unique items to a scoped property list.
function(gpbt_appendUniqueScopedList propertyKey)
  gpbt_getScopedProperty("${propertyKey}" _existing)
  foreach(_item IN LISTS ARGN)
    if(NOT _item IN_LIST _existing)
      list(APPEND _existing "${_item}")
      gpbt_appendScopedProperty("${propertyKey}" "${_item}")
    endif()
  endforeach()
endfunction()

# @brief Declare include directories exposed through the GPBT-managed thirdparty target.
# @param[in] ... Directory paths (relative to the thirdparty source directory, absolute, or generator expressions).
#                Optional PUBLIC / PRIVATE / INTERFACE keywords may precede entries (default: PUBLIC).
# @remarks Repeated calls accumulate entries; duplicate entries are ignored.
# @example
#   gpThirdpartySetIncludeDirectories(
#     "."
#     "include"
#   )
function(gpbt_thirdpartySetIncludeDirectories)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetIncludeDirectories")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetIncludeDirectories: at least one include directory is required")
  endif()

  gpbt_parseThirdpartyVisibilityArgs("PUBLIC" _pub _priv _iface ${ARGN})
  if(NOT _pub AND NOT _priv AND NOT _iface)
    gpbt_log(FATAL "gpThirdpartySetIncludeDirectories: at least one include directory is required")
  endif()

  if(_pub)
    gpbt_appendUniqueScopedList(_packageIncludeDirsPublic ${_pub})
  endif()
  if(_priv)
    gpbt_appendUniqueScopedList(_packageIncludeDirsPrivate ${_priv})
  endif()
  if(_iface)
    gpbt_appendUniqueScopedList(_packageIncludeDirsInterface ${_iface})
  endif()

  gpbt_log(VERBOSE "  Include directories: ${ARGN}")
endfunction()

# @brief Control how GPBT compiles manually declared thirdparty source files.
# @param[in] libraryType STATIC | SHARED | MODULE | OBJECT | INTERFACE
# @remarks
#   - STATIC    : Compiled into a static archive (.lib / .a). Default when sources are declared.
#   - SHARED    : Compiled into a shared library (.dll / .so / .dylib). Enables WINDOWS_EXPORT_ALL_SYMBOLS on Windows.
#   - MODULE    : Compiled into a dynamically loadable module (cannot be linked via target_link_libraries).
#   - OBJECT    : Compiled into object files propagated to consumers via target_link_libraries.
#   - INTERFACE : Header-only target; cannot compile source files. Default when no sources are declared.
function(gpbt_thirdpartySetLibraryType libraryType)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetLibraryType")

  if(NOT libraryType IN_LIST GPBT_THIRDPARTY_AVAILABLE_LIBRARY_TYPES)
    gpbt_log(FATAL "gpThirdpartySetLibraryType: invalid library type '${libraryType}'. Valid values: ${GPBT_THIRDPARTY_AVAILABLE_LIBRARY_TYPES}")
  endif()

  gpbt_setScopedProperty(_packageLibraryType "${libraryType}")
  gpbt_log(VERBOSE "  Library type: ${libraryType}")
endfunction()

# @brief Declare compile definitions for the thirdparty target.
# @param[in] ... Preprocessor definitions (e.g. "FOO", "FOO=1", generator expressions).
#                Optional PUBLIC / PRIVATE / INTERFACE keywords may precede entries (default: PUBLIC).
# @remarks Repeated calls accumulate entries; duplicate entries are ignored.
function(gpbt_thirdpartySetCompileDefinitions)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetCompileDefinitions")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetCompileDefinitions: at least one compile definition is required")
  endif()

  gpbt_parseThirdpartyVisibilityArgs("PUBLIC" _pub _priv _iface ${ARGN})
  if(NOT _pub AND NOT _priv AND NOT _iface)
    gpbt_log(FATAL "gpThirdpartySetCompileDefinitions: at least one compile definition is required")
  endif()

  if(_pub)
    gpbt_appendUniqueScopedList(_packageCompileDefsPublic ${_pub})
  endif()
  if(_priv)
    gpbt_appendUniqueScopedList(_packageCompileDefsPrivate ${_priv})
  endif()
  if(_iface)
    gpbt_appendUniqueScopedList(_packageCompileDefsInterface ${_iface})
  endif()

  gpbt_log(VERBOSE "  Compile definitions: ${ARGN}")
endfunction()

# @brief Declare compiler options for the thirdparty target.
# @param[in] ... Compiler flags or generator expressions.
#                Optional PUBLIC / PRIVATE / INTERFACE keywords may precede entries (default: PRIVATE).
# @remarks Defaults to PRIVATE so thirdparty-specific compiler flags do not leak into consumers.
#          Repeated calls accumulate entries.
function(gpbt_thirdpartySetCompileOptions)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetCompileOptions")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetCompileOptions: at least one compile option is required")
  endif()

  gpbt_parseThirdpartyVisibilityArgs("PRIVATE" _pub _priv _iface ${ARGN})
  if(NOT _pub AND NOT _priv AND NOT _iface)
    gpbt_log(FATAL "gpThirdpartySetCompileOptions: at least one compile option is required")
  endif()

  if(_pub)
    foreach(_opt IN LISTS _pub)
      gpbt_appendScopedProperty(_packageCompileOptsPublic "${_opt}")
    endforeach()
  endif()
  if(_priv)
    foreach(_opt IN LISTS _priv)
      gpbt_appendScopedProperty(_packageCompileOptsPrivate "${_opt}")
    endforeach()
  endif()
  if(_iface)
    foreach(_opt IN LISTS _iface)
      gpbt_appendScopedProperty(_packageCompileOptsInterface "${_opt}")
    endforeach()
  endif()

  gpbt_log(VERBOSE "  Compile options: ${ARGN}")
endfunction()

# @brief Declare additional libraries required by the thirdparty target.
# @param[in] ... Library targets or link flags.
#                Optional PUBLIC / PRIVATE / INTERFACE keywords may precede entries (default: PUBLIC).
# @remarks Repeated calls accumulate entries; duplicate entries are ignored within each visibility.
function(gpbt_thirdpartySetLinkLibraries)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetLinkLibraries")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetLinkLibraries: at least one library is required")
  endif()

  gpbt_parseThirdpartyVisibilityArgs("PUBLIC" _pub _priv _iface ${ARGN})
  if(NOT _pub AND NOT _priv AND NOT _iface)
    gpbt_log(FATAL "gpThirdpartySetLinkLibraries: at least one library is required")
  endif()

  if(_pub)
    gpbt_appendUniqueScopedList(_packageLinkLibsPublic ${_pub})
  endif()
  if(_priv)
    gpbt_appendUniqueScopedList(_packageLinkLibsPrivate ${_priv})
  endif()
  if(_iface)
    gpbt_appendUniqueScopedList(_packageLinkLibsInterface ${_iface})
  endif()

  gpbt_log(VERBOSE "  Link libraries: ${ARGN}")
endfunction()

# @brief Declare required CMake compile features for the thirdparty target.
# @param[in] ... CMake compile features (e.g. cxx_std_17, c_std_11).
#                Optional PUBLIC / PRIVATE / INTERFACE keywords may precede entries (default: PUBLIC).
# @remarks Repeated calls accumulate entries; duplicate entries are ignored within each visibility.
function(gpbt_thirdpartySetCompileFeatures)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetCompileFeatures")

  if(NOT ARGN)
    gpbt_log(FATAL "gpThirdpartySetCompileFeatures: at least one compile feature is required")
  endif()

  gpbt_parseThirdpartyVisibilityArgs("PUBLIC" _pub _priv _iface ${ARGN})
  if(NOT _pub AND NOT _priv AND NOT _iface)
    gpbt_log(FATAL "gpThirdpartySetCompileFeatures: at least one compile feature is required")
  endif()

  if(_pub)
    gpbt_appendUniqueScopedList(_packageCompileFeaturesPublic ${_pub})
  endif()
  if(_priv)
    gpbt_appendUniqueScopedList(_packageCompileFeaturesPrivate ${_priv})
  endif()
  if(_iface)
    gpbt_appendUniqueScopedList(_packageCompileFeaturesInterface ${_iface})
  endif()

  gpbt_log(VERBOSE "  Compile features: ${ARGN}")
endfunction()

# @brief Control the POSITION_INDEPENDENT_CODE property on a GPBT-managed thirdparty target.
# @param[in] enabled ON | OFF (also accepts TRUE/FALSE, YES/NO, 1/0).
function(gpbt_thirdpartySetPositionIndependentCode enabled)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySetPositionIndependentCode")

  string(TOUPPER "${enabled}" _upper)
  if(_upper MATCHES "^(ON|TRUE|YES|1)$")
    set(_normalized "ON")
  elseif(_upper MATCHES "^(OFF|FALSE|NO|0)$")
    set(_normalized "OFF")
  else()
    gpbt_log(FATAL "gpThirdpartySetPositionIndependentCode: invalid value '${enabled}'. Expected ON or OFF")
  endif()

  gpbt_setScopedProperty(_packagePositionIndependentCode "${_normalized}")
  gpbt_log(VERBOSE "  Position Independent Code: ${_normalized}")
endfunction()
