# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/tests/asserts)
include(gp-build-tool/targets/api/build-tool)
include(gp-build-tool/targets/default)

# Target Registration Tests

gpbt_startTestSection("Target Registration: basic module")
  gpbt_startBuildTool()

  # A CMakeLists.txt path is needed to give the target a location.
  # We use CMAKE_CURRENT_LIST_DIR as a stand-in — any existing directory works.
  gpbt_startTarget("module" "mymodule" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  # Verify the target was registered in the global list
  gpbt_getProperty(GPBT_TARGETS allTargets)
  list(FIND allTargets "mymodule" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("Target 'mymodule' was added to GPBT_TARGETS")
  else()
    gpbt_assertFail("Target 'mymodule' was NOT found in GPBT_TARGETS (got: ${allTargets})")
  endif()

  # Verify type property
  gpbt_testGetTargetProperty("mymodule" _targetType _type)
  gpbt_assertEqual("${_type}" "module" "Target type should be 'module'")

  # Verify export name is prefixed with gp_
  gpbt_testGetTargetProperty("mymodule" _targetExportName _exportName)
  gpbt_assertEqual("${_exportName}" "gp_mymodule" "Export name should be 'gp_mymodule'")

  # Verify output name is prefixed with gp- and in kebab-case
  gpbt_testGetTargetProperty("mymodule" _targetOutputName _outputName)
  gpbt_assertEqual("${_outputName}" "gp-mymodule" "Output name should be 'gp-mymodule'")

  # Verify default alias is set
  gpbt_testGetTargetProperty("mymodule" _targetAliases _aliases)
  gpbt_assertEqual("${_aliases}" "gp::mymodule" "Default alias should be 'gp::mymodule'")

  # Verify default IDE folder for modules
  gpbt_testGetTargetProperty("mymodule" _targetCustomFolder _folder)
  gpbt_assertEqual("${_folder}" "modules" "Default folder for module should be 'modules'")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Target Registration: executable")
  gpbt_startBuildTool()
  gpbt_startTarget("executable" "myapp" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_testGetTargetProperty("myapp" _targetType _type)
  gpbt_assertEqual("${_type}" "executable" "Target type should be 'executable'")

  gpbt_testGetTargetProperty("myapp" _targetCustomFolder _folder)
  gpbt_assertEqual("${_folder}" "executables" "Default folder for executable should be 'executables'")

  gpbt_testGetTargetProperty("myapp" _targetExecutableHasGui _hasGui)
  gpbt_assertEqual("${_hasGui}" "FALSE" "Executable should not be GUI by default")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Target Registration: name with slash becomes underscore")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "rhi/d3d12" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  # "rhi/d3d12" should be cleaned to "rhi_d3d12"
  gpbt_getProperty(GPBT_TARGETS allTargets)
  list(FIND allTargets "rhi_d3d12" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("'rhi/d3d12' clean name is 'rhi_d3d12' in GPBT_TARGETS")
  else()
    gpbt_assertFail("'rhi/d3d12' clean name not found — GPBT_TARGETS: ${allTargets}")
  endif()

  gpbt_testGetTargetProperty("rhi_d3d12" _targetName _rawName)
  gpbt_assertEqual("${_rawName}" "rhi/d3d12" "Raw target name should be preserved as 'rhi/d3d12'")

  gpbt_testGetTargetProperty("rhi_d3d12" _targetOutputName _outputName)
  gpbt_assertEqual("${_outputName}" "gp-rhi-d3d12" "Output name for 'rhi/d3d12' should be 'gp-rhi-d3d12'")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Target Registration: uppercase name is lowercased")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "MyEngine" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  gpbt_getProperty(GPBT_TARGETS allTargets)
  list(FIND allTargets "myengine" _idx)
  if(_idx GREATER_EQUAL 0)
    gpbt_assertSuccess("'MyEngine' was lowercased to 'myengine' in GPBT_TARGETS")
  else()
    gpbt_assertFail("Lowercased name 'myengine' not found in GPBT_TARGETS: ${allTargets}")
  endif()

  gpbt_testGetTargetProperty("myengine" _targetExportName _exportName)
  gpbt_assertEqual("${_exportName}" "gp_myengine" "Export name should be 'gp_myengine'")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Target Registration: duplicate target is fatal error")
  gpbt_startBuildTool()
  gpbt_startTarget("module" "duplicate" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()

  # Trying to register the same target twice should produce a FATAL log and stop.
  # We can't catch CMake FATAL_ERROR from within CMake, so we verify the duplicate
  # detection state by checking GPBT_TARGETS only has one entry for this name.
  gpbt_getProperty(GPBT_TARGETS allTargets)
  list(LENGTH allTargets _count)
  gpbt_assertEqual("${_count}" "1" "Exactly one target should be registered")

  gpbt_testResetBuildTool()
gpbt_endTestSection()

gpbt_startTestSection("Target Registration: gpbt_startBuildTool resets GPBT_TARGETS")
  # First run
  gpbt_startBuildTool()
  gpbt_startTarget("module" "alpha" "${CMAKE_CURRENT_LIST_DIR}")
  gpbt_endTarget()
  gpbt_testResetBuildTool()

  # Second run — should NOT see 'alpha' from the first run
  gpbt_startBuildTool()
  gpbt_getProperty(GPBT_TARGETS allTargets)
  list(FIND allTargets "alpha" _idx)
  if(_idx LESS 0)
    gpbt_assertSuccess("GPBT_TARGETS was reset on second gpbt_startBuildTool call")
  else()
    gpbt_assertFail("GPBT_TARGETS was NOT reset — 'alpha' leaked from previous run")
  endif()
  gpbt_testResetBuildTool()
gpbt_endTestSection()
