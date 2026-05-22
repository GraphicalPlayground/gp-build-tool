// Copyright (c) - Graphical Playground. All rights reserved.
// For more information, see https://graphical-playground/legal
// mailto:support AT graphical-playground DOT com

// Demonstrates how to write GoogleTest tests for a GPBT module.
// Replace these placeholder tests with assertions against the module's public API.
//
// This file is auto-discovered because it lives in the tests/ subdirectory next to
// the module's CMakeLists.txt, which calls gpEnableTests().
//
// Build and run:
//   cmake -S . -B build -DGPBT_TEST_FRAMEWORK=GOOGLETEST
//   cmake --build build
//   ctest --test-dir build --output-on-failure

#include <gtest/gtest.h>

// ---------------------------------------------------------------------------
// Placeholder suite, replace with real tests against <Public.hpp>.
// ---------------------------------------------------------------------------

TEST(RuntimeCoreTest, SanityCheck) {
    EXPECT_TRUE(true);
}

TEST(RuntimeCoreTest, BasicArithmetic) {
    EXPECT_EQ(1 + 1, 2);
    EXPECT_NE(0, 1);
    EXPECT_LT(0, 1);
}

TEST(RuntimeCoreTest, StringNonEmpty) {
    const char* name = "gp-runtime-core";
    EXPECT_STRNE(name, "");
    EXPECT_EQ(std::string(name).find("gp"), 0u);
}
