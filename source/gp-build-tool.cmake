# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/config)
include(gp-build-tool/utilities/logger)

if(GPBT_LOG_BANNER_ENABLED)
  gpbt_logBanner()
endif()

if(GPBT_TESTS_ENABLED)
  include(gp-build-tool/tests/all)
  return()
endif()
