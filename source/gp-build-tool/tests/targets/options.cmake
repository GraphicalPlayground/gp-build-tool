# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/tests/asserts)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/api/compile-definitions)
include(gp-build-tool/targets/api/compile-options)
include(gp-build-tool/targets/api/link-options)
include(gp-build-tool/targets/api/options)
include(gp-build-tool/targets/api/metadata)
include(gp-build-tool/targets/default)

# Per-Target Option Tests

gpbt_startTestSection("Options: gpSetHeaderOnly sets _targetIsHeaderOnly")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "headerlib" "${CMAKE_CURRENT_LIST_DIR}")
  gpSetHeaderOnly()
  gpbt_endTarget()

  gpbt_testGetTargetProperty("headerlib" _targetIsHeaderOnly _val)
  gpbt_assertEqual("${_val}" "TRUE" "gpSetHeaderOnly should set _targetIsHeaderOnly to TRUE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpEnableUnityBuild sets _targetEnableUnityBuild")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "bigmod" "${CMAKE_CURRENT_LIST_DIR}")
  gpEnableUnityBuild()
  gpbt_endTarget()

  gpbt_testGetTargetProperty("bigmod" _targetEnableUnityBuild _val)
  gpbt_assertEqual("${_val}" "TRUE" "gpEnableUnityBuild should set _targetEnableUnityBuild to TRUE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpDisableStrictWarnings sets _targetEnableStrictWarnings to FALSE")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "vendor" "${CMAKE_CURRENT_LIST_DIR}")
  gpDisableStrictWarnings()
  gpbt_endTarget()

  gpbt_testGetTargetProperty("vendor" _targetEnableStrictWarnings _val)
  gpbt_assertEqual("${_val}" "FALSE" "gpDisableStrictWarnings should set _targetEnableStrictWarnings to FALSE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: strict warnings are ON by default")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "strictmod" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("strictmod" _targetEnableStrictWarnings _val)
  gpbt_assertEqual("${_val}" "TRUE" "Strict warnings should be enabled by default")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpSetStatic sets _targetIsBuildShared to FALSE")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "staticlib" "${CMAKE_CURRENT_LIST_DIR}")
  gpSetStatic()
  gpbt_endTarget()

  gpbt_testGetTargetProperty("staticlib" _targetIsBuildShared _val)
  gpbt_assertEqual("${_val}" "FALSE" "gpSetStatic should set _targetIsBuildShared to FALSE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpSetShared sets _targetIsBuildShared to TRUE")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "sharedlib" "${CMAKE_CURRENT_LIST_DIR}")
  gpSetStatic()    # first force static
  gpSetShared()    # then override back to shared
  gpbt_endTarget()

  gpbt_testGetTargetProperty("sharedlib" _targetIsBuildShared _val)
  gpbt_assertEqual("${_val}" "TRUE" "gpSetShared should override to _targetIsBuildShared TRUE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpSetFolder overrides default IDE folder")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "engine_core" "${CMAKE_CURRENT_LIST_DIR}")
  gpSetFolder("engine/runtime")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("engine_core" _targetCustomFolder _val)
  gpbt_assertEqual("${_val}" "engine/runtime" "gpSetFolder should set _targetCustomFolder")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpAddAlias appends to _targetAliases")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "mylib" "${CMAKE_CURRENT_LIST_DIR}")
  gpAddAlias("mylib::v2")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("mylib" _targetAliases _aliases)
  list(FIND _aliases "mylib::v2" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("gpAddAlias 'mylib::v2' found in _targetAliases")
  else()
    gpbt_assertFail("'mylib::v2' NOT found in aliases: ${_aliases}")
  endif()

  # Default alias should still be there
  list(FIND _aliases "gp::mylib" _defIdx)
  if(_defIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("Default alias 'gp::mylib' still present after gpAddAlias")
  else()
    gpbt_assertFail("Default alias 'gp::mylib' was lost after gpAddAlias")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpSetGuiExecutable sets _targetExecutableHasGui")
  gpbt_startBuildTool()
  gpbt_startTarget("executable" "guiapp" "${CMAKE_CURRENT_LIST_DIR}")
  gpSetGuiExecutable()
  gpbt_endTarget()

  gpbt_testGetTargetProperty("guiapp" _targetExecutableHasGui _val)
  gpbt_assertEqual("${_val}" "TRUE" "gpSetGuiExecutable should set _targetExecutableHasGui to TRUE")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpAddCompileDefinition stores definitions by visibility")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "flagmod" "${CMAKE_CURRENT_LIST_DIR}")
  gpAddCompileDefinition(PUBLIC  "MY_PUBLIC_DEFINE=1")
  gpAddCompileDefinition(PRIVATE "MY_PRIVATE_DEFINE=1")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("flagmod" _targetPublicCompileDefinitions  _pubDefs)
  gpbt_testGetTargetProperty("flagmod" _targetPrivateCompileDefinitions _privDefs)

  list(FIND _pubDefs  "MY_PUBLIC_DEFINE=1"  _pubIdx)
  list(FIND _privDefs "MY_PRIVATE_DEFINE=1" _privIdx)
  if(_pubIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("PUBLIC definition stored in _targetPublicCompileDefinitions")
  else()
    gpbt_assertFail("PUBLIC definition missing: ${_pubDefs}")
  endif()
  if(_privIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("PRIVATE definition stored in _targetPrivateCompileDefinitions")
  else()
    gpbt_assertFail("PRIVATE definition missing: ${_privDefs}")
  endif()

  # Verify no cross-contamination
  list(FIND _privDefs "MY_PUBLIC_DEFINE=1"  _cross1)
  list(FIND _pubDefs  "MY_PRIVATE_DEFINE=1" _cross2)
  if(_cross1 LESS 0)
    gpbt_assertSuccess("PUBLIC definition not leaked into PRIVATE bucket")
  else()
    gpbt_assertFail("PUBLIC definition incorrectly appeared in PRIVATE bucket")
  endif()
  if(_cross2 LESS 0)
    gpbt_assertSuccess("PRIVATE definition not leaked into PUBLIC bucket")
  else()
    gpbt_assertFail("PRIVATE definition incorrectly appeared in PUBLIC bucket")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpAddCompileOption stores flags by visibility")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "optmod" "${CMAKE_CURRENT_LIST_DIR}")
  gpAddCompileOption(PUBLIC  "-march=native")
  gpAddCompileOption(PRIVATE "-fno-rtti")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("optmod" _targetPublicCompileOptions  _pubOpts)
  gpbt_testGetTargetProperty("optmod" _targetPrivateCompileOptions _privOpts)

  list(FIND _pubOpts  "-march=native" _pubIdx)
  list(FIND _privOpts "-fno-rtti"     _privIdx)
  if(_pubIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("PUBLIC compile option '-march=native' stored correctly")
  else()
    gpbt_assertFail("'-march=native' missing from public options: ${_pubOpts}")
  endif()
  if(_privIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("PRIVATE compile option '-fno-rtti' stored correctly")
  else()
    gpbt_assertFail("'-fno-rtti' missing from private options: ${_privOpts}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Options: gpAddLinkOption stores linker flags")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "linkmod" "${CMAKE_CURRENT_LIST_DIR}")
  gpAddLinkOption(PRIVATE "-Wl,--no-undefined")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("linkmod" _targetPrivateLinkOptions _opts)
  list(FIND _opts "-Wl,--no-undefined" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("PRIVATE link option '-Wl,--no-undefined' stored correctly")
  else()
    gpbt_assertFail("Link option missing: ${_opts}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()
