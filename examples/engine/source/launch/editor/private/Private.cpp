// Copyright (c) - Graphical Playground. All rights reserved.
// For more information, see https://graphical-playground/legal
// mailto:support AT graphical-playground DOT com

#include <nlohmann/json.hpp>
#include <iostream>

int main()
{
    nlohmann::json config = {
        {"engine",  "Graphical Playground"},
        {"version", "0.4.0"},
        {"build",   {
            {"type",     "editor"},
            {"thirdparty", "nlohmann-json"}
        }}
    };

    std::cout << config.dump(2) << '\n';
    return 0;
}
