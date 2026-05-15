# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/tests/asserts)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/api/dependencies)
include(gp-build-tool/targets/default)

# Dependency Management Tests

gpbt_startTestSection("Dependencies: PUBLIC dependency is stored")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC core)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("consumer" _targetPublicDependencies _pubDeps)
  list(FIND _pubDeps "core" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("PUBLIC dependency 'core' found in _targetPublicDependencies")
  else()
    gpbt_assertFail("'core' NOT found in public deps: ${_pubDeps}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: PRIVATE dependency is stored")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PRIVATE impl)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("consumer" _targetPrivateDependencies _privDeps)
  list(FIND _privDeps "impl" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("PRIVATE dependency 'impl' found in _targetPrivateDependencies")
  else()
    gpbt_assertFail("'impl' NOT found in private deps: ${_privDeps}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: INTERNAL dependency is stored")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(INTERNAL shared_internal)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("consumer" _targetInternalDependencies _intDeps)
  list(FIND _intDeps "shared_internal" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("INTERNAL dependency 'shared_internal' stored correctly")
  else()
    gpbt_assertFail("'shared_internal' NOT found in internal deps: ${_intDeps}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: DYNAMIC dependency is stored")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(DYNAMIC runtime_plugin)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("consumer" _targetDynamicDependencies _dynDeps)
  list(FIND _dynDeps "runtime_plugin" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("DYNAMIC dependency 'runtime_plugin' stored correctly")
  else()
    gpbt_assertFail("'runtime_plugin' NOT found in dynamic deps: ${_dynDeps}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: duplicate dependency is skipped")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC core)
  gpbt_addDependency(PUBLIC core)  # duplicate
  gpbt_endTarget()

  gpbt_testGetTargetProperty("consumer" _targetPublicDependencies _pubDeps)
  list(LENGTH _pubDeps _count)
  gpbt_assertEqual("${_count}" "1" "Duplicate dependency should not be added twice")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: multiple dependencies accumulate")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "richmodule" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC  core)
  gpbt_addDependency(PUBLIC  math)
  gpbt_addDependency(PRIVATE logging)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("richmodule" _targetPublicDependencies  _pubDeps)
  gpbt_testGetTargetProperty("richmodule" _targetPrivateDependencies _privDeps)
  list(LENGTH _pubDeps  _pubCount)
  list(LENGTH _privDeps _privCount)
  gpbt_assertEqual("${_pubCount}"  "2" "Two PUBLIC dependencies expected")
  gpbt_assertEqual("${_privCount}" "1" "One PRIVATE dependency expected")

  list(FIND _pubDeps "core" _coreIdx)
  list(FIND _pubDeps "math" _mathIdx)
  if(_coreIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("'core' found in PUBLIC deps")
  else()
    gpbt_assertFail("'core' missing from PUBLIC deps: ${_pubDeps}")
  endif()
  if(_mathIdx GREATER_EQUAL 0)
    gpbt_assertSuccess("'math' found in PUBLIC deps")
  else()
    gpbt_assertFail("'math' missing from PUBLIC deps: ${_pubDeps}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Dependencies: adding to different visibility buckets does not cross-contaminate")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "clean" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC  pubdep)
  gpbt_addDependency(PRIVATE privdep)
  gpbt_endTarget()

  gpbt_testGetTargetProperty("clean" _targetPublicDependencies  _pubDeps)
  gpbt_testGetTargetProperty("clean" _targetPrivateDependencies _privDeps)

  list(FIND _pubDeps  "privdep" _pInPub)
  list(FIND _privDeps "pubdep"  _uInPriv)
  if(_pInPub LESS 0)
    gpbt_assertSuccess("PRIVATE dep not contaminating PUBLIC bucket")
  else()
    gpbt_assertFail("PRIVATE 'privdep' was incorrectly found in PUBLIC deps")
  endif()
  if(_uInPriv LESS 0)
    gpbt_assertSuccess("PUBLIC dep not contaminating PRIVATE bucket")
  else()
    gpbt_assertFail("PUBLIC 'pubdep' was incorrectly found in PRIVATE deps")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()
