# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# Select the test framework: NONE | GOOGLETEST | CATCH2 | CUSTOM
# Override on the command line: cmake -DGPBT_TEST_FRAMEWORK=CATCH2 ...
set(GPBT_TEST_FRAMEWORK "GOOGLETEST" CACHE STRING "")

gpStartBuildTool()
  gpBuildToolAutoScan(thirdparty source)
gpEndBuildTool()
