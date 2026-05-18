---
sidebar_position: 3
title: Testing
description: How to run the build tool's own internal test suite and how per-target test infrastructure works.
tags:
  - testing
  - cmake
  - ci
---

## Build tool internal tests

GPBT ships with its own test suite that validates core behaviours such as the property scoping system, topological sorting, and string utilities. These tests are separate from your project's tests and are primarily useful when contributing to the build tool itself.

To run the internal tests, configure with `GPBT_TESTS_ENABLED`:

```bash
cmake -S . -B build -DGPBT_TESTS_ENABLED=ON
cmake --build build
```

When `GPBT_TESTS_ENABLED` is `ON`, the example targets are skipped and only the internal test targets are built.

### Filtering test sections

To run only a subset of tests, pass a filter string:

```bash
cmake -S . -B build -DGPBT_TESTS_ENABLED=ON -DGPBT_TESTS_FILTER_SECTION="sort"
```

Only test sections whose name contains the filter string will execute.

## Per-target test infrastructure

GPBT reserves the `gpEnableTests()` macro for per-target test support. When called inside a target definition, it signals that the target has an associated test suite in a `tests/` subdirectory.

```cmake
gpStartModule("core")
  gpEnableTests()
gpEndModule()
```

:::note
Per-target test infrastructure is reserved for a future release. Calling `gpEnableTests()` currently records the intent but does not generate test targets. The same applies to `gpEnableBenchmarks()` and `gpEnableExamples()`.
:::

## CI considerations

When running in CI, set `GPBT_RUNNING_IN_CI=ON` and `GPBT_TREAT_WARNINGS_AS_FATAL=ON`:

```bash
cmake -S . -B build \
  -DGPBT_RUNNING_IN_CI=ON \
  -DGPBT_TREAT_WARNINGS_AS_FATAL=ON \
  -DGPBT_CONFIGURE_DEPENDS=OFF
```

`GPBT_CONFIGURE_DEPENDS=OFF` disables filesystem polling for source file changes, which reduces overhead on CI agents where the source tree does not change between configure and build steps.
