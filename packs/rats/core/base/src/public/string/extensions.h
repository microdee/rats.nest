#pragma once

#include <string>
#include <functional>

#include "rats.core.base.string.traits.h"
#include "rats.core.base.language.extension_methods.h"

namespace rats::core::base::string::extensions
{
    using namespace rats::core::base::string::traits;

    namespace sz = ashvardanian::stringzilla;
    using namespace sz::literals;

    template <StringOrView LsString, StringOrView RsString>
    auto operator / (LsString&& ls, RsString&& rs)
    {
        return sz::concatenate(std::forward(ls), "/"_sz, std::forward(rs));
    }

    template <StringOrView String, typename... ConcatenationArgs>
    auto operator / (sz::concatenation<ConcatenationArgs...>&& ls, String&& rs)
    {
        return ls | "/"_sz | rs;
    }

    /** Use it via `myString % OnEmpty("None"_sz) */
    auto OnEmpty(const sz::string_view& rs)
    {
        return [&rs](const sz::string_view& ls)
        {
            return ls.length() == 0 ? rs : ls;
        };
    }

    /** Use it via `myString % OnWhitespace("None"_sz) */
    auto OnWhitespace(const sz::string_view& rs)
    {
        return [&rs](const sz::string_view& ls)
        {
            return ls.length() == 0 || ls.is_space() ? rs : ls;
        };
    }
}