# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/config)
include(gp-build-tool/utilities/logger)

gpbt_getProperty(GPBT_HAS_LOGGED_BANNER hasLoggedBanner)
if(GPBT_LOG_BANNER_ENABLED AND NOT hasLoggedBanner)
  gpbt_logBanner()
  gpbt_setProperty(GPBT_HAS_LOGGED_BANNER TRUE)
endif()

if(GPBT_TESTS_ENABLED)
  include(gp-build-tool/tests/all)
  return()
endif()

include(gp-build-tool/api)
