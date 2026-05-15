# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/tests/asserts)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/api/dependencies)
include(gp-build-tool/targets/utilities/sort)
include(gp-build-tool/targets/default)

# ---------------------------------------------------------------------------
# Topological Sort Tests
# ---------------------------------------------------------------------------

gpbt_startTestSection("Sort: linear chain A -> B -> C is sorted C, B, A")
  # Register three targets: C has no deps, B depends on C, A depends on B
  gpbt_startBuildTool()

  gpbt_startTarget("module" "chain_c" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_startTarget("module" "chain_b" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC chain_c)
  gpbt_endTarget()

  gpbt_startTarget("module" "chain_a" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC chain_b)
  gpbt_endTarget()

  gpbt_sortTargets(_sorted)

  list(GET _sorted 0 _first)
  list(GET _sorted 1 _second)
  list(GET _sorted 2 _third)
  gpbt_assertEqual("${_first}"  "chain_c" "chain_c (no deps) should be first")
  gpbt_assertEqual("${_second}" "chain_b" "chain_b (depends on chain_c) should be second")
  gpbt_assertEqual("${_third}"  "chain_a" "chain_a (depends on chain_b) should be third")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Sort: diamond dependency A -> B, A -> C, B -> D, C -> D")
  # D has no deps; B and C both depend on D; A depends on both B and C
  # Valid sort orders: D, B, C, A or D, C, B, A
  gpbt_startBuildTool()

  gpbt_startTarget("module" "diamond_d" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_startTarget("module" "diamond_b" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC diamond_d)
  gpbt_endTarget()

  gpbt_startTarget("module" "diamond_c" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC diamond_d)
  gpbt_endTarget()

  gpbt_startTarget("module" "diamond_a" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC diamond_b)
  gpbt_addDependency(PUBLIC diamond_c)
  gpbt_endTarget()

  gpbt_sortTargets(_sorted)
  list(LENGTH _sorted _count)
  gpbt_assertEqual("${_count}" "4" "All 4 targets should appear in sorted list")

  # diamond_d must be before diamond_b and diamond_c
  list(FIND _sorted "diamond_d" _dIdx)
  list(FIND _sorted "diamond_b" _bIdx)
  list(FIND _sorted "diamond_c" _cIdx)
  list(FIND _sorted "diamond_a" _aIdx)

  if(_dIdx LESS _bIdx)
    gpbt_assertSuccess("diamond_d comes before diamond_b")
  else()
    gpbt_assertFail("diamond_d (${_dIdx}) should come before diamond_b (${_bIdx})")
  endif()
  if(_dIdx LESS _cIdx)
    gpbt_assertSuccess("diamond_d comes before diamond_c")
  else()
    gpbt_assertFail("diamond_d (${_dIdx}) should come before diamond_c (${_cIdx})")
  endif()
  if(_bIdx LESS _aIdx AND _cIdx LESS _aIdx)
    gpbt_assertSuccess("diamond_b and diamond_c both come before diamond_a")
  else()
    gpbt_assertFail("diamond_a should come last (b=${_bIdx}, c=${_cIdx}, a=${_aIdx})")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Sort: target with no dependencies is placed before dependents")
  gpbt_startBuildTool()

  gpbt_startTarget("module" "nodeps"   "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_startTarget("module" "hasdeps"  "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC nodeps)
  gpbt_endTarget()

  gpbt_sortTargets(_sorted)
  list(FIND _sorted "nodeps"  _nIdx)
  list(FIND _sorted "hasdeps" _hIdx)
  if(_nIdx LESS _hIdx)
    gpbt_assertSuccess("'nodeps' correctly placed before 'hasdeps'")
  else()
    gpbt_assertFail("'hasdeps' should come after 'nodeps'")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Sort: external (non-registered) dependencies do not block sort")
  # A module that depends on an external lib (e.g. "SDL2") should still be sorted
  gpbt_startBuildTool()

  gpbt_startTarget("module" "ext_consumer" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(PUBLIC SDL2)   # external, not a registered GP target
  gpbt_endTarget()

  gpbt_sortTargets(_sorted)
  list(LENGTH _sorted _count)
  gpbt_assertEqual("${_count}" "1" "Target with external-only deps should sort successfully")
  list(GET _sorted 0 _first)
  gpbt_assertEqual("${_first}" "ext_consumer" "The target itself should be in the sorted list")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Sort: DYNAMIC dependencies affect order")
  # DYNAMIC deps participate in the sort to ensure the dynamic target is built first
  gpbt_startBuildTool()

  gpbt_startTarget("module" "dyn_plugin" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_startTarget("module" "dyn_host" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_addDependency(DYNAMIC dyn_plugin)
  gpbt_endTarget()

  gpbt_sortTargets(_sorted)
  list(FIND _sorted "dyn_plugin" _pIdx)
  list(FIND _sorted "dyn_host"   _hIdx)
  if(_pIdx LESS _hIdx)
    gpbt_assertSuccess("dyn_plugin (DYNAMIC dep) sorted before dyn_host")
  else()
    gpbt_assertFail("DYNAMIC dep ordering failed: plugin=${_pIdx}, host=${_hIdx}")
  endif()

  gpbt_testResetBuildTool()
gpbt_endTestSection()
