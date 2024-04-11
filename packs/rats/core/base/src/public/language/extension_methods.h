#pragma once

#include <concepts>

namespace rats::core::base::language::extension_methods
{
    template <typename Left, typename Extension> requires std::invocable<Extension, Left>
    constexpr auto operator % (const Left& ls, Extension&& rs)
    {
        return rs(ls);
    }
}