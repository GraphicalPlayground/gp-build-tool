# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/config)
include(gp-build-tool/utilities/logger)

include(gp-build-tool/defaulter)

gpbt_getProperty(GPBT_HAS_LOGGED_BANNER hasLoggedBanner)
if(GPBT_LOG_BANNER_ENABLED AND NOT hasLoggedBanner)
  gpbt_logBanner()
  gpbt_setProperty(GPBT_HAS_LOGGED_BANNER TRUE)
endif()

if(GPBT_TESTS_ENABLED)
  # Load the full API so target API tests can simulate the build tool lifecycle.
  include(gp-build-tool/api)
  include(gp-build-tool/tests/all)
  return()
endif()

include(gp-build-tool/api)
