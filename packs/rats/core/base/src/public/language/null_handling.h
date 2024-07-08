#pragma once

#include <concepts>

#include "rats.core.base.language.concepts.h"
#include "rats.core.base.functional.h"

/**
 * This namespace contains utilities for handling optional types (naked pointers, std::optional,
 * std::shared_ptr, etc...) in a comfortable manner
 */
namespace rats::core::base::language::null_handling
{
    using namespace rats::core::base::functional;
    using namespace rats::core::base::language::concepts;

    /** Optional propagating / operator */
    template <
        OptionalLike Left,
        AcceptsOnly<decltype(*std::declval<Left>)> Function
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