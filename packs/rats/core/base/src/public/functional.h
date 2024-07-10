
#pragma once

#include <concepts>
#include <tuple>

#include "rats.core.base.tuples.h"

/**
 * this namespace contains functional templates, concepts and usual lambda calculus helpers
 */
namespace rats::core::base::functional
{
    using namespace rats::core::base::tuples;

    /** Concept constraining input T to a lambda function or a functor object. */
    template <typename T>
    concept FunctorObject = requires { &T::operator(); };

    namespace detail
    {
        template <bool IsMemberFunctionIn, bool IsConstIn, typename ReturnIn, typename... Args>
        struct FunctionMeta
        {
            static constexpr size_t ArgumentCount = sizeof...(Args);

            /** Is the function a member of a type */
            static constexpr bool IsMember = IsMemberFunctionIn;
            
            /** Is the function marked const on a type */
            static constexpr bool IsConst = IsConstIn;

            using Return = ReturnIn;

            /** The input parameters of the function as a tuple type. Types are not decayed. */
            using Arguments = std::tuple<Args...>;

            /** The input parameters of the function as a tuple type. Types are decayed (useful for storage) */
            using ArgumentsDecay = std::tuple<std::decay_t<Args>...>;

            /** The pure function signature with other information stripped from it */
            using Signature = Return(Args...);

            template <int I>
            using Arg = std::tuple_element_t<I, Arguments>;

            template <int I>
            using ArgDecay = std::tuple_element_t<I, ArgumentsDecay>;
        };
    }
    
    /**
     * Get signature information about any function declaring type (function pointer or functor
     * structs including lambda functions). It should be used in other templates.
     * @tparam T the inferred type of the input function. 99% of cases this should be inferred.
     */
    template <typename T>
    struct FunctionTraits
    {
        static constexpr bool IsFunction = false;
    };
        
    /** Specialization for functor structs / lambda functions. */
    template <FunctorObject T>
    struct FunctionTraits<T> : FunctionTraits<decltype(&T::operator())>
    {
        static constexpr bool IsFunction = true;
    };

    /** Specialization extracting the types from the compound function type of a const member function. */
    template <typename ClassIn, typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(ClassIn::*)(Args...) const> : detail::FunctionMeta<true, true, ReturnIn, Args...>
    {
        using Class = ClassIn;
        static constexpr bool IsFunction = true;
    };

    /** Specialization extracting the types from the compound function type of a member function. */
    template <typename ClassIn, typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(ClassIn::*)(Args...)> : detail::FunctionMeta<true, false, ReturnIn, Args...>
    {
        using Class = ClassIn;
        static constexpr bool IsFunction = true;
    };

    /** Specialization extracting the types from the compound function type. */
    template <typename ReturnIn, typename... Args>
    struct FunctionTraits<ReturnIn(*)(Args...)> : detail::FunctionMeta<false, false, ReturnIn, Args...>
    {
        static constexpr bool IsFunction = true;
    };

    /** Shorthand for getting a type of a function argument at given position I. */
    template <typename T, int I>
    using Function_Arg = typename FunctionTraits<T>::template Arg<I>;

    /** Shorthand for getting a decayed type of a function argument at given position I. */
    template <typename T, int I>
    using Function_ArgDecay = typename FunctionTraits<T>::template ArgDecay<I>;

    template <typename T>
    inline constexpr size_t Function_ArgCount = FunctionTraits<T>::ArgumentCount;

    template <typename T>
    using Function_Return = typename FunctionTraits<T>::Return;

    template <typename T>
    using Function_Signature = typename FunctionTraits<T>::Signature;

    template <typename T>
    inline constexpr bool Function_IsMember = FunctionTraits<T>::IsMember;

    template <typename T>
    inline constexpr bool Function_IsConst = FunctionTraits<T>::IsConst;
    
    /** A concept accepting any function like entity (function pointer or functor object) */
    template <typename T>
    concept FunctionLike = FunctionTraits<T>::IsFunction;

    // TODO: faulty, check conversion of arguments instead
    /** Given function shall only accept given arguments */
    template <typename Function, typename... Args>
    concept AcceptsOnly = FunctionLike<Function>
        && std::same_as<
            typename FunctionTraits<Function>::ArgumentsDecay,
            std::tuple<std::decay_t<Args>...>
        >
    ;

    // TODO: faulty, check conversion of arguments instead
    /** Given function shall only accept given arguments with given qualifiers */
    template <typename Function, typename... Args>
    concept AcceptsPrecisely = FunctionLike<Function>
        && std::same_as<
            typename FunctionTraits<Function>::Arguments,
            std::tuple<Args...>
        >
    ;

    // TODO: faulty, check conversion of arguments instead
    /** Given function pure signature shall match the given signature */
    template <typename Function, typename Signature>
    concept SignatureCompatible = std::same_as<typename FunctionTraits<Function>::Signature, Signature>;

    namespace detail
    {
        template<typename Function, size_t... Sequence>
        typename FunctionTraits<Function>::Return ApplyImplementation(
            Function&& function,
            const typename FunctionTraits<Function>::Arguments& arguments,
            std::index_sequence<Sequence...>&&
        )
        {
            return function(arguments.template Get<Sequence>()...);
        }

        template<typename Function, size_t... Sequence>
        typename FunctionTraits<Function>::Return ApplyImplementation(
            const Function& function,
            const typename FunctionTraits<Function>::Arguments& arguments,
            std::index_sequence<Sequence...>&&
        )
        {
            return function(arguments.template Get<Sequence>()...);
        }
    }

	/**
	 * A clone of std::apply for Unreal tuples which also supports function pointers.
	 * TL;DR: It calls a function with arguments supplied from a tuple.
	 */
	template<typename Function>
	typename FunctionTraits<Function>::Return Apply(Function&& function, const typename FunctionTraits<Function>::Arguments& arguments)
	{
		return detail::ApplyImplementation(
            Forward<Function>(function), arguments, std::make_index_sequence<FunctionTraits<Function>::ArgumentCount>()
        );
	}

	/**
	 * A clone of std::apply for Unreal tuples which also supports function pointers.
	 * TL;DR: It calls a function with arguments supplied from a tuple.
	 */
	template<typename Function>
	typename FunctionTraits<Function>::Return Apply(const Function& function, const typename FunctionTraits<Function>::Arguments& arguments)
	{
		return detail::ApplyImplementation(
            function, arguments, std::make_index_sequence<FunctionTraits<Function>::ArgumentCount>()
        );
	}

    template <typename Return, typename Tuple, size_t... Indices>
    using FunctionPtrFromTupleIndices = Return(*)(std::tuple_element_t<Indices, Tuple>...);

    template <typename Return, typename Tuple>
    struct FunctionPtrFromTuple
    {
        template <size_t... Indices>
        static consteval FunctionPtrFromTupleIndices<Return, Tuple, Indices...> Compose(std::index_sequence<Indices...>&&);

        using type = decltype(
            Compose(std::make_index_sequence<std::tuple_size_v<Tuple>>{})
        );
    };

    template <typename Return, typename Tuple>
    using FunctionPtrFromTuple_t = typename FunctionPtrFromTuple<Return, Tuple>::type;
}
