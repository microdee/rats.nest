#pragma once

#include <concepts>

#include "rats.core.base.language.concepts.h"
#include "rats.core.base.language.function_traits.h"

/**
 * This namespace contains utilities for handling optional types (naked pointers, std::optional,
 * std::shared_ptr, etc...) in a comfortable manner
 */
namespace rats
{
    /** Optional propagating / operator */
    template <
        COptionalLike Left,
        CFunctionCompatible_Arguments<void(Left&&)> Function
    >
    constexpr Function_Return<Function> operator / (const Left& ls, const Function& rs)
    {
        return ls ? rs(*ls) : Function_Return<Function>{};
    }

    /** Default provider / operator */
    template <OptionalLike Left, SignatureCompatible<Left()> Function>
    constexpr Left operator / (const Left& ls, const Function& rs)
    {
        return ls ? ls : rs();
    }
}