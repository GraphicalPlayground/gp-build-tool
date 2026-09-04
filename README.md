![Graphical Playground - Engine](https://github.com/GraphicalPlayground/.github/blob/main/assets/banners/gp-build-tool.svg)

[![Explore the Platform](https://github.com/GraphicalPlayground/.github/blob/main/assets/cta/cta-explore-platform.svg)](https://graphical-playground.com)
[![Read the Handbook](https://github.com/GraphicalPlayground/.github/blob/main/assets/cta/cta-read-handbook.svg)](https://handbook.graphical-playground.com)
[![Documentation](https://github.com/GraphicalPlayground/.github/blob/main/assets/cta/cta-documentation.svg)](https://docs.graphical-playground.com)
[![Learn about Licensing](https://github.com/GraphicalPlayground/.github/blob/main/assets/cta/cta-learn-licensing.svg)](https://graphical-playground.com/licensing)

# [@GraphicalPlayground](https://github.com/GraphicalPlayground)/gp-build-tool

🌎 Read this in: [English](README.md) | [Español](translations/es/README.md) | [Français](translations/fr/README.md) | [简体中文](translations/zh-cn/README.md)

<!-- gp-source-of-truth:custom:start -->
**Table of content**  
[Overview](#overview)  
┕ [The Problem](#the-problem)  
┕ [The Solution](#the-solution)  
┕ [Getting Started](#getting-started)  
┕ [Prerequisites](#prerequisites)  
[Documentation](#documentation)  
[Contributing](#contributing)  
┕ [Code of Conduct](#code-of-conduct)  
┕ [Security](#security)  
┕ [License](#license)  
┕ [Donations](#donations)  

## Overview

`gp-build-tool` is a cmake-based build system designed to simplify the process of building and
running the [Graphical Playground Engine](https://github.com/GraphicalPlayground/gp-engine)
and its surrounding ecosystem.

### The Problem

Modern C++ graphics engines are complex. They require managing dozens of internal modules,
third-party libraries, and platform-specific graphics APIs (Vulkan, D3D12, Metal). Traditional
CMake setups often become tangled, brittle, and difficult to read. Furthermore, a standard CMake
setup parses files top-to-bottom; if Module A depends on Module B, but B hasn't been scanned by
the system yet, the configuration fails.

### The Solution

GPBT abstracts away the boilerplate of raw CMake, allowing developers and students to focus on
writing high-performance graphics code instead of wrestling with build scripts. It provides a
clean, macro-driven API that lets you state what a module needs rather than how to build it.

### Getting Started

To start using the Graphical Playground Build Tool in your project, the recommended approach is to
add it as a Git submodule and include it in your root CMake configuration.

1. Add the submodule to your project:

```bash
git submodule add https://github.com/GraphicalPlayground/gp-build-tool.git thirdparty/gp-build-tool
git submodule update --init --recursive
```

2. Include GPBT in your `CMakeLists.txt`:

Once included, you can immediately start using the declarative API to define your engine targets,
modules, and executables without worrying about build order.

```cmake
# Include the GPBT layer
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/gp-build-tool")
include(gp-build-tool)

# Define your first module
gpStartModule(my_module)
  # GPBT automatically discovers your public/ private/ and internal/ sources
  gpAddDependency(PUBLIC core)
  gpTargetSetTestsEnabled(TRUE)
gpEndModule()
```

3. Generate and Build:

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

### Prerequisites

Since `gp-build-tool` orchestrates the compilation of modern, high-performance C++ code across
multiple platforms, ensure your development environment meets the following requirements:

- **CMake**: Version 3.28+ or newer.
- **C++23 Compatible Compiler**:
  - MSVC 19.38+ (Windows)
  - Clang 16+ (Linux/macOS/Windows)
  - GCC 13+ (Linux)
- **Ninja Build System**: Highly recommended for optimal build throughput, especially when utilizing
  GPBT's Unity Build features.
- **Git**: For fetching the repository and managing third-party submodules.

## Documentation

Comprehensive documentation for `gp-build-tool` is hosted on our main documentation portal. Whether you
are building your first triangle or writing a custom features, our guides are designed to support your
experimentation.

- [**Main Documentation Portal**](https://docs.graphical-playground.com)
- [**Build Tool Guide**](https://docs.graphical-playground.com/docs/engine/build-tool)
- [**Engine Introduction**](https://docs.graphical-playground.com/docs/engine/intro)
- [**API Introduction**](https://docs.graphical-playground.com/docs/api/intro)
<!-- gp-source-of-truth:custom:end -->

## Contributing

We welcome contributions from everybody! Whether you are fixing a bug, implementing a new features,
or improving our documentation, your help is appreciated. Please see our full
[CONTRIBUTING.md](./CONTRIBUTING.md) guide for detailed information on our standards and the pull
request review process.

### Code of Conduct

To ensure a welcoming, collaborative, and inclusive environment for everyone learning and
building within the Graphical Playground ecosystem, all contributors and participants are
expected to adhere to our [Code of Conduct](./CODE_OF_CONDUCT.md). Please review it before engaging
in community discussions or submitting code.

### Security

If you discover a security vulnerability within `gp-build-tool`, please do not report
it by opening a public issue. Instead, refer to our [Security Policy](./SECURITY.md) for
instructions on how to securely disclose the vulnerability to the maintainers.

### License

`gp-build-tool` is open-source software. Please see the [LICENSE.md](./LICENSE.md) file in the root
directory for full terms regarding modification, distribution, and use in your own projects.

### Donations

If you find `gp-build-tool` helpful for your learning, academic research, or game development journey,
please consider supporting the project. Maintaining a modern C++ graphics engine takes
significant time and resources!

You can sponsor the Graphical Playground project through the following links:

- [**Buy Me A Coffee**](https://www.buymeacoffee.com/GraphicalPlayground)
- [**GitHub Sponsors**](https://github.com/sponsors/GraphicalPlayground)
- [**Open Collective**](https://opencollective.com/graphical-playground)
- [**Thanks Dev**](https://thanks.dev/u/gh/GraphicalPlayground)
- [**Direct donation**](https://graphical-playground.com/donate)

You can see the full list of sponsors and supporters on our
[Sponsors Page](https://graphical-playground.com/sponsors) or in [DONORS.md](./DONORS.md).
Your support helps us continue to develop high-quality educational resources and maintain the engine
for the next generation of graphics engineers.

## Contact

If you have any questions, suggestions, or want to share your projects built with `gp-build-tool`, we
would love to hear from you! You can reach out to us through the following channels:

- **GitHub Discussions**: [Join the Conversation](https://github.com/orgs/GraphicalPlayground/discussions)
- **Email**:
  - Support: <mailto:support@graphical-playground.com>
  - Contact: <mailto:contact@graphical-playground.com>
  - Security: <mailto:security@graphical-playground.com>
  - Marketing: <mailto:marketing@graphical-playground.com>
  - Legal: <mailto:legal@graphical-playground.com>
  - Sponsor: <mailto:sponsor@graphical-playground.com>
  - Press: <mailto:press@graphical-playground.com>
  - Billing: <mailto:billing@graphical-playground.com>
  - Partnerships: <mailto:partnerships@graphical-playground.com>
  - Feedback: <mailto:feedback@graphical-playground.com>
  - Accessibility: <mailto:accessibility@graphical-playground.com>
  - Abuse: <mailto:abuse@graphical-playground.com>
  - Careers: <mailto:careers@graphical-playground.com>
  - Privacy: <mailto:privacy@graphical-playground.com>
- **Social Media**:
  - [**Discord**](https://discord.graphical-playground.com)
  - [**GitHub**](https://github.com/GraphicalPlayground)
  - [**LinkedIn**](https://linkedin.com/company/graphical-playground)

---
© 2026 Graphical Playground. Built for the next generation of graphics engineers.

![Graphical Playground](https://github.com/GraphicalPlayground/.github/blob/main/assets/misc/gplayd-footer.svg)
