#pragma once

#include <string>

namespace rats::core::base::string::traits
{
    template <typename T>
    concept StringOrView = std::same_as<T, std::string> || std::same_as<T, std::string_view>;
}