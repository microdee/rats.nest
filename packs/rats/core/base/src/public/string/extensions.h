#pragma once

#include <string>
#include <functional>

#include "rats.core.base.string.traits.h"
#include "rats.core.base.language.extension_methods.h"

namespace rats::core::base::string::extensions
{
    using namespace rats::core::base::string::traits;
    using namespace rats::core::base::language::extension_methods;

    template <StringOrView String>
    constexpr std::string operator / (const String& ls, const String& rs)
    {
        return ls + "/" + rs;
    }

    template <StringOrView String>
    constexpr std::string operator / (String&& ls, String&& rs)
    {
        return ls + "/" + rs;
    }

    struct TakeUntil
    {
        using Predicate = std::move_only_function<bool, int>
        private: 
    }

    struct Trim
    {
        private: char TrimChar;
        public: Trim(char trimChar) : TrimChar(trimChar) {}

        template <StringOrView String>
        std::string_view operator () (const String& ls) const
        {

        }
    }
}