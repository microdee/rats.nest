#pragma once

#include <concepts>

namespace rats::core::base::language::null_handling
{
    // TODO: do "pointer-like" instead of naked pointer and do functor instead of std::function
    template <typename Left, typename Result>
    constexpr Result operator || (Left* ls, const std::function<Result(Left&)> rs)
    {
        return ls ? rs(*ls) : Result{};
    }
}