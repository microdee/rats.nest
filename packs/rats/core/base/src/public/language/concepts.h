#pragma once

#include <concepts>

namespace rats::core::base::language::concepts
{
    template<typename T>
    concept BooleanTestable = std::convertible_to<T, bool>
        && requires(T&& t)
        {
            { !Forward<T>(t) } -> std::convertible_to<bool>;
        }
    ;

    template <typename T>
    concept Derefable = requires(T t) { *t; };

    template <typename T>
    concept OptionalLike = Derefable<T> && BooleanTestable<T>;
}