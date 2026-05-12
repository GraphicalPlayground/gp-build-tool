# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

# Global configuration for the build tool and its tests.
set(GPBT_CURRENT_VERSION "0.4.0")

# Options of the unit tests for the build tool
option(GPBT_TESTS_ENABLED "Set to true to run build tool tests" FALSE)
option(GPBT_TESTS_FILTER_SECTION "If set, only run test sections that contain this string in their name" "")

# Specific options
option(GPBT_IS_RUNNED_IN_CI "Set to true if the build tool is being run in a CI environment" FALSE)

# Logging
option(GPBT_LOG_PREFIX_ENABLED "Set to true to enable log prefix" FALSE)
option(GPBT_TREAT_WARNINGS_AS_FATAL "Set to true to treat warnings as fatal errors" FALSE)
option(GPBT_TREAT_ERRORS_AS_FATAL "Set to true to treat errors as fatal" FALSE)
option(GPBT_LOG_VERBOSE_ENABLED "Set to true to enable verbose logging" FALSE)
option(GPBT_LOG_BANNER_ENABLED "Set to true to enable log banner" TRUE)
option(GPBT_DUMP_TARGETS_PROPERTIES "Set to true to dump target properties after configuration" FALSE)
