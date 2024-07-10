#pragma once

#include <concepts>

#include "rats.core.base.functional.h"

/**
 * Rats infixing attempts to create a more readable syntax for passing arguments in-between functions.
 * This is a more general and less intrusive approach to the amazing infix paradigm of boost.HOF
 * but the syntax may be less pleasing to look at
 * 
 * `myInput > _(Foo, param);` instead of `myInput <Foo> param;`
 */
namespace rats::core::base::language::infixing
{
    using namespace rats::core::base::functional;

    /**
     * @brief  > (infixing operator in the context of functions) passes the left hand side operand
     *         into a function accepting that operand as a singular parameter. By itself that is not
     *         exactly "infixed" but the intention here is to be used with function template which
     *         moves the first parameter in front of the function like so (given function
     *         `void Foo(MyInput, MyParam)` ):
     * 
     *         `myInput > _(Foo, param);` should be equivalent to `_(Foo, param)(myInput);`
     * 
     *         This allows for a more modern syntax:
     *         
     *         ```
     *         auto result = input
     *             > _(Foo, a, b)
     *             > _(Bar, x, y)
     *             > _(etc);
     *         ```
     */
    template <typename Left, FunctionLike Right>
    constexpr Function_Return<Right> operator > (const Left& ls, Right&& rs)
    {
        return rs(ls);
    }

    /**
     * @brief  > (infixing operator in the context of functions) passes the left hand side operand
     *         into a function accepting that operand as a singular parameter. By itself that is not
     *         exactly "infixed" but the intention here is to be used with function template which
     *         moves the first parameter in front of the function like so (given function
     *         `void Foo(MyInput, MyParam)` ):
     * 
     *         `myInput > _(Foo, param);` should be equivalent to `_(Foo, param)(myInput);`
     * 
     *         This allows for a more modern syntax:
     *         
     *         ```
     *         auto result = input
     *             > _(Foo, a, b)
     *             > _(Bar, x, y)
     *             > _(etc);
     *         ```
     */
    template <typename Left, FunctionLike Right>
    constexpr Function_Return<Right> operator > (const Left& ls, const Right& rs)
    {
        return rs(ls);
    }

    /**
     * @brief  A wrapper allowing functions to be infixed between the first parameter and the rest
     *         with the following syntax:
     *         
     *         ```
     *         auto result = input
     *             > _(Foo, a, b)
     *             > _(Bar, x, y)
     *             > _(etc);
     *         ```
     * 
     *         in cooperation with the overloaded > operator.
     * 
     *         This wrapper actually returns a function which has the only argument as the first
     *         parameter of the input function pointer, and the remaining parameters captured via
     *         reference.
     */
    template <FunctionLike FunctionPtr, typename... Args>
    requires (Function_ArgCount<FunctionPtr> == sizeof...(Args) + 1)
    auto _(FunctionPtr func, const Args&... args)
    {
        return [&, func](Function_Arg<FunctionPtr, 0> left)
        {
            return func(left, args...);
        };
    }
}