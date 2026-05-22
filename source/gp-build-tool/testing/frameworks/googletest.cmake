# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# @brief Register the built-in GoogleTest 1.17.0 source package into the thirdparty system.
# @remarks Called by gpbt_initTestingSystem() when GPBT_TEST_FRAMEWORK is GOOGLETEST and the
#          project has not pre-declared its own "googletest" package.
#          The resulting alias is gp::thirdparty::googletest and links GTest::gtest_main,
#          which supplies both the testing macros and a default main() so test executables do
#          not need to provide their own entry point.
#          Hashes computed from:
#            https://github.com/google/googletest/archive/refs/tags/v1.17.0.tar.gz
function(gpbt_registerGoogleTestFramework)
  gpbt_log(INFO "Testing: registering built-in GoogleTest 1.17.0")

  gpbt_startThirdparty("googletest" VERSION "1.17.0")
    gpbt_thirdpartySource(
      URL    "https://github.com/google/googletest/archive/refs/tags/v1.17.0.tar.gz"
      HASH   "SHA256=65fab701d9829d38cb77c14acdc431d2108bfdbf8979e40eb8ae567edf10b27c"
      TARGET "GTest::gtest_main"
    )
    gpbt_thirdpartySetCMakeArgs(
      # Force GoogleTest to use the same MSVC runtime as the rest of the project.
      # Without this, MSVC will emit LNK2038 "mismatch detected for RuntimeLibrary".
      gtest_force_shared_crt=ON
      # Do not install GoogleTest headers globally, it is an internal tool dependency.
      INSTALL_GTEST=OFF
      # GMock is not wired into the default test target; disable it to reduce build time.
      BUILD_GMOCK=OFF
    )
    # GoogleTest 1.17.0 emits -Wcharacter-conversion under strict settings (char8_t implicit
    # conversion in gtest-printers.h:528).  Strip -Werror/-WX for the source build so the
    # warning does not become a hard error without affecting the rest of the project.
    gpbt_thirdpartyDisableStrictWarnings()
  gpbt_endThirdparty()
endfunction()
