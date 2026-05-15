# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/tests/asserts)

gpbt_setupTestSuite()

# Utility layer tests (no build tool lifecycle required)
include(gp-build-tool/tests/utilities/strings)
include(gp-build-tool/tests/utilities/properties)

# Target API tests (require build tool lifecycle simulation)
include(gp-build-tool/tests/targets/registration)
include(gp-build-tool/tests/targets/dependencies)
include(gp-build-tool/tests/targets/options)
include(gp-build-tool/tests/targets/sort)

gpbt_dumpTestStats()
