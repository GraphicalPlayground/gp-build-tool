# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/tests/asserts)
include(gp-build-tool/utilities/strings)

gpbt_startTestSection("Strings Check Case: UPPERCASE")
  gpbt_checkCase("UPPERCASE" "HELLO WORLD" result)
  gpbt_assertFalse("${result}" "Expected 'HELLO WORLD' to not be recognized as UPPERCASE")

  gpbt_checkCase("UPPERCASE" "HELLOWORLD" result)
  gpbt_assertTrue("${result}" "Expected 'HELLOWORLD' to be recognized as UPPERCASE")

  gpbt_checkCase("UPPERCASE" "HELLO123WORLD" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO123WORLD' to be recognized as UPPERCASE")

  gpbt_checkCase("UPPERCASE" "HelloWorld" result)
  gpbt_assertFalse("${result}" "Expected 'HelloWorld' to not be recognized as UPPERCASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: lowercase")
  gpbt_checkCase("lowercase" "hello world" result)
  gpbt_assertFalse("${result}" "Expected 'hello world' to not be recognized as lowercase")

  gpbt_checkCase("lowercase" "helloworld" result)
  gpbt_assertTrue("${result}" "Expected 'helloworld' to be recognized as lowercase")

  gpbt_checkCase("lowercase" "hello123world" result)
  gpbt_assertTrue("${result}" "Expected 'hello123world' to be recognized as lowercase")

  gpbt_checkCase("lowercase" "hello_world" result)
  gpbt_assertFalse("${result}" "Expected 'hello_world' to not be recognized as lowercase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: PascalCase")
  gpbt_checkCase("PascalCase" "HelloWorld" result)
  gpbt_assertTrue("${result}" "Expected 'HelloWorld' to be recognized as PascalCase")

  gpbt_checkCase("PascalCase" "Hello" result)
  gpbt_assertTrue("${result}" "Expected 'Hello' to be recognized as PascalCase")

  gpbt_checkCase("PascalCase" "PascalCase123" result)
  gpbt_assertTrue("${result}" "Expected 'PascalCase123' to be recognized as PascalCase")

  gpbt_checkCase("PascalCase" "helloWorld" result)
  gpbt_assertFalse("${result}" "Expected 'helloWorld' to not be recognized as PascalCase")

  gpbt_checkCase("PascalCase" "HELLO" result)
  gpbt_assertFalse("${result}" "Expected 'HELLO' to not be recognized as PascalCase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: camelCase")
  gpbt_checkCase("camelCase" "helloWorld" result)
  gpbt_assertTrue("${result}" "Expected 'helloWorld' to be recognized as camelCase")

  gpbt_checkCase("camelCase" "hello" result)
  gpbt_assertTrue("${result}" "Expected 'hello' to be recognized as camelCase")

  gpbt_checkCase("camelCase" "camelCase123" result)
  gpbt_assertTrue("${result}" "Expected 'camelCase123' to be recognized as camelCase")

  gpbt_checkCase("camelCase" "HelloWorld" result)
  gpbt_assertFalse("${result}" "Expected 'HelloWorld' to not be recognized as camelCase")

  gpbt_checkCase("camelCase" "hello_world" result)
  gpbt_assertFalse("${result}" "Expected 'hello_world' to not be recognized as camelCase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: snake_case")
  gpbt_checkCase("snake_case" "hello_world" result)
  gpbt_assertTrue("${result}" "Expected 'hello_world' to be recognized as snake_case")

  gpbt_checkCase("snake_case" "hello_world_123" result)
  gpbt_assertTrue("${result}" "Expected 'hello_world_123' to be recognized as snake_case")

  gpbt_checkCase("snake_case" "hello" result)
  gpbt_assertTrue("${result}" "Expected 'hello' to be recognized as snake_case")

  gpbt_checkCase("snake_case" "Hello_World" result)
  gpbt_assertFalse("${result}" "Expected 'Hello_World' to not be recognized as snake_case")

  gpbt_checkCase("snake_case" "hello__world" result)
  gpbt_assertFalse("${result}" "Expected 'hello__world' to not be recognized as snake_case")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: SNAKE_CASE")
  gpbt_checkCase("SNAKE_CASE" "HELLO_WORLD" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO_WORLD' to be recognized as SNAKE_CASE")

  gpbt_checkCase("SNAKE_CASE" "HELLO_WORLD_123" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO_WORLD_123' to be recognized as SNAKE_CASE")

  gpbt_checkCase("SNAKE_CASE" "HELLO" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO' to be recognized as SNAKE_CASE")

  gpbt_checkCase("SNAKE_CASE" "Hello_World" result)
  gpbt_assertFalse("${result}" "Expected 'Hello_World' to not be recognized as SNAKE_CASE")

  gpbt_checkCase("SNAKE_CASE" "HELLO-WORLD" result)
  gpbt_assertFalse("${result}" "Expected 'HELLO-WORLD' to not be recognized as SNAKE_CASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: kebab-case")
  gpbt_checkCase("kebab-case" "hello-world" result)
  gpbt_assertTrue("${result}" "Expected 'hello-world' to be recognized as kebab-case")

  gpbt_checkCase("kebab-case" "hello-world-123" result)
  gpbt_assertTrue("${result}" "Expected 'hello-world-123' to be recognized as kebab-case")

  gpbt_checkCase("kebab-case" "hello" result)
  gpbt_assertTrue("${result}" "Expected 'hello' to be recognized as kebab-case")

  gpbt_checkCase("kebab-case" "Hello-World" result)
  gpbt_assertFalse("${result}" "Expected 'Hello-World' to not be recognized as kebab-case")

  gpbt_checkCase("kebab-case" "hello--world" result)
  gpbt_assertFalse("${result}" "Expected 'hello--world' to not be recognized as kebab-case")
gpbt_endTestSection()

gpbt_startTestSection("Strings Check Case: KEBAB-CASE")
  gpbt_checkCase("KEBAB-CASE" "HELLO-WORLD" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO-WORLD' to be recognized as KEBAB-CASE")

  gpbt_checkCase("KEBAB-CASE" "HELLO-WORLD-123" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO-WORLD-123' to be recognized as KEBAB-CASE")

  gpbt_checkCase("KEBAB-CASE" "HELLO" result)
  gpbt_assertTrue("${result}" "Expected 'HELLO' to be recognized as KEBAB-CASE")

  gpbt_checkCase("KEBAB-CASE" "hello-world" result)
  gpbt_assertFalse("${result}" "Expected 'hello-world' to not be recognized as KEBAB-CASE")

  gpbt_checkCase("KEBAB-CASE" "HELLO_WORLD" result)
  gpbt_assertFalse("${result}" "Expected 'HELLO_WORLD' to not be recognized as KEBAB-CASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to UPPERCASE")
  gpbt_convertCase("UPPERCASE" "hello world" result)
  gpbt_assertEqual("${result}" "HELLOWORLD" "Convert spaced string to UPPERCASE")

  gpbt_convertCase("UPPERCASE" "hello_world" result)
  gpbt_assertEqual("${result}" "HELLOWORLD" "Convert snake_case to UPPERCASE")

  gpbt_convertCase("UPPERCASE" "helloWorld" result)
  gpbt_assertEqual("${result}" "HELLOWORLD" "Convert camelCase to UPPERCASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to lowercase")
  gpbt_convertCase("lowercase" "HELLO WORLD" result)
  gpbt_assertEqual("${result}" "helloworld" "Convert spaced string to lowercase")

  gpbt_convertCase("lowercase" "HELLO_WORLD" result)
  gpbt_assertEqual("${result}" "helloworld" "Convert SNAKE_CASE to lowercase")

  gpbt_convertCase("lowercase" "HelloWorld" result)
  gpbt_assertEqual("${result}" "helloworld" "Convert PascalCase to lowercase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to PascalCase")
  gpbt_convertCase("PascalCase" "hello world" result)
  gpbt_assertEqual("${result}" "HelloWorld" "Convert spaced string to PascalCase")

  gpbt_convertCase("PascalCase" "hello_world" result)
  gpbt_assertEqual("${result}" "HelloWorld" "Convert snake_case to PascalCase")

  gpbt_convertCase("PascalCase" "helloWorld" result)
  gpbt_assertEqual("${result}" "HelloWorld" "Convert camelCase to PascalCase")

  gpbt_convertCase("PascalCase" "hello-world" result)
  gpbt_assertEqual("${result}" "HelloWorld" "Convert kebab-case to PascalCase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to camelCase")
  gpbt_convertCase("camelCase" "Hello World" result)
  gpbt_assertEqual("${result}" "helloWorld" "Convert spaced string to camelCase")

  gpbt_convertCase("camelCase" "hello_world" result)
  gpbt_assertEqual("${result}" "helloWorld" "Convert snake_case to camelCase")

  gpbt_convertCase("camelCase" "HelloWorld" result)
  gpbt_assertEqual("${result}" "helloWorld" "Convert PascalCase to camelCase")

  gpbt_convertCase("camelCase" "HELLO-WORLD" result)
  gpbt_assertEqual("${result}" "helloWorld" "Convert KEBAB-CASE to camelCase")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to snake_case")
  gpbt_convertCase("snake_case" "Hello World" result)
  gpbt_assertEqual("${result}" "hello_world" "Convert spaced string to snake_case")

  gpbt_convertCase("snake_case" "helloWorld" result)
  gpbt_assertEqual("${result}" "hello_world" "Convert camelCase to snake_case")

  gpbt_convertCase("snake_case" "HelloWorld" result)
  gpbt_assertEqual("${result}" "hello_world" "Convert PascalCase to snake_case")

  gpbt_convertCase("snake_case" "HELLO-WORLD" result)
  gpbt_assertEqual("${result}" "hello_world" "Convert KEBAB-CASE to snake_case")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to SNAKE_CASE")
  gpbt_convertCase("SNAKE_CASE" "hello world" result)
  gpbt_assertEqual("${result}" "HELLO_WORLD" "Convert spaced string to SNAKE_CASE")

  gpbt_convertCase("SNAKE_CASE" "helloWorld" result)
  gpbt_assertEqual("${result}" "HELLO_WORLD" "Convert camelCase to SNAKE_CASE")

  gpbt_convertCase("SNAKE_CASE" "HelloWorld" result)
  gpbt_assertEqual("${result}" "HELLO_WORLD" "Convert PascalCase to SNAKE_CASE")

  gpbt_convertCase("SNAKE_CASE" "hello-world" result)
  gpbt_assertEqual("${result}" "HELLO_WORLD" "Convert kebab-case to SNAKE_CASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to kebab-case")
  gpbt_convertCase("kebab-case" "Hello World" result)
  gpbt_assertEqual("${result}" "hello-world" "Convert spaced string to kebab-case")

  gpbt_convertCase("kebab-case" "helloWorld" result)
  gpbt_assertEqual("${result}" "hello-world" "Convert camelCase to kebab-case")

  gpbt_convertCase("kebab-case" "HelloWorld" result)
  gpbt_assertEqual("${result}" "hello-world" "Convert PascalCase to kebab-case")

  gpbt_convertCase("kebab-case" "hello_world" result)
  gpbt_assertEqual("${result}" "hello-world" "Convert snake_case to kebab-case")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: to KEBAB-CASE")
  gpbt_convertCase("KEBAB-CASE" "hello world" result)
  gpbt_assertEqual("${result}" "HELLO-WORLD" "Convert spaced string to KEBAB-CASE")

  gpbt_convertCase("KEBAB-CASE" "helloWorld" result)
  gpbt_assertEqual("${result}" "HELLO-WORLD" "Convert camelCase to KEBAB-CASE")

  gpbt_convertCase("KEBAB-CASE" "HelloWorld" result)
  gpbt_assertEqual("${result}" "HELLO-WORLD" "Convert PascalCase to KEBAB-CASE")

  gpbt_convertCase("KEBAB-CASE" "hello_world" result)
  gpbt_assertEqual("${result}" "HELLO-WORLD" "Convert snake_case to KEBAB-CASE")
gpbt_endTestSection()

gpbt_startTestSection("Strings Convert Case: Edge Cases")
  gpbt_convertCase("camelCase" "" result)
  gpbt_assertEqual("${result}" "" "Convert empty string")

  # Testing numbers mixed with words
  gpbt_convertCase("snake_case" "Hello World 123" result)
  gpbt_assertEqual("${result}" "hello_world_123" "Convert string with numbers to snake_case")
  
  # Testing complex mixed formats
  gpbt_convertCase("PascalCase" "some_weird-Formatted String" result)
  gpbt_assertEqual("${result}" "SomeWeirdFormattedString" "Convert messy string to PascalCase")
gpbt_endTestSection()
