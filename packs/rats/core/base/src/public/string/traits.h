#pragma once

#include <string>

#include "stringzilla.hpp"

namespace rats::core::base::string::traits
{
    namespace sz = ashvardanian::stringzilla;
    
    template <typename T>
    concept StdStringOrView = std::same_as<T, std::string> || std::same_as<T, std::string_view>;

    template <typename T>
    concept SzStringOrView = std::same_as<T, sz::string> || std::same_as<T, sz::string_view>;

    template <typename T>
    concept StringOrView = StdStringOrView<T> || SzStringOrView<T>;
}