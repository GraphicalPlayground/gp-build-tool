# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(FetchContent)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# Suppress the FetchContent_Populate single-arg deprecation warning (CMake 3.30+).
# We intentionally call FetchContent_Populate for binary-only archives and
# GPBT-managed source packages where add_subdirectory must NOT be invoked.
if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()

# Internal helper: resolve a path against baseDir unless it is already absolute
# or contains a CMake generator expression ($<...>).
function(gpbt_resolveThirdpartyPath rawPath baseDir outResolved)
  if("${rawPath}" MATCHES "\\$<")
    set(${outResolved} "${rawPath}" PARENT_SCOPE)
    return()
  endif()

  if(IS_ABSOLUTE "${rawPath}")
    get_filename_component(_resolved "${rawPath}" ABSOLUTE)
  elseif(baseDir)
    get_filename_component(_resolved "${baseDir}/${rawPath}" ABSOLUTE)
  else()
    set(_resolved "${rawPath}")
  endif()

  set(${outResolved} "${_resolved}" PARENT_SCOPE)
endfunction()

# Internal helper: apply declared include directories, compile definitions, compile options,
# compile features, and link libraries to a GPBT-managed or wrapped thirdparty target.
function(gpbt_applyThirdpartyTargetUsageRequirements targetName cleanName packageName sourceDir isInterface)
  gpbt_pushScope("thirdparty_${cleanName}")
  gpbt_getScopedProperty(_packageIncludeDirsPublic       _incPub)
  gpbt_getScopedProperty(_packageIncludeDirsPrivate      _incPriv)
  gpbt_getScopedProperty(_packageIncludeDirsInterface    _incIface)
  gpbt_getScopedProperty(_packageCompileDefsPublic       _defPub)
  gpbt_getScopedProperty(_packageCompileDefsPrivate      _defPriv)
  gpbt_getScopedProperty(_packageCompileDefsInterface    _defIface)
  gpbt_getScopedProperty(_packageCompileOptsPublic       _optPub)
  gpbt_getScopedProperty(_packageCompileOptsPrivate      _optPriv)
  gpbt_getScopedProperty(_packageCompileOptsInterface    _optIface)
  gpbt_getScopedProperty(_packageLinkLibsPublic          _libPub)
  gpbt_getScopedProperty(_packageLinkLibsPrivate         _libPriv)
  gpbt_getScopedProperty(_packageLinkLibsInterface       _libIface)
  gpbt_getScopedProperty(_packageCompileFeaturesPublic   _featPub)
  gpbt_getScopedProperty(_packageCompileFeaturesPrivate  _featPriv)
  gpbt_getScopedProperty(_packageCompileFeaturesInterface _featIface)
  gpbt_popScope()

  # Resolve and validate include directories
  set(_resolvedIncPub "")
  set(_resolvedIncPriv "")
  set(_resolvedIncIface "")

  foreach(_bucket IN ITEMS Pub Priv Iface)
    foreach(_rawDir IN LISTS _inc${_bucket})
      gpbt_resolveThirdpartyPath("${_rawDir}" "${sourceDir}" _dir)
      if(NOT "${_dir}" MATCHES "\\$<" AND NOT IS_DIRECTORY "${_dir}")
        gpbt_log(WARNING "Thirdparty '${packageName}': include directory does not exist: '${_dir}'")
      endif()
      if(NOT _dir IN_LIST _resolvedInc${_bucket})
        list(APPEND _resolvedInc${_bucket} "${_dir}")
      endif()
    endforeach()
  endforeach()

  if(isInterface)
    # INTERFACE targets only support INTERFACE visibility; merge PUBLIC + INTERFACE.
    set(_mergedInc ${_resolvedIncPub})
    foreach(_d IN LISTS _resolvedIncIface)
      if(NOT _d IN_LIST _mergedInc)
        list(APPEND _mergedInc "${_d}")
      endif()
    endforeach()
    if(_mergedInc)
      target_include_directories(${targetName} SYSTEM INTERFACE ${_mergedInc})
    endif()
    if(_resolvedIncPriv)
      gpbt_log(WARNING "Thirdparty '${packageName}': PRIVATE include directories are ignored on INTERFACE target '${targetName}'")
    endif()

    set(_mergedDefs ${_defPub} ${_defIface})
    if(_mergedDefs)
      target_compile_definitions(${targetName} INTERFACE ${_mergedDefs})
    endif()
    if(_defPriv)
      gpbt_log(WARNING "Thirdparty '${packageName}': PRIVATE compile definitions are ignored on INTERFACE target '${targetName}'")
    endif()

    set(_mergedOpts ${_optPub} ${_optIface})
    if(_mergedOpts)
      target_compile_options(${targetName} INTERFACE ${_mergedOpts})
    endif()
    if(_optPriv)
      gpbt_log(WARNING "Thirdparty '${packageName}': PRIVATE compile options are ignored on INTERFACE target '${targetName}'")
    endif()

    set(_mergedFeats ${_featPub} ${_featIface})
    if(_mergedFeats)
      target_compile_features(${targetName} INTERFACE ${_mergedFeats})
    endif()
    if(_featPriv)
      gpbt_log(WARNING "Thirdparty '${packageName}': PRIVATE compile features are ignored on INTERFACE target '${targetName}'")
    endif()

    set(_mergedLibs ${_libPub} ${_libIface})
    if(_mergedLibs)
      target_link_libraries(${targetName} INTERFACE ${_mergedLibs})
    endif()
    if(_libPriv)
      gpbt_log(WARNING "Thirdparty '${packageName}': PRIVATE link libraries are ignored on INTERFACE target '${targetName}'")
    endif()
  else()
    if(_resolvedIncPub)
      target_include_directories(${targetName} SYSTEM PUBLIC ${_resolvedIncPub})
    endif()
    if(_resolvedIncIface)
      target_include_directories(${targetName} SYSTEM INTERFACE ${_resolvedIncIface})
    endif()
    if(_resolvedIncPriv)
      target_include_directories(${targetName} SYSTEM PRIVATE ${_resolvedIncPriv})
    endif()

    if(_defPub)
      target_compile_definitions(${targetName} PUBLIC ${_defPub})
    endif()
    if(_defIface)
      target_compile_definitions(${targetName} INTERFACE ${_defIface})
    endif()
    if(_defPriv)
      target_compile_definitions(${targetName} PRIVATE ${_defPriv})
    endif()

    if(_optPub)
      target_compile_options(${targetName} PUBLIC ${_optPub})
    endif()
    if(_optIface)
      target_compile_options(${targetName} INTERFACE ${_optIface})
    endif()
    if(_optPriv)
      target_compile_options(${targetName} PRIVATE ${_optPriv})
    endif()

    if(_featPub)
      target_compile_features(${targetName} PUBLIC ${_featPub})
    endif()
    if(_featIface)
      target_compile_features(${targetName} INTERFACE ${_featIface})
    endif()
    if(_featPriv)
      target_compile_features(${targetName} PRIVATE ${_featPriv})
    endif()

    if(_libPub)
      target_link_libraries(${targetName} PUBLIC ${_libPub})
    endif()
    if(_libIface)
      target_link_libraries(${targetName} INTERFACE ${_libIface})
    endif()
    if(_libPriv)
      target_link_libraries(${targetName} PRIVATE ${_libPriv})
    endif()
  endif()
endfunction()

# Internal helper: create a GPBT-managed CMake target (STATIC, SHARED, MODULE, OBJECT, or INTERFACE)
# from manually declared sources and usage requirements, exposed as gp::thirdparty::<cleanName>.
function(gpbt_createManagedThirdpartyTarget cleanName packageName sourceDir)
  gpbt_pushScope("thirdparty_${cleanName}")
  gpbt_getScopedProperty(_packageSources                                     _sources)
  gpbt_getScopedProperty(_packagePlatformSources_${GPBT_CURRENT_PLATFORM}    _platformSources)
  gpbt_getScopedProperty(_packageLibraryType                                 _libraryType)
  gpbt_getScopedProperty(_packagePositionIndependentCode                     _pic)
  gpbt_getScopedProperty(_packageStripStrictWarnings                         _stripStrictWarnings)
  gpbt_popScope()

  # Resolve and deduplicate declared sources (common + current platform)
  set(_allRawSources ${_sources} ${_platformSources})
  set(_resolvedSources "")
  foreach(_rawSrc IN LISTS _allRawSources)
    gpbt_resolveThirdpartyPath("${_rawSrc}" "${sourceDir}" _srcPath)
    if(NOT "${_srcPath}" MATCHES "\\$<")
      get_source_file_property(_isGenerated "${_srcPath}" GENERATED)
      if(NOT EXISTS "${_srcPath}" AND NOT _isGenerated)
        gpbt_log(FATAL "Thirdparty '${packageName}': declared source file does not exist: '${_srcPath}' (from '${_rawSrc}')")
      endif()
    endif()
    if(NOT _srcPath IN_LIST _resolvedSources)
      list(APPEND _resolvedSources "${_srcPath}")
    endif()
  endforeach()

  # Determine effective library type when not explicitly specified:
  #   - STATIC if sources are declared (safe across all platforms including Windows)
  #   - INTERFACE if no sources are declared (header-only library)
  if(NOT _libraryType)
    if(_resolvedSources)
      set(_libraryType "STATIC")
    else()
      set(_libraryType "INTERFACE")
    endif()
  endif()

  set(_targetName "gp_thirdparty_${cleanName}")

  if(_libraryType STREQUAL "INTERFACE")
    if(_resolvedSources)
      gpbt_log(FATAL "Thirdparty '${packageName}': library type INTERFACE cannot compile source files. Remove gpThirdpartySetSources() or select STATIC, SHARED, MODULE, or OBJECT.")
    endif()

    add_library(${_targetName} INTERFACE)
    gpbt_applyThirdpartyTargetUsageRequirements("${_targetName}" "${cleanName}" "${packageName}" "${sourceDir}" TRUE)
  else()
    if(NOT _resolvedSources)
      gpbt_log(FATAL "Thirdparty '${packageName}': library type '${_libraryType}' requires at least one source file. Declare sources with gpThirdpartySetSources() or use INTERFACE for header-only libraries.")
    endif()

    add_library(${_targetName} ${_libraryType} ${_resolvedSources})
    set_target_properties(${_targetName} PROPERTIES FOLDER "thirdparty")

    if(_pic)
      set_target_properties(${_targetName} PROPERTIES POSITION_INDEPENDENT_CODE ${_pic})
    endif()

    if(WIN32 AND _libraryType STREQUAL "SHARED")
      set_target_properties(${_targetName} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()

    if(_stripStrictWarnings)
      if(MSVC OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options(${_targetName} PRIVATE /W0)
      else()
        target_compile_options(${_targetName} PRIVATE -w)
      endif()
    endif()

    gpbt_applyThirdpartyTargetUsageRequirements("${_targetName}" "${cleanName}" "${packageName}" "${sourceDir}" FALSE)
  endif()

  add_library(gp::thirdparty::${cleanName} ALIAS ${_targetName})
  gpbt_log(VERBOSE "  [MANAGED/${_libraryType}] ${packageName} -> gp::thirdparty::${cleanName}")
endfunction()

# Internal helper: wrap an upstream CMake target under gp::thirdparty::<cleanName>.
function(gpbt_wrapUpstreamThirdpartyTarget cleanName packageName upstreamTarget sourceDir)
  set(_targetName "gp_thirdparty_${cleanName}")
  add_library(${_targetName} INTERFACE)
  target_link_libraries(${_targetName} INTERFACE "${upstreamTarget}")
  gpbt_applyThirdpartyTargetUsageRequirements("${_targetName}" "${cleanName}" "${packageName}" "${sourceDir}" TRUE)
  add_library(gp::thirdparty::${cleanName} ALIAS ${_targetName})
endfunction()

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
      gpbt_applyThirdpartyTargetUsageRequirements("gp_thirdparty_${cleanName}" "${cleanName}" "${packageName}" "" TRUE)
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
    gpbt_applyThirdpartyTargetUsageRequirements("gp_thirdparty_${cleanName}" "${cleanName}" "${packageName}" "" TRUE)
    add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
    gpbt_log(SUCCESS "  [SYSTEM/framework] ${packageName}, frameworks: ${_frameworks}")
    set(${outResolved} TRUE PARENT_SCOPE)

  elseif(_sysMode STREQUAL "WINDOWS_SDK")
    add_library(gp_thirdparty_${cleanName} INTERFACE)
    foreach(_lib IN LISTS _wsdkLibs)
      target_link_libraries(gp_thirdparty_${cleanName} INTERFACE "${_lib}.lib")
    endforeach()
    gpbt_applyThirdpartyTargetUsageRequirements("gp_thirdparty_${cleanName}" "${cleanName}" "${packageName}" "" TRUE)
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
    SYSTEM
    ${_hashArg}
  )
  FetchContent_GetProperties(${_fcName})
  if(NOT ${_fcNameLower}_POPULATED)
    FetchContent_Populate(${_fcName})
  endif()

  set(_extractedDir "${${_fcNameLower}_SOURCE_DIR}")
  gpbt_createTargetFromBinaryLayout("${cleanName}" "${_extractedDir}")
  gpbt_applyThirdpartyTargetUsageRequirements("gp_thirdparty_${cleanName}" "${cleanName}" "${packageName}" "${_extractedDir}" TRUE)

  gpbt_log(SUCCESS "  [BINARY] ${packageName}, extracted to ${_extractedDir}")
  set(${outResolved} TRUE PARENT_SCOPE)
endfunction()

# Internal helper: walk a directory tree and append the error-suppression flag to every
# compiled target (EXECUTABLE, STATIC/SHARED/MODULE/OBJECT_LIBRARY).
# Recursively silence ALL warnings on every compiled target under a directory.
# /W0 (MSVC/Clang-CL) and -w (GCC/Clang) are the strongest suppression flags:
# they disable every diagnostic category, not just error-promotion.
# Appended as PRIVATE target_compile_options so they appear after any project-wide
# /W4 or -Wall in the build command and therefore take precedence.
function(gpbt_suppressStrictWarningsInDirectory dir)
  if(NOT IS_DIRECTORY "${dir}")
    return()
  endif()

  get_directory_property(_dirTargets DIRECTORY "${dir}" BUILDSYSTEM_TARGETS)
  foreach(_tgt IN LISTS _dirTargets)
    if(NOT TARGET "${_tgt}")
      continue()
    endif()
    get_target_property(_tgtType "${_tgt}" TYPE)
    if(_tgtType MATCHES "^(EXECUTABLE|STATIC_LIBRARY|SHARED_LIBRARY|MODULE_LIBRARY|OBJECT_LIBRARY)$")
      if(MSVC OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options("${_tgt}" PRIVATE /W0)
      else()
        target_compile_options("${_tgt}" PRIVATE -w)
      endif()
    endif()
  endforeach()

  get_directory_property(_subdirs DIRECTORY "${dir}" SUBDIRECTORIES)
  foreach(_sub IN LISTS _subdirs)
    gpbt_suppressStrictWarningsInDirectory("${_sub}")
  endforeach()
endfunction()

# Internal: resolve a package by building it from source (URL archive or Git repository)
# via FetchContent. Sets outResolved to TRUE in PARENT_SCOPE if a target was created.
function(gpbt_resolveSourcePackage cleanName packageName outResolved)
  gpbt_pushScope("thirdparty_${cleanName}")
  gpbt_getScopedProperty(_packageSourceType          _srcType)
  gpbt_getScopedProperty(_packageSourceUrl           _url)
  gpbt_getScopedProperty(_packageSourceHash          _hash)
  gpbt_getScopedProperty(_packageSourceTarget        _sourceTarget)
  gpbt_getScopedProperty(_packageCmakeArgs           _cmakeArgs)
  gpbt_getScopedProperty(_packageStripStrictWarnings _stripStrictWarnings)
  gpbt_getScopedProperty(_packageGitRepository       _gitRepo)
  gpbt_getScopedProperty(_packageGitTag              _gitTag)
  gpbt_getScopedProperty(_packageGitShallow          _gitShallow)
  gpbt_getScopedProperty(_packagePatchCommand        _patchCommand)
  gpbt_getScopedProperty(_packageSources             _manualSources)
  gpbt_getScopedProperty(_packagePlatformSources_${GPBT_CURRENT_PLATFORM} _manualPlatformSources)
  gpbt_getScopedProperty(_packageIncludeDirsPublic   _manualIncPub)
  gpbt_getScopedProperty(_packageIncludeDirsPrivate  _manualIncPriv)
  gpbt_getScopedProperty(_packageIncludeDirsInterface _manualIncIface)
  gpbt_getScopedProperty(_packageLibraryType         _manualLibraryType)
  gpbt_popScope()

  set(_hasManualBuild FALSE)
  if(_manualSources OR _manualPlatformSources OR _manualIncPub OR _manualIncPriv OR _manualIncIface OR _manualLibraryType)
    set(_hasManualBuild TRUE)
  endif()

  set(_hasExplicitTarget FALSE)
  if(_sourceTarget)
    set(_hasExplicitTarget TRUE)
  endif()

  if(_srcType STREQUAL "GIT")
    if(NOT _gitRepo OR NOT _gitTag)
      gpbt_log(FATAL "Thirdparty package '${packageName}': GIT source requires both REPOSITORY and TAG")
    endif()
  elseif(NOT _url)
    gpbt_log(FATAL "Thirdparty package '${packageName}': no source URL or git repository declared and no matching binary found for platform '${GPBT_CURRENT_PLATFORM}' / compiler '${GPBT_CURRENT_COMPILER}'")
  endif()

  set(_fcName "gp_thirdparty_${cleanName}_source")
  string(TOLOWER "${_fcName}" _fcNameLower)

  # Build the optional PATCH_COMMAND forwarding argument
  set(_patchArg "")
  if(_patchCommand)
    set(_patchArg PATCH_COMMAND ${_patchCommand})
  endif()

  if(_srcType STREQUAL "GIT")
    set(_shallowArg "")
    if(_gitShallow)
      set(_shallowArg GIT_SHALLOW TRUE)
    endif()

    FetchContent_Declare(
      ${_fcName}
      GIT_REPOSITORY "${_gitRepo}"
      GIT_TAG        "${_gitTag}"
      GIT_PROGRESS   TRUE
      SYSTEM
      ${_shallowArg}
      ${_patchArg}
    )
  else()
    set(_hashArg "")
    if(_hash)
      set(_hashArg URL_HASH "${_hash}")
    endif()

    FetchContent_Declare(
      ${_fcName}
      URL "${_url}"
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
      SYSTEM
      ${_hashArg}
      ${_patchArg}
    )
  endif()

  if(_hasManualBuild AND NOT _hasExplicitTarget)
    # GPBT-managed target generation: populate sources without invoking any upstream
    # CMakeLists.txt so we never create duplicate targets or run broken subprojects.
    FetchContent_GetProperties(${_fcName})
    if(NOT ${_fcNameLower}_POPULATED)
      FetchContent_Populate(${_fcName})
    endif()

    set(_sourceDir "${${_fcNameLower}_SOURCE_DIR}")
    gpbt_createManagedThirdpartyTarget("${cleanName}" "${packageName}" "${_sourceDir}")

    if(_srcType STREQUAL "GIT")
      gpbt_log(SUCCESS "  [GIT/managed] ${packageName} @ ${_gitTag}, target generated by GPBT")
    else()
      gpbt_log(SUCCESS "  [SOURCE/managed] ${packageName}, target generated by GPBT")
    endif()
    set(${outResolved} TRUE PARENT_SCOPE)
    return()
  endif()

  # Upstream CMake subproject path: apply any package-specific cmake cache overrides
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

  # Packages that opted out of strict warnings must also be built as STATIC libraries.
  # BUILD_SHARED_LIBS=ON is set globally by GPBT's defaulter and propagates into every
  # FetchContent subproject, turning test framework libraries into DLLs.  Those DLLs then
  # fail to load at test-run time because Windows resolves DLLs from the executable's
  # directory first, and the build directory layout doesn't guarantee co-location.
  # Forcing static here avoids the DLL entirely; the save/restore ensures subsequent
  # packages are not affected.
  if(_stripStrictWarnings)
    set(_gpbt_saved_BUILD_SHARED_LIBS "${BUILD_SHARED_LIBS}")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
  endif()

  FetchContent_MakeAvailable(${_fcName})
  set(_sourceDir "${${_fcNameLower}_SOURCE_DIR}")

  if(_stripStrictWarnings)
    # Restore BUILD_SHARED_LIBS for all packages that come after this one.
    set(BUILD_SHARED_LIBS "${_gpbt_saved_BUILD_SHARED_LIBS}" CACHE BOOL "" FORCE)

    # Walk every compiled target in the subproject tree and silence all warnings.
    # /W0 (MSVC/Clang-CL) and -w (GCC/Clang) are the strongest suppression flags and
    # override any project-wide /W4 or -Wall because they appear last in the command.
    gpbt_suppressStrictWarningsInDirectory("${_sourceDir}")
    gpbt_log(VERBOSE "  [SOURCE] ${packageName}: forced static build and silenced all warnings")
  endif()

  # Wrap the subproject's exported target under the gp::thirdparty:: namespace,
  # or fall back to GPBT-managed target generation if manual sources/config were declared.
  set(_expectedTarget "${_sourceTarget}")
  if(NOT _expectedTarget)
    set(_expectedTarget "${cleanName}::${cleanName}")
  endif()

  if(TARGET "${_expectedTarget}")
    if(_hasManualBuild AND (_manualSources OR _manualPlatformSources))
      gpbt_log(VERBOSE "  [SOURCE] ${packageName}: upstream target '${_expectedTarget}' found; skipping manual source compilation to avoid duplicate compilation")
    endif()
    gpbt_wrapUpstreamThirdpartyTarget("${cleanName}" "${packageName}" "${_expectedTarget}" "${_sourceDir}")
  elseif(_hasManualBuild)
    gpbt_log(VERBOSE "  [SOURCE] ${packageName}: upstream target '${_expectedTarget}' not found; generating GPBT-managed target")
    gpbt_createManagedThirdpartyTarget("${cleanName}" "${packageName}" "${_sourceDir}")
  else()
    add_library(gp_thirdparty_${cleanName} INTERFACE)
    if(_srcType STREQUAL "GIT")
      gpbt_log(WARNING "Thirdparty '${packageName}' (git): expected target '${_expectedTarget}' was not created by the subproject, set TARGET in gpThirdpartyGit() to the correct name or declare sources/includes with gpThirdpartySetSources() / gpThirdpartySetIncludeDirectories()")
    else()
      gpbt_log(WARNING "Thirdparty '${packageName}' (source): expected target '${_expectedTarget}' was not created by the subproject, set TARGET in gpThirdpartySource() to the correct name or declare sources/includes with gpThirdpartySetSources() / gpThirdpartySetIncludeDirectories()")
    endif()
    gpbt_applyThirdpartyTargetUsageRequirements("gp_thirdparty_${cleanName}" "${cleanName}" "${packageName}" "${_sourceDir}" TRUE)
    add_library(gp::thirdparty::${cleanName} ALIAS gp_thirdparty_${cleanName})
  endif()

  if(_srcType STREQUAL "GIT")
    gpbt_log(SUCCESS "  [GIT] ${packageName} @ ${_gitTag}, built from source")
  else()
    gpbt_log(SUCCESS "  [SOURCE] ${packageName}, built from source")
  endif()
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
