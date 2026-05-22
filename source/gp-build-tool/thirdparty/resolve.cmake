# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(FetchContent)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# Suppress the FetchContent_Populate single-arg deprecation warning (CMake 3.30+).
# We intentionally call FetchContent_Populate for binary-only archives where
# add_subdirectory must NOT be invoked.
if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()

# Internal helper: create a CMake INTERFACE target from a GP binary layout.
# Layout convention:
#   <dir>/include/        - public headers
#   <dir>/lib/            - config-agnostic libs (.lib/.a/.so/.dylib)
#   <dir>/lib/debug/      - Debug-only libs
#   <dir>/lib/release/    - Non-debug libs (Development, Profile, Shipping)
#   <dir>/bin/            - Runtime DLLs/SOs (Windows: .dll, Linux: .so)
function(gpbt_createTargetFromBinaryLayout cleanName extractedDir)
  set(_lib_patterns "*.lib" "*.a" "*.so" "*.dylib")

  # Collect libs from each tier
  set(_debugLibs "")
  set(_releaseLibs "")
  set(_genericLibs "")

  foreach(_pat IN LISTS _lib_patterns)
    file(GLOB _found "${extractedDir}/lib/debug/${_pat}")
    list(APPEND _debugLibs ${_found})

    file(GLOB _found "${extractedDir}/lib/release/${_pat}")
    list(APPEND _releaseLibs ${_found})

    file(GLOB _found "${extractedDir}/lib/${_pat}")
    list(APPEND _genericLibs ${_found})
  endforeach()

  # Resolve include directory
  set(_includeDir "${extractedDir}/include")

  add_library(gp_thirdparty_${cleanName} INTERFACE)

  if(IS_DIRECTORY "${_includeDir}")
    target_include_directories(gp_thirdparty_${cleanName} INTERFACE "${_includeDir}")
  endif()

  if(_debugLibs OR _releaseLibs)
    # Separate debug / non-debug sets available: use config-specific linking.
    # Debug config uses debug libs; Development / Profile / Shipping use release libs.
    # If one side is empty, fall through to the generic list as a safety net.
    if(_debugLibs)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE
        $<$<CONFIG:Debug>:${_debugLibs}>
      )
    endif()
    if(_releaseLibs)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE
        $<$<NOT:$<CONFIG:Debug>>:${_releaseLibs}>
      )
    elseif(_genericLibs)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE
        $<$<NOT:$<CONFIG:Debug>>:${_genericLibs}>
      )
    endif()
  elseif(_genericLibs)
    target_link_libraries(gp_thirdparty_${cleanName} INTERFACE ${_genericLibs})
  endif()

  add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
endfunction()

# Internal: resolve a package via its SYSTEM declaration.
# Sets outResolved to TRUE in PARENT_SCOPE if a target was created.
function(gpbt_resolveSystemPackage cleanName packageName outResolved)
  gpbt_pushScope("thirdparty_${cleanName}")
  gpbt_getScopedProperty(_packageSystemMode      _sysMode)
  gpbt_getScopedProperty(_packageSystemFindPackageName _findName)
  gpbt_getScopedProperty(_packageSystemFindPackageComponents _findComponents)
  gpbt_getScopedProperty(_packageSystemFindPackageTarget _findTarget)
  gpbt_getScopedProperty(_packageSystemFrameworks _frameworks)
  gpbt_getScopedProperty(_packageSystemWindowsSdkLibs _wsdkLibs)
  gpbt_popScope()

  if(_sysMode STREQUAL "FIND_PACKAGE")
    find_package(${_findName} ${_findComponents} QUIET)
    if(${_findName}_FOUND)
      if(NOT _findTarget)
        set(_findTarget "${_findName}::${_findName}")
      endif()
      add_library(gp_thirdparty_${cleanName} INTERFACE)
      if(TARGET "${_findTarget}")
        target_link_libraries(gp_thirdparty_${cleanName} INTERFACE "${_findTarget}")
      else()
        gpbt_log(WARNING "Thirdparty '${packageName}': find_package(${_findName}) succeeded but target '${_findTarget}' was not created, package may not link correctly")
      endif()
      add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
      gpbt_log(SUCCESS "  [SYSTEM/find_package] ${packageName}, using ${_findTarget}")
      set(${outResolved} TRUE PARENT_SCOPE)
    else()
      gpbt_log(VERBOSE "  [SYSTEM/find_package] ${packageName}, not found, trying fallback")
      set(${outResolved} FALSE PARENT_SCOPE)
    endif()

  elseif(_sysMode STREQUAL "FRAMEWORK")
    add_library(gp_thirdparty_${cleanName} INTERFACE)
    foreach(_fw IN LISTS _frameworks)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE "-framework ${_fw}")
    endforeach()
    add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
    gpbt_log(SUCCESS "  [SYSTEM/framework] ${packageName}, frameworks: ${_frameworks}")
    set(${outResolved} TRUE PARENT_SCOPE)

  elseif(_sysMode STREQUAL "WINDOWS_SDK")
    add_library(gp_thirdparty_${cleanName} INTERFACE)
    foreach(_lib IN LISTS _wsdkLibs)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE "${_lib}.lib")
    endforeach()
    add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
    gpbt_log(SUCCESS "  [SYSTEM/windows-sdk] ${packageName}, libs: ${_wsdkLibs}")
    set(${outResolved} TRUE PARENT_SCOPE)

  else()
    set(${outResolved} FALSE PARENT_SCOPE)
  endif()
endfunction()

# Internal: resolve a package via its prebuilt binary declaration.
# Sets outResolved to TRUE in PARENT_SCOPE if a target was created.
function(gpbt_resolveBinaryPackage cleanName packageName binaryIndex outResolved)
  gpbt_pushScope("thirdparty_${cleanName}_binary_${binaryIndex}")
  gpbt_getScopedProperty(_binaryUrl  _url)
  gpbt_getScopedProperty(_binaryHash _hash)
  gpbt_popScope()

  set(_fcName "gp_thirdparty_${cleanName}_binary")
  string(TOLOWER "${_fcName}" _fcNameLower)

  set(_hashArg "")
  if(_hash)
    set(_hashArg URL_HASH "${_hash}")
  endif()

  FetchContent_Declare(
    ${_fcName}
    URL "${_url}"
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    ${_hashArg}
  )
  FetchContent_GetProperties(${_fcName})
  if(NOT ${_fcNameLower}_POPULATED)
    FetchContent_Populate(${_fcName})
  endif()

  set(_extractedDir "${${_fcNameLower}_SOURCE_DIR}")
  gpbt_createTargetFromBinaryLayout("${cleanName}" "${_extractedDir}")

  gpbt_log(SUCCESS "  [BINARY] ${packageName}, extracted to ${_extractedDir}")
  set(${outResolved} TRUE PARENT_SCOPE)
endfunction()

# Internal: resolve a package by building it from source via FetchContent.
# Sets outResolved to TRUE in PARENT_SCOPE if a target was created.
function(gpbt_resolveSourcePackage cleanName packageName outResolved)
  gpbt_pushScope("thirdparty_${cleanName}")
  gpbt_getScopedProperty(_packageSourceUrl           _url)
  gpbt_getScopedProperty(_packageSourceHash          _hash)
  gpbt_getScopedProperty(_packageSourceTarget        _sourceTarget)
  gpbt_getScopedProperty(_packageCmakeArgs           _cmakeArgs)
  gpbt_getScopedProperty(_packageStripStrictWarnings _stripStrictWarnings)
  gpbt_popScope()

  if(NOT _url)
    gpbt_log(FATAL "Thirdparty package '${packageName}': no source URL declared and no matching binary found for platform '${GPBT_CURRENT_PLATFORM}' / compiler '${GPBT_CURRENT_COMPILER}'")
  endif()

  # Apply any package-specific cmake cache overrides before MakeAvailable
  foreach(_arg IN LISTS _cmakeArgs)
    string(REGEX MATCH "^([^=]+)=(.*)$" _match "${_arg}")
    if(_match)
      set(_key "${CMAKE_MATCH_1}")
      set(_val "${CMAKE_MATCH_2}")
      if(_val MATCHES "^(ON|OFF|TRUE|FALSE|YES|NO)$")
        set(${_key} "${_val}" CACHE BOOL "" FORCE)
      else()
        set(${_key} "${_val}" CACHE STRING "" FORCE)
      endif()
    else()
      gpbt_log(WARNING "gpThirdpartySetCMakeArgs: ignoring malformed argument '${_arg}' (expected KEY=VALUE)")
    endif()
  endforeach()

  set(_fcName "gp_thirdparty_${cleanName}_source")

  set(_hashArg "")
  if(_hash)
    set(_hashArg URL_HASH "${_hash}")
  endif()

  FetchContent_Declare(
    ${_fcName}
    URL "${_url}"
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    ${_hashArg}
  )

  # If the package opted out of strict warnings, shadow CMAKE_CXX_FLAGS and CMAKE_C_FLAGS
  # locally to strip -Werror / /WX before the subproject configures.  Because this is a
  # function(), the shadowed variables are automatically discarded on return, so the parent
  # project's flags are unaffected.
  if(_stripStrictWarnings)
    foreach(_flagVar CMAKE_CXX_FLAGS CMAKE_C_FLAGS)
      set(_stripped "${${_flagVar}}")
      # MSVC / Clang-CL: /WX or -WX (but not /WX- which is the "disable" form)
      string(REGEX REPLACE "(^|[ \t])(/WX|-WX)($|[ \t])" " " _stripped "${_stripped}")
      # GCC / Clang: -Werror or -Werror=<specific-warning>
      string(REGEX REPLACE "(^|[ \t])-Werror(=[^ \t]*)?([ \t]|$)" " " _stripped "${_stripped}")
      string(STRIP "${_stripped}" _stripped)
      set(${_flagVar} "${_stripped}")
    endforeach()
    gpbt_log(VERBOSE "  [SOURCE] ${packageName}: stripped -Werror/-WX from CMAKE_CXX/C_FLAGS for source build")
  endif()

  FetchContent_MakeAvailable(${_fcName})

  # Wrap the subproject's exported target under the gp::thirdparty:: namespace
  if(NOT _sourceTarget)
    set(_sourceTarget "${cleanName}::${cleanName}")
  endif()

  add_library(gp_thirdparty_${cleanName} INTERFACE)
  if(TARGET "${_sourceTarget}")
    target_link_libraries(gp_thirdparty_${cleanName} INTERFACE "${_sourceTarget}")
  else()
    gpbt_log(WARNING "Thirdparty '${packageName}' (source): expected target '${_sourceTarget}' was not created by the subproject, set TARGET in gpThirdpartySource() to the correct name")
  endif()
  add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})

  gpbt_log(SUCCESS "  [SOURCE] ${packageName}, built from source")
  set(${outResolved} TRUE PARENT_SCOPE)
endfunction()

# Public entry point: called by gpbt_endBuildTool() before target configuration.
# Iterates every registered package and applies SYSTEM → BINARY → SOURCE priority.
function(gpbt_resolveThirdpartyPackages)
  gpbt_getProperty(GPBT_THIRDPARTY_PACKAGES _packages)

  if(NOT _packages)
    gpbt_log(VERBOSE "No thirdparty packages registered, skipping resolution")
    return()
  endif()

  # Apply the global disconnect flag so cached downloads are reused immediately.
  if(GPBT_THIRDPARTY_UPDATES_DISCONNECTED)
    set(FETCHCONTENT_UPDATES_DISCONNECTED ON)
  endif()

  gpbt_logSection("Resolving thirdparty packages")
  list(LENGTH _packages _count)
  gpbt_log(INFO "Resolving ${_count} thirdparty package(s)...")

  foreach(_cleanName IN LISTS _packages)
    gpbt_pushScope("thirdparty_${_cleanName}")
    gpbt_getScopedProperty(_packageName _name)
    gpbt_getScopedProperty(_packageVersion _version)
    gpbt_getScopedProperty(_packageRequiredPlatforms _reqPlatforms)
    gpbt_getScopedProperty(_packageRequiredCompilers _reqCompilers)
    gpbt_getScopedProperty(_packageMode _pkgMode)
    gpbt_getScopedProperty(_packageBinaryCount _binaryCount)
    gpbt_getScopedProperty(_packageSystemMode _sysMode)
    gpbt_popScope()

    gpbt_log(INFO "  ${_name} ${_version}")

    # Platform gate
    if(_reqPlatforms AND NOT (GPBT_CURRENT_PLATFORM IN_LIST _reqPlatforms))
      gpbt_log(INFO "    Skipped, platform '${GPBT_CURRENT_PLATFORM}' not in [${_reqPlatforms}]")
      continue()
    endif()

    # Compiler gate
    if(_reqCompilers AND NOT (GPBT_CURRENT_COMPILER IN_LIST _reqCompilers))
      gpbt_log(INFO "    Skipped, compiler '${GPBT_CURRENT_COMPILER}' not in [${_reqCompilers}]")
      continue()
    endif()

    # Effective mode: package override → global cache var → AUTO
    set(_mode "${_pkgMode}")
    if(NOT _mode)
      set(_mode "${GPBT_THIRDPARTY_MODE}")
    endif()
    if(NOT _mode)
      set(_mode "AUTO")
    endif()

    # SYSTEM (always attempted first unless mode is SOURCE)
    if(_sysMode AND NOT (_mode STREQUAL "SOURCE"))
      gpbt_resolveSystemPackage("${_cleanName}" "${_name}" _resolved)
      if(_resolved)
        continue()
      endif()
      # Not resolved, fall through to binary/source
    endif()

    if(_mode STREQUAL "SOURCE")
      gpbt_resolveSourcePackage("${_cleanName}" "${_name}" _resolved)
      continue()
    endif()

    # BINARY: scan declared slots in order, pick the first matching combo
    set(_binaryIndex -1)
    if(_binaryCount GREATER 0)
      math(EXPR _last "${_binaryCount} - 1")
      foreach(_i RANGE 0 "${_last}")
        gpbt_pushScope("thirdparty_${_cleanName}_binary_${_i}")
        gpbt_getScopedProperty(_binaryPlatforms _slotPlatforms)
        gpbt_getScopedProperty(_binaryCompilers _slotCompilers)
        gpbt_popScope()

        # Empty list means "matches anything"
        set(_platformMatch TRUE)
        set(_compilerMatch TRUE)
        if(_slotPlatforms AND NOT (GPBT_CURRENT_PLATFORM IN_LIST _slotPlatforms))
          set(_platformMatch FALSE)
        endif()
        if(_slotCompilers AND NOT (GPBT_CURRENT_COMPILER IN_LIST _slotCompilers))
          set(_compilerMatch FALSE)
        endif()

        if(_platformMatch AND _compilerMatch)
          set(_binaryIndex ${_i})
          break()
        endif()
      endforeach()
    endif()

    if(_binaryIndex GREATER_EQUAL 0)
      gpbt_resolveBinaryPackage("${_cleanName}" "${_name}" "${_binaryIndex}" _resolved)
      continue()
    endif()

    # SOURCE fallback (only in AUTO mode)
    if(_mode STREQUAL "AUTO")
      gpbt_log(VERBOSE "    No binary matched, falling back to source build")
      gpbt_resolveSourcePackage("${_cleanName}" "${_name}" _resolved)
      continue()
    endif()

    # BINARY mode with no match: fatal
    gpbt_log(FATAL "Thirdparty package '${_name}': no prebuilt binary declared for platform '${GPBT_CURRENT_PLATFORM}' / compiler '${GPBT_CURRENT_COMPILER}' and mode is BINARY (no source fallback)")
  endforeach()

  gpbt_log(SUCCESS "Thirdparty resolution complete")
endfunction()
