# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Declare that this package should be resolved from the host system.
# @remarks System resolution is attempted first (before BINARY and SOURCE). Mutually exclusive modes:
#
#   FIND_PACKAGE <name>             Use CMake's built-in find_package() machinery.
#     COMPONENTS <comp...>          (Optional) Components to pass to find_package().
#     TARGET <target>               (Optional) The imported target name produced by find_package().
#                                   Defaults to "<name>::<name>" if omitted.
#
#   FRAMEWORK <name> [<name2>...]   Link Apple system frameworks (-framework <name>).
#                                   Always succeeds on matching platforms (Metal, Foundation, etc.).
#
#   WINDOWS_SDK                     Resolve libraries from the Windows SDK (d3d12, dxgi, etc.).
#     LIBS <lib1> [<lib2>...]       Library names without extension (e.g. d3d12 dxgi d3dcompiler).
#                                   Headers are part of the Windows SDK system include path.
#
# @remarks
#   Only one system declaration is allowed per package.
#   System packages discovered via this mechanism are always preferred over BINARY/SOURCE.
#   If FIND_PACKAGE fails and no binary/source fallback is declared, configuration is fatal.
function(gpbt_thirdpartySystem)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartySystem")

  cmake_parse_arguments(_SYS
    "WINDOWS_SDK"          # options (flags)
    "FIND_PACKAGE;TARGET"  # one-value keywords
    "COMPONENTS;FRAMEWORK;LIBS" # multi-value keywords
    ${ARGN}
  )

  # Validate: only one mode at a time
  set(_modeCount 0)
  if(_SYS_FIND_PACKAGE)
    math(EXPR _modeCount "${_modeCount} + 1")
  endif()
  if(_SYS_FRAMEWORK)
    math(EXPR _modeCount "${_modeCount} + 1")
  endif()
  if(_SYS_WINDOWS_SDK)
    math(EXPR _modeCount "${_modeCount} + 1")
  endif()
  if(_modeCount GREATER 1)
    gpbt_log(FATAL "gpThirdpartySystem: specify exactly one of FIND_PACKAGE, FRAMEWORK, or WINDOWS_SDK")
  endif()
  if(_modeCount EQUAL 0)
    gpbt_log(FATAL "gpThirdpartySystem: specify one of FIND_PACKAGE, FRAMEWORK, or WINDOWS_SDK")
  endif()

  # Warn on duplicate system declaration
  gpbt_getScopedProperty(_packageSystemMode _existingMode)
  if(_existingMode)
    gpbt_getScopedProperty(_packageName _name)
    gpbt_log(WARNING "gpThirdpartySystem: system declaration already set for '${_name}', overwriting")
  endif()

  if(_SYS_FIND_PACKAGE)
    gpbt_setScopedProperty(_packageSystemMode "FIND_PACKAGE")
    gpbt_setScopedProperty(_packageSystemFindPackageName "${_SYS_FIND_PACKAGE}")
    gpbt_setScopedProperty(_packageSystemFindPackageComponents "${_SYS_COMPONENTS}")
    gpbt_setScopedProperty(_packageSystemFindPackageTarget "${_SYS_TARGET}")
    gpbt_log(VERBOSE "  System: find_package(${_SYS_FIND_PACKAGE})")

  elseif(_SYS_FRAMEWORK)
    gpbt_setScopedProperty(_packageSystemMode "FRAMEWORK")
    gpbt_setScopedProperty(_packageSystemFrameworks "${_SYS_FRAMEWORK}")
    gpbt_log(VERBOSE "  System: framework(${_SYS_FRAMEWORK})")

  elseif(_SYS_WINDOWS_SDK)
    if(NOT _SYS_LIBS)
      gpbt_log(FATAL "gpThirdpartySystem: WINDOWS_SDK requires LIBS <lib1> [<lib2>...]")
    endif()
    gpbt_setScopedProperty(_packageSystemMode "WINDOWS_SDK")
    gpbt_setScopedProperty(_packageSystemWindowsSdkLibs "${_SYS_LIBS}")
    gpbt_log(VERBOSE "  System: Windows SDK libs=[${_SYS_LIBS}]")
  endif()
endfunction()
