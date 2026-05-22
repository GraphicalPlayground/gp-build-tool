# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# @brief Register the built-in Catch2 3.15.0 source package into the thirdparty system.
# @remarks Called by gpbt_initTestingSystem() when GPBT_TEST_FRAMEWORK is CATCH2 and the
#          project has not pre-declared its own "catch2" package.
#          The resulting alias is gp::thirdparty::catch2 and links Catch2::Catch2WithMain,
#          which supplies both the testing macros and a default main() so test executables
#          do not need to provide their own entry point.
#          Hashes computed from:
#            https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.0.tar.gz
function(gpbt_registerCatch2Framework)
  gpbt_log(INFO "Testing: registering built-in Catch2 3.15.0")

  gpbt_startThirdparty("catch2" VERSION "3.15.0")
    gpbt_thirdpartySource(
      URL    "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.0.tar.gz"
      HASH   "SHA256=9650c55e497759cc39b977e45524bc8acb15256061c112080916ab6cb0b1ea66"
      TARGET "Catch2::Catch2WithMain"
    )
    gpbt_thirdpartySetCMakeArgs(
      # Suppress documentation and extras installation, internal tool dependency only.
      CATCH_INSTALL_DOCS=OFF
      CATCH_INSTALL_EXTRAS=OFF
      # Catch2 ships its own test suite and examples; disable them to keep builds lean.
      CATCH_BUILD_EXAMPLES=OFF
      CATCH_BUILD_TESTING=OFF
    )
    # Suppress -Werror / /WX for the Catch2 source build.
    # Catch2's headers and generated sources can trigger warnings under strict project flags
    # (e.g. -Wsign-conversion, -Wold-style-cast on older compilers).
    gpbt_thirdpartyDisableStrictWarnings()
  gpbt_endThirdparty()
endfunction()
