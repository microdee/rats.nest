
#pragma once

#include <concepts>

namespace rats::core::base::functional
{
    namespace detail
    {
        template<int IsMemberFunctionIn, int IsConstIn, typename ReturnIn, typename... Args>
        struct FunctionMeta
        {
            enum
            {
                ArgumentCount = sizeof...(Args),
                IsMemberFunction = IsMemberFunctionIn,
                IsConst = IsConstIn
            };

            using Return = ReturnIn;
            using Arguments = std::tuple<Args...>;
            using Signature = Return(Args...);
            
            template<int I>
            struct Arg
            {
                using type = typename std::tuple_element_t<I, Arguments>;
            };

            template<int I>
            using ArgT = Arg<I>::type;
        };
    } // namespace detail
    
    template<std::invocable T>
    struct FunctionTraits : FunctionTraits<decltype(&T::operator())>
    {
        enum
        {
            IsLambda = 1
        };
    };

    template<std::invocable T>
    struct FunctionTraits : FunctionTraits<T>
    {
        enum
        {
            IsLambda = 0
        };
    };

    template<typename ClassIn, typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(ClassIn::*)(Args...) const> : detail::FunctionMeta<1, 1, ReturnIn, Args...>
    {
        using Class = ClassIn;
    };

    template<typename ClassIn, typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(ClassIn::*)(Args...)> : detail::FunctionMeta<1, 0, ReturnIn, Args...>
    {
        using Class = ClassIn;
    };

    template<typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(*)(Args...)> : detail::FunctionMeta<0, 0, ReturnIn, Args...> {};
} // namespace rats::core::base::templates
