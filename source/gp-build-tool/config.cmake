# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# Global configuration for the build tool and its tests.
set(GPBT_CURRENT_VERSION "0.4.0")

# General options
set(GPBT_ALLOWED_CONFIGS "Debug;Development;Profile;Shipping")

# Options of the unit tests for the build tool
option(GPBT_TESTS_ENABLED "Set to true to run build tool tests" FALSE)
option(GPBT_TESTS_FILTER_SECTION "If set, only run test sections that contain this string in their name" "")

# Specific options
option(GPBT_RUNNING_IN_CI "Set to true if the build tool is being run in a CI environment" FALSE)

# Logging
option(GPBT_LOG_PREFIX_ENABLED "Set to true to enable log prefix" FALSE)
option(GPBT_TREAT_WARNINGS_AS_FATAL "Set to true to treat warnings as fatal errors" FALSE)
option(GPBT_TREAT_ERRORS_AS_FATAL "Set to true to treat errors as fatal" FALSE)
option(GPBT_LOG_VERBOSE_ENABLED "Set to true to enable verbose logging" FALSE)
option(GPBT_LOG_BANNER_ENABLED "Set to true to enable log banner" TRUE)
option(GPBT_DUMP_TARGETS_PROPERTIES "Set to true to dump target properties after configuration" FALSE)

# Building options
option(GPBT_IS_MONOLITHIC "Set to true to build all targets in a single monolithic library" FALSE)

# Source discovery: set to FALSE in CI environments where filesystem polling is expensive.
option(GPBT_CONFIGURE_DEPENDS "Rerun CMake configure when globbed source files change" TRUE)

# Install export set name. All targets are added to this CMake export set.
# Change this to match your project's find_package() name.
set(GPBT_INSTALL_EXPORT_NAME "GPTargets" CACHE STRING "Name of the CMake install export set")

# Dependency graph export (Graphviz DOT format).
# Render with: dot -Tsvg <file> -o <file>.svg
option(GPBT_EXPORT_DEPENDENCY_GRAPH "Write a Graphviz DOT file of the target dependency graph after configuration" FALSE)
set(GPBT_DEPENDENCY_GRAPH_FILE "${CMAKE_BINARY_DIR}/gpbt_dependency_graph.dot" CACHE FILEPATH "Output path for the dependency graph DOT file")

# Thirdparty package management
set(GPBT_THIRDPARTY_MODE "AUTO" CACHE STRING "Thirdparty resolution mode: AUTO (binary-first with source fallback), SOURCE (always build from source), BINARY (prebuilt only)")
set_property(CACHE GPBT_THIRDPARTY_MODE PROPERTY STRINGS AUTO SOURCE BINARY)
option(GPBT_THIRDPARTY_UPDATES_DISCONNECTED "Skip network checks for already-fetched thirdparty packages (faster reconfigure)" ON)

# LLVM's libc++ is generally more modern and better supported than the older libstdc++ on Linux, especially when using Clang.
option(GPBT_USE_LIBCXX "Use LLVM's libc++ instead of system libstdc++ (Recommended for Clang on Linux)" OFF)

# Test framework integration
# NONE       - gpEnableTests() is a no-op; no framework is fetched.
# GOOGLETEST - GoogleTest 1.17.0 is fetched via the thirdparty system; test executables link GTest::gtest_main.
# CATCH2     - Catch2 3.15.0 is fetched via the thirdparty system; test executables link Catch2::Catch2WithMain.
# CUSTOM     - Use a CMake target you provide; set GPBT_TEST_FRAMEWORK_CUSTOM_TARGET to its name.
#
# User override: declaring gpStartThirdparty("googletest") or gpStartThirdparty("catch2") before
# gpEndBuildTool() makes GPBT skip the built-in version and use your declared package instead.
# GPBT_TEST_FRAMEWORK default is intentionally set to NONE here so that projects
# that do not call gpApplyGraphicalPlaygroundDefaultPolicy() stay opt-out.
# gpApplyGraphicalPlaygroundDefaultPolicy() promotes it to GOOGLETEST when the
# user has not provided an explicit -DGPBT_TEST_FRAMEWORK=<value> override.
if(NOT DEFINED CACHE{GPBT_TEST_FRAMEWORK})
  set(GPBT_TEST_FRAMEWORK "NONE" CACHE STRING "Test framework used by gpEnableTests(): NONE | GOOGLETEST | CATCH2 | CUSTOM")
endif()
set_property(CACHE GPBT_TEST_FRAMEWORK PROPERTY STRINGS NONE GOOGLETEST CATCH2 CUSTOM)
set(GPBT_TEST_FRAMEWORK_CUSTOM_TARGET "" CACHE STRING "CMake target to link test executables against when GPBT_TEST_FRAMEWORK=CUSTOM")
