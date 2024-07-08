#pragma once

#include <concepts>

#include "rats.core.base.functional.h"

/**
 * Rats infixing attempts to create a more readable syntax for passing arguments in-between functions
 */
namespace rats::core::base::language::infixing
{
    using namespace rats::core::base::functional;

    /**
     * @brief  % (infixing operator in the context of functions) passes the left hand side operand
     *         into a function accepting that operand as a singular parameter. By itself that is not
     *         exactly "infixed" but the intention here is to be used with functions returning other
     *         functions, for example:
     * 
     *         `myInput % Foo(param);` should be equivalent to `Foo(param)(myInput);`
     * 
     *         This allows for a more modern syntax:
     *         
     *         ```
     *         auto result = input
     *             % Foo(a, b)
     *             % Bar(x, y)
     *             % etc();
     *         ```
     */
    template <typename Left, AcceptsOnly<Left> Right>
    constexpr Function_Return<Right> operator % (const Left& ls, Right&& rs)
    {
        return rs(ls);
    }

    /**
     * @brief  % (infixing operator in the context of functions) passes the left hand side operand
     *         into a function accepting that operand as a singular parameter. By itself that is not
     *         exactly "infixed" but the intention here is to be used with functions returning other
     *         functions, for example:
     * 
     *         `myInput % Foo(param);` should be equivalent to `Foo(param)(myInput);`
     * 
     *         This allows for a more modern syntax:
     *         
     *         ```
     *         auto result = input
     *             % Foo(a, b)
     *             % Bar(x, y)
     *             % etc();
     *         ```
     */
    template <typename Left, AcceptsOnly<Left> Right>
    constexpr Function_Return<Right> operator % (const Left& ls, const Right& rs)
    {
        return rs(ls);
    }
}