# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/tests/asserts)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/thirdparty/core)

# Helper: create a local fixture directory with minimal C++ source and header files
# so target generation tests run offline without network access.
set(_gpbt_tp_fixture_dir "${CMAKE_CURRENT_BINARY_DIR}/_gpbt_tp_fixtures")
file(MAKE_DIRECTORY "${_gpbt_tp_fixture_dir}/include")
file(MAKE_DIRECTORY "${_gpbt_tp_fixture_dir}/src")
file(WRITE "${_gpbt_tp_fixture_dir}/include/dummy.hpp" "#pragma once\nint gpbt_dummy_fn();\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/dummy_a.cpp" "int gpbt_dummy_fn() { return 42; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/dummy_b.cpp" "int gpbt_dummy_b() { return 7; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_win.cpp" "int gpbt_plat() { return 1; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_linux.cpp" "int gpbt_plat() { return 2; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_macos.cpp" "int gpbt_plat() { return 3; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_ios.cpp" "int gpbt_plat() { return 4; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_android.cpp" "int gpbt_plat() { return 5; }\n")
file(WRITE "${_gpbt_tp_fixture_dir}/src/plat_freebsd.cpp" "int gpbt_plat() { return 6; }\n")

# Registration & Property Storage Tests

gpbt_startTestSection("Thirdparty: gpThirdpartySetSources accumulates and deduplicates")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_sources_test" VERSION "1.0.0")
    gpThirdpartySetSources(src/a.cpp src/b.cpp)
    gpThirdpartySetSources(src/b.cpp src/c.cpp)
  gpEndThirdparty()

  gpbt_testGetThirdpartyProperty("tp_sources_test" _packageSources _srcs)
  list(LENGTH _srcs _len)
  gpbt_assertEqual("${_len}" "3" "Duplicate source 'src/b.cpp' should be ignored")
  gpbt_assertEqual("${_srcs}" "src/a.cpp;src/b.cpp;src/c.cpp" "Sources should accumulate in order without duplicates")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: gpThirdpartySetSourcesByPlatform stores per-platform lists")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_plat_sources_test" VERSION "1.0.0")
    gpThirdpartySetSourcesByPlatform(
      Windows
        src/plat_win.cpp
      Linux
        src/plat_linux.cpp
      macOS
        src/plat_macos.cpp
    )
    gpThirdpartySetSourcesByPlatform(
      Windows
        src/plat_win.cpp
        src/plat_win2.cpp
    )
  gpEndThirdparty()

  gpbt_testGetThirdpartyProperty("tp_plat_sources_test" _packagePlatformSources_Windows _winSrcs)
  gpbt_testGetThirdpartyProperty("tp_plat_sources_test" _packagePlatformSources_Linux   _linSrcs)
  gpbt_testGetThirdpartyProperty("tp_plat_sources_test" _packagePlatformSources_macOS   _macSrcs)

  gpbt_assertEqual("${_winSrcs}" "src/plat_win.cpp;src/plat_win2.cpp" "Windows sources should accumulate and deduplicate")
  gpbt_assertEqual("${_linSrcs}" "src/plat_linux.cpp" "Linux sources should be stored separately")
  gpbt_assertEqual("${_macSrcs}" "src/plat_macos.cpp" "macOS sources should be stored separately")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: gpThirdpartySetIncludeDirectories supports default PUBLIC and explicit visibilities")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_inc_test" VERSION "1.0.0")
    gpThirdpartySetIncludeDirectories("." "include")
    gpThirdpartySetIncludeDirectories("include" PRIVATE "src" INTERFACE "iface")
  gpEndThirdparty()

  gpbt_testGetThirdpartyProperty("tp_inc_test" _packageIncludeDirsPublic    _pubInc)
  gpbt_testGetThirdpartyProperty("tp_inc_test" _packageIncludeDirsPrivate   _privInc)
  gpbt_testGetThirdpartyProperty("tp_inc_test" _packageIncludeDirsInterface _ifaceInc)

  gpbt_assertEqual("${_pubInc}"   ".;include" "Default visibility should be PUBLIC and deduplicate")
  gpbt_assertEqual("${_privInc}"  "src"       "PRIVATE include dir should be stored in private bucket")
  gpbt_assertEqual("${_ifaceInc}" "iface"     "INTERFACE include dir should be stored in interface bucket")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: gpThirdpartySetLibraryType accepts all supported library types")
  gpbt_startBuildTool()
  foreach(_type IN ITEMS STATIC SHARED MODULE OBJECT INTERFACE)
    string(TOLOWER "${_type}" _typeLower)
    gpStartThirdparty("tp_libtype_${_typeLower}" VERSION "1.0.0")
      gpThirdpartySetLibraryType(${_type})
    gpEndThirdparty()
    gpbt_testGetThirdpartyProperty("tp_libtype_${_typeLower}" _packageLibraryType _stored)
    gpbt_assertEqual("${_stored}" "${_type}" "Library type ${_type} should be stored")
  endforeach()
  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: compile definitions, options, features, link libs, and PIC storage")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_props_test" VERSION "1.0.0")
    gpThirdpartySetCompileDefinitions(DEF_A DEF_B=1 PRIVATE DEF_PRIV)
    gpThirdpartySetCompileOptions(-Wall PUBLIC -DPUB_OPT)
    gpThirdpartySetCompileFeatures(cxx_std_17 PRIVATE c_std_11)
    gpThirdpartySetLinkLibraries(PRIVATE Threads::Threads PUBLIC m)
    gpThirdpartySetPositionIndependentCode(ON)
  gpEndThirdparty()

  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileDefsPublic     _defPub)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileDefsPrivate    _defPriv)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileOptsPublic     _optPub)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileOptsPrivate    _optPriv)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileFeaturesPublic _featPub)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageCompileFeaturesPrivate _featPriv)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageLinkLibsPublic        _libPub)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packageLinkLibsPrivate       _libPriv)
  gpbt_testGetThirdpartyProperty("tp_props_test" _packagePositionIndependentCode _pic)

  gpbt_assertEqual("${_defPub}"  "DEF_A;DEF_B=1"    "Compile definitions default to PUBLIC")
  gpbt_assertEqual("${_defPriv}" "DEF_PRIV"         "PRIVATE compile definition stored separately")
  gpbt_assertEqual("${_optPriv}" "-Wall"            "Compile options default to PRIVATE to prevent leakage")
  gpbt_assertEqual("${_optPub}"  "-DPUB_OPT"        "Explicit PUBLIC compile option stored in PUBLIC bucket")
  gpbt_assertEqual("${_featPub}" "cxx_std_17"       "Compile features default to PUBLIC")
  gpbt_assertEqual("${_featPriv}" "c_std_11"        "Explicit PRIVATE compile feature stored in PRIVATE bucket")
  gpbt_assertEqual("${_libPub}"  "m"                "Explicit PUBLIC link library stored in PUBLIC bucket")
  gpbt_assertEqual("${_libPriv}" "Threads::Threads" "Explicit PRIVATE link library stored in PRIVATE bucket")
  gpbt_assertEqual("${_pic}"     "ON"               "POSITION_INDEPENDENT_CODE stored as ON")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

# Managed Target Generation Tests (using local offline fixtures)

gpbt_startTestSection("Thirdparty: managed STATIC target creation and property propagation")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_gen_static" VERSION "1.0.0")
    gpThirdpartySetLibraryType(STATIC)
    gpThirdpartySetSources(src/dummy_a.cpp src/dummy_b.cpp)
    gpThirdpartySetIncludeDirectories("." "include")
    gpThirdpartySetCompileDefinitions(TP_PUBLIC_DEF=1 PRIVATE TP_PRIVATE_DEF=2)
    gpThirdpartySetCompileOptions(PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/W3> $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall>)
    gpThirdpartySetCompileFeatures(cxx_std_17)
    gpThirdpartySetPositionIndependentCode(ON)
  gpEndThirdparty()

  gpbt_createManagedThirdpartyTarget("tp_gen_static" "tp_gen_static" "${_gpbt_tp_fixture_dir}")

  if(TARGET gp::thirdparty::tp_gen_static)
    gpbt_assertSuccess("Alias target gp::thirdparty::tp_gen_static exists")
  else()
    gpbt_assertFail("Alias target gp::thirdparty::tp_gen_static was not created")
  endif()

  get_target_property(_tgtType gp_thirdparty_tp_gen_static TYPE)
  gpbt_assertEqual("${_tgtType}" "STATIC_LIBRARY" "Target type should be STATIC_LIBRARY")

  get_target_property(_tgtPic gp_thirdparty_tp_gen_static POSITION_INDEPENDENT_CODE)
  gpbt_assertEqual("${_tgtPic}" "ON" "POSITION_INDEPENDENT_CODE property should be ON")

  get_target_property(_ifaceDefs gp_thirdparty_tp_gen_static INTERFACE_COMPILE_DEFINITIONS)
  list(FIND _ifaceDefs "TP_PUBLIC_DEF=1" _pubDefIdx)
  list(FIND _ifaceDefs "TP_PRIVATE_DEF=2" _privDefIdx)
  if(_pubDefIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("PUBLIC compile definition propagated to INTERFACE_COMPILE_DEFINITIONS")
  else()
    gpbt_assertFail("PUBLIC compile definition missing from INTERFACE_COMPILE_DEFINITIONS: ${_ifaceDefs}")
  endif()
  if(_privDefIdx LESS 0)
    gpbt_assertSuccess("PRIVATE compile definition did not leak into INTERFACE_COMPILE_DEFINITIONS")
  else()
    gpbt_assertFail("PRIVATE compile definition leaked into INTERFACE_COMPILE_DEFINITIONS")
  endif()

  get_target_property(_ifaceOpts gp_thirdparty_tp_gen_static INTERFACE_COMPILE_OPTIONS)
  if(NOT _ifaceOpts)
    gpbt_assertSuccess("PRIVATE compile options did not leak into INTERFACE_COMPILE_OPTIONS")
  else()
    gpbt_assertFail("PRIVATE compile options leaked into INTERFACE_COMPILE_OPTIONS: ${_ifaceOpts}")
  endif()

  get_target_property(_ifaceFeats gp_thirdparty_tp_gen_static INTERFACE_COMPILE_FEATURES)
  list(FIND _ifaceFeats "cxx_std_17" _featIdx)
  if(_featIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Compile feature cxx_std_17 propagated to INTERFACE_COMPILE_FEATURES")
  else()
    gpbt_assertFail("Compile feature cxx_std_17 missing: ${_ifaceFeats}")
  endif()

  get_target_property(_ifaceInc gp_thirdparty_tp_gen_static INTERFACE_INCLUDE_DIRECTORIES)
  list(FIND _ifaceInc "${_gpbt_tp_fixture_dir}/include" _incIdx)
  if(_incIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Resolved include directory present in INTERFACE_INCLUDE_DIRECTORIES")
  else()
    gpbt_assertFail("Resolved include directory missing from INTERFACE_INCLUDE_DIRECTORIES: ${_ifaceInc}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: default library type inference (STATIC with sources, INTERFACE without)")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_default_static" VERSION "1.0.0")
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartySetIncludeDirectories(include)
  gpEndThirdparty()

  gpStartThirdparty("tp_default_interface" VERSION "1.0.0")
    gpThirdpartySetIncludeDirectories(include)
    gpThirdpartySetCompileDefinitions(HEADER_ONLY_DEF=1)
  gpEndThirdparty()

  gpbt_createManagedThirdpartyTarget("tp_default_static" "tp_default_static" "${_gpbt_tp_fixture_dir}")
  gpbt_createManagedThirdpartyTarget("tp_default_interface" "tp_default_interface" "${_gpbt_tp_fixture_dir}")

  get_target_property(_t1 gp_thirdparty_tp_default_static TYPE)
  get_target_property(_t2 gp_thirdparty_tp_default_interface TYPE)
  gpbt_assertEqual("${_t1}" "STATIC_LIBRARY"    "Sources without explicit type should default to STATIC")
  gpbt_assertEqual("${_t2}" "INTERFACE_LIBRARY" "No sources without explicit type should default to INTERFACE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: SHARED, OBJECT, and MODULE managed target creation")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_gen_shared" VERSION "1.0.0")
    gpThirdpartySetLibraryType(SHARED)
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartySetIncludeDirectories(include)
  gpEndThirdparty()

  gpStartThirdparty("tp_gen_object" VERSION "1.0.0")
    gpThirdpartySetLibraryType(OBJECT)
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartySetIncludeDirectories(include)
  gpEndThirdparty()

  gpStartThirdparty("tp_gen_module" VERSION "1.0.0")
    gpThirdpartySetLibraryType(MODULE)
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartySetIncludeDirectories(include)
  gpEndThirdparty()

  gpbt_createManagedThirdpartyTarget("tp_gen_shared" "tp_gen_shared" "${_gpbt_tp_fixture_dir}")
  gpbt_createManagedThirdpartyTarget("tp_gen_object" "tp_gen_object" "${_gpbt_tp_fixture_dir}")
  gpbt_createManagedThirdpartyTarget("tp_gen_module" "tp_gen_module" "${_gpbt_tp_fixture_dir}")

  get_target_property(_tShared gp_thirdparty_tp_gen_shared TYPE)
  get_target_property(_tObject gp_thirdparty_tp_gen_object TYPE)
  get_target_property(_tModule gp_thirdparty_tp_gen_module TYPE)
  gpbt_assertEqual("${_tShared}" "SHARED_LIBRARY" "SHARED library type creates SHARED_LIBRARY")
  gpbt_assertEqual("${_tObject}" "OBJECT_LIBRARY" "OBJECT library type creates OBJECT_LIBRARY")
  gpbt_assertEqual("${_tModule}" "MODULE_LIBRARY" "MODULE library type creates MODULE_LIBRARY")

  if(WIN32)
    get_target_property(_winExport gp_thirdparty_tp_gen_shared WINDOWS_EXPORT_ALL_SYMBOLS)
    gpbt_assertEqual("${_winExport}" "ON" "SHARED library on Windows should enable WINDOWS_EXPORT_ALL_SYMBOLS")
  endif()

  # Verify OBJECT library can be consumed via target_link_libraries using the gp::thirdparty:: alias
  add_library(gpbt_test_obj_consumer STATIC "${_gpbt_tp_fixture_dir}/src/dummy_b.cpp")
  target_link_libraries(gpbt_test_obj_consumer PRIVATE gp::thirdparty::tp_gen_object)
  gpbt_assertSuccess("OBJECT library alias gp::thirdparty::tp_gen_object links cleanly into a consumer target")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: platform-specific source selection picks only active platform")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_gen_plat" VERSION "1.0.0")
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartySetSourcesByPlatform(
      Windows src/plat_win.cpp
      Linux   src/plat_linux.cpp
      macOS   src/plat_macos.cpp
      iOS     src/plat_ios.cpp
      Android src/plat_android.cpp
      FreeBSD src/plat_freebsd.cpp
    )
    gpThirdpartySetIncludeDirectories(include)
  gpEndThirdparty()

  gpbt_createManagedThirdpartyTarget("tp_gen_plat" "tp_gen_plat" "${_gpbt_tp_fixture_dir}")

  get_target_property(_platSources gp_thirdparty_tp_gen_plat SOURCES)
  list(LENGTH _platSources _srcCount)
  gpbt_assertEqual("${_srcCount}" "2" "Target should have common source + exactly one active-platform source")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: gpThirdpartyDisableStrictWarnings applies PRIVATE suppression on managed targets")
  gpbt_startBuildTool()
  gpStartThirdparty("tp_gen_nowarn" VERSION "1.0.0")
    gpThirdpartySetSources(src/dummy_a.cpp)
    gpThirdpartyDisableStrictWarnings()
  gpEndThirdparty()

  gpbt_createManagedThirdpartyTarget("tp_gen_nowarn" "tp_gen_nowarn" "${_gpbt_tp_fixture_dir}")

  get_target_property(_privOpts gp_thirdparty_tp_gen_nowarn COMPILE_OPTIONS)
  get_target_property(_ifaceOpts gp_thirdparty_tp_gen_nowarn INTERFACE_COMPILE_OPTIONS)
  if(MSVC OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    list(FIND _privOpts "/W0" _wIdx)
  else()
    list(FIND _privOpts "-w" _wIdx)
  endif()
  if(_wIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Strict warning suppression flag applied to managed target's PRIVATE COMPILE_OPTIONS")
  else()
    gpbt_assertFail("Strict warning suppression flag missing from COMPILE_OPTIONS: ${_privOpts}")
  endif()
  if(NOT _ifaceOpts)
    gpbt_assertSuccess("Strict warning suppression flag did not leak into INTERFACE_COMPILE_OPTIONS")
  else()
    gpbt_assertFail("Strict warning suppression flag leaked into INTERFACE_COMPILE_OPTIONS: ${_ifaceOpts}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Thirdparty: wrapping upstream target preserves transitive properties without duplicate compilation")
  gpbt_startBuildTool()
  add_library(gpbt_mock_upstream INTERFACE)
  target_compile_definitions(gpbt_mock_upstream INTERFACE UPSTREAM_DEF=99)

  gpStartThirdparty("tp_wrap_upstream" VERSION "1.0.0")
    gpThirdpartySetCompileDefinitions(EXTRA_WRAP_DEF=1)
  gpEndThirdparty()

  gpbt_wrapUpstreamThirdpartyTarget("tp_wrap_upstream" "tp_wrap_upstream" "gpbt_mock_upstream" "${_gpbt_tp_fixture_dir}")

  if(TARGET gp::thirdparty::tp_wrap_upstream)
    gpbt_assertSuccess("Wrapped alias target gp::thirdparty::tp_wrap_upstream exists")
  else()
    gpbt_assertFail("Wrapped alias target gp::thirdparty::tp_wrap_upstream was not created")
  endif()

  get_target_property(_wrapType gp_thirdparty_tp_wrap_upstream TYPE)
  gpbt_assertEqual("${_wrapType}" "INTERFACE_LIBRARY" "Wrapped upstream target should be an INTERFACE target")

  get_target_property(_wrapLinks gp_thirdparty_tp_wrap_upstream INTERFACE_LINK_LIBRARIES)
  list(FIND _wrapLinks "gpbt_mock_upstream" _linkIdx)
  if(_linkIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Wrapped target links to upstream target gpbt_mock_upstream")
  else()
    gpbt_assertFail("Wrapped target missing link to gpbt_mock_upstream: ${_wrapLinks}")
  endif()

  get_target_property(_wrapDefs gp_thirdparty_tp_wrap_upstream INTERFACE_COMPILE_DEFINITIONS)
  list(FIND _wrapDefs "EXTRA_WRAP_DEF=1" _extraDefIdx)
  if(_extraDefIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Extra compile definitions applied to wrapped upstream target")
  else()
    gpbt_assertFail("Extra compile definitions missing on wrapped target: ${_wrapDefs}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()
