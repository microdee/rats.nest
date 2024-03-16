#pragma once

#include <concepts>

namespace rats::core::base::language::extension_methods
{
    template <typename T, typename Of>
    concept ExtensionMethod = std::invocable<T, Of>;

    template <typename Left, typename Extension> requires ExtensionMethod<Extension, Left>
    constexpr auto operator % (const Left& ls, Extension&& rs)
    {
        return rs(ls);
    }
}