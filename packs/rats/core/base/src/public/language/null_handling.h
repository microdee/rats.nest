#pragma once

#include <concepts>

namespace rats::core::base::language::null_handling
{
    template <typename T>
    concept Derefable = requires(T t) { *t; };

    template <typename T>
    concept BoolCheckable = requires(T t) { if(t); };

    template <typname T>
    concept OptionalLike = Derefable<T> && BoolCheckable<T>;

    /** Null propagating || operator */
    template <OptionalLike Left, typename Function> requires std::invocable<Function, decltype(*Left{})>
    constexpr auto operator || (Left ls, const Function& rs)
    {
        return ls ? rs(*ls) : decltype(rs(*ls)){};
    }

    /** Default provider || operator */
    template <OptionalLike Left, std::invocable Function>
    constexpr Left operator || (Left ls, const Function& rs)
    {
        return ls ? ls : rs();
    }
}