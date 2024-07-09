#pragma once

#include <string>
#include <functional>

#include "rats.core.base.string.traits.h"
#include "rats.core.base.language.infixing.h"

namespace rats::core::base::string::utils
{
    using namespace rats::core::base::string::traits;
    using namespace rats::core::base::language::infixing;

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

    template <StringOrView String, typename... ConcatenationArgs>
    auto operator / (String&& rs, sz::concatenation<ConcatenationArgs...>&& ls)
    {
        return ls | "/"_sz | rs;
    }

    /** Use it via `myString % OnEmpty("None"_sz) */
    auto OnEmpty(const sz::string_view& rs) -> Infixed<sz::string_view, const sz::string_view&>;

    /** Use it via `myString % OnWhitespace("None"_sz) */
    auto OnWhitespace(const sz::string_view& rs) -> Infixed<sz::string_view, const sz::string_view&>;
}