#pragma once

#include <concepts>
#include "rats.core.base.language.convenience.h"

namespace rats
{
    template<typename T>
    concept CBooleanTestable = std::convertible_to<T, bool>
        && requires(T&& t)
        {
            { !Forward<T>(t) } -> std::convertible_to<bool>;
        }
    ;

    template <typename T>
    concept CDerefable = requires(T t) { *t; };

    template <typename T>
    concept COptionalLike = CDerefable<T> && CBooleanTestable<T>;

    template <typename T>
    concept CVoid = $::same_as<T, void>;
}