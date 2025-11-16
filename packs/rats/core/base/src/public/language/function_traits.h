
#pragma once

#include "rats.core.base.language.templates.h"

namespace rats
{
    /** Concept constraining input T to a lambda function or a functor object. */
    template <typename T>
    concept CFunctorObject = requires { &Dc<T>::operator(); };

    namespace _private
    {
        template <typename ReturnIn, typename... Args>
        struct TFunctionMeta
        {
            static constexpr sz ArgumentCount = sizeof...(Args);

            using Return = ReturnIn;
            using ReturnDecay = Dc<ReturnIn>;

            /** The input parameters of the function as a type-list. Types are not decayed. */
            using Arguments = TTypes<Args...>;

            /** The input parameters of the function as a type-list. Types are decayed (useful for storage) */
            using ArgumentsDecay = TTypes<Dc<Args>...>;

            /** The pure function signature with other information stripped from it */
            using Signature = Return(Args...);

            template <sz I>
            using Arg = TTypes_Get<Arguments, I>;

            template <sz I>
            using ArgDecay = TTypes_Get<ArgumentsDecay, I>;
        };
    }

    /**
     * Get signature information about any function declaring type (function pointer or functor
     * structs including lambda functions). It should be used in other templates.
     * 
     * @tparam T  the inferred type of the input function. 99% of cases this should be inferred.
     */
    template <typename T>
    struct TFunctionTraits
    {
        static constexpr sz ArgumentCount = 0;
        static constexpr bool IsFunction = false;
        static constexpr bool IsPointer = false;
        static constexpr bool IsFunctor = false;
        static constexpr bool IsMember = false;
        static constexpr bool IsConst = false;
    };
        
    /** Specialization for functor structs / lambda functions. */
    template <CFunctorObject T>
    struct TFunctionTraits<T> : TFunctionTraits<decltype(&Dc<T>::operator())>
    {
        static constexpr bool IsFunction = true;
        static constexpr bool IsPointer = false;
        static constexpr bool IsFunctor = true;
        static constexpr bool IsMember = false;
        static constexpr bool IsConst = false;
    };

    /** Specialization extracting the types from the compound function pointer type of a const member function. */
    template <typename ClassIn, typename ReturnIn, typename... Args>
    struct TFunctionTraits<ReturnIn(ClassIn::*)(Args...) const> : _private::TFunctionMeta<ReturnIn, Args...>
    {
        using Class = ClassIn;
        static constexpr bool IsFunction = true;
        static constexpr bool IsPointer = true;
        static constexpr bool IsFunctor = false;
        static constexpr bool IsMember = true;
        static constexpr bool IsConst = true;
    };

    /** Specialization extracting the types from the compound function pointer type of a member function. */
    template <typename ClassIn, typename ReturnIn, typename... Args>
    struct TFunctionTraits<ReturnIn(ClassIn::*)(Args...)> : _private::TFunctionMeta<ReturnIn, Args...>
    {
        using Class = ClassIn;
        static constexpr bool IsFunction = true;
        static constexpr bool IsPointer = true;
        static constexpr bool IsFunctor = false;
        static constexpr bool IsMember = true;
        static constexpr bool IsConst = false;
    };

    /** Specialization extracting the types from the compound function pointer type. */
    template <typename ReturnIn, typename... Args>
    struct TFunctionTraits<ReturnIn(*)(Args...)> : _private::TFunctionMeta<ReturnIn, Args...>
    {
        static constexpr bool IsFunction = true;
        static constexpr bool IsPointer = true;
        static constexpr bool IsFunctor = false;
        static constexpr bool IsMember = false;
        static constexpr bool IsConst = false;
    };

    /** Specialization extracting the types from the compound function type. */
    template <typename ReturnIn, typename... Args>
    struct TFunctionTraits<ReturnIn(Args...)> : _private::TFunctionMeta<ReturnIn, Args...>
    {
        static constexpr bool IsFunction = true;
        static constexpr bool IsPointer = false;
        static constexpr bool IsFunctor = false;
        static constexpr bool IsMember = false;
        static constexpr bool IsConst = false;
    };

    /** Shorthand for getting a type-list representing the function arguments. */
    template <typename T>
    using TFunction_Arguments = typename TFunctionTraits<Dc<T>>::Arguments;

    /** Shorthand for getting a type-list representing the decayed function arguments. */
    template <typename T>
    using TFunction_ArgumentsDecay = typename TFunctionTraits<Dc<T>>::ArgumentsDecay;

    /** Shorthand for getting a type of a function argument at given position I. */
    template <typename T, sz I>
    using TFunction_Arg = typename TFunctionTraits<Dc<T>>::template Arg<I>;

    /** Shorthand for getting a decayed type of a function argument at given position I. */
    template <typename T, sz I>
    using TFunction_ArgDecay = typename TFunctionTraits<Dc<T>>::template ArgDecay<I>;

    /** Shorthand for getting a function argument count. */
    template <typename T>
    inline constexpr sz TFunction_ArgCount = TFunctionTraits<Dc<T>>::ArgumentCount;

    /** Shorthand for getting a function return type. */
    template <typename T>
    using TFunction_Return = typename TFunctionTraits<Dc<T>>::Return;

    /** Shorthand for getting a function return type discarding qualifiers. */
    template <typename T>
    using TFunction_ReturnDecay = typename TFunctionTraits<Dc<T>>::ReturnDecay;

    /** Shorthand for getting a pure function signature. */
    template <typename T>
    using TFunction_Signature = typename TFunctionTraits<Dc<T>>::Signature;

    template <typename T>
    concept CFunction_IsMember = TFunctionTraits<Dc<T>>::IsMember;

    /** Shorthand for getting the class of a member function. */
    template <CFunction_IsMember T>
    using TFunction_Class = typename TFunctionTraits<Dc<T>>::Class;

    /**
     * Tests if a provided class member function pointer instance (not type!) is indeed an instance member method.
     * Negating it can assume static class member function
     */
    template <auto FunctionPtr>
    concept CInstanceMethod = CFunction_IsMember<decltype(FunctionPtr)>;

    /** Shorthand for getting the constness of a member function. */
    template <typename T>
    concept CFunction_IsConst = TFunctionTraits<Dc<T>>::IsConst;

    /** A concept accepting any function like entity (function pointer or functor object) */
    template <typename T>
    concept CFunctionLike = TFunctionTraits<Dc<T>>::IsFunction;

    /** A concept accepting function pointer types */
    template <typename T>
    concept CFunctionPtr = TFunctionTraits<Dc<T>>::IsPointer;

    /**
     * A concept constraining an input function type to be a member pointer of the input class. This is useful for
     * constraining the bound objects for a function pointer input.
     */
    template <typename Class, typename Function>
    concept CHasFunction = CFunction_IsMember<Function>
        && ($::derived_from<Class, TFunction_Class<Function>> || $::same_as<Class, TFunction_Class<Function>>)
    ;

    template <typename Return, typename>
    struct TFunctionFromTypes_Struct
    {
        using Type = void;
    };

    template <typename Return, typename... Types>
    struct TFunctionFromTypes_Struct<Return, TTypes<Types...>>
    {
        using Type = Return(Types...);
    };

    /** Compose a function type from a return type and a type list for parameters. */
    template <typename Return, CTypeList Types>
    using TFunctionFromTypes = typename TFunctionFromTypes_Struct<Return, Types>::Type;

    /** Override the return type of an input function signature */
    template <typename Return, typename DstFunction>
    using TSetReturn = TFunctionFromTypes<Return, TFunction_Arguments<DstFunction>>;

    /** Override the return type of an input function signature, and discard its qualifiers */
    template <typename Return, typename DstFunction>
    using TSetReturnDecay = TFunctionFromTypes<Dc<Return>, TFunction_Arguments<DstFunction>>;

    /** Copy the return type from source function signature to the destination one */
    template <typename SrcFunction, typename DstFunction>
    using TCopyReturn = TSetReturn<TFunction_Return<SrcFunction>, DstFunction>;

    /** Copy the return type from source function signature to the destination one, and discard its qualifiers */
    template <typename SrcFunction, typename DstFunction>
    using TCopyReturnDecay = TSetReturnDecay<TFunction_ReturnDecay<SrcFunction>, DstFunction>;

    /**
     * Is given tuple type compatible with the arguments of the given function?
     *
     * Works with `TTuple`, `$::tuple` and `ranges::common_tuple` (tuple type of RangeV3 library)
     */
    template <typename Tuple, typename Function>
    concept CTupleCompatibleWithFunction =
        $::tuple_like<Tuple>
        && CFunctionLike<Function>
        && CTypesConvertibleTo<TTemplateMap<TTypes, Tuple>, TFunction_Arguments<Function>>
    ;

    namespace _private
    {
        template <typename Function, $::tuple_like Tuple, sz... Sequence>
        TFunction_Return<Function> InvokeWithTuple_Impl(
            Function&& function,
            Tuple&& arguments,
            $::index_sequence<Sequence...>&&)
        {
            return function($::get<Sequence>(arguments)...);
        }
            
        template <typename Object, typename Function, $::tuple_like Tuple, sz... Sequence>
        TFunction_Return<Function> InvokeWithTuple_Impl(
            Object* object,
            Function&& function,
            Tuple&& arguments,
            $::index_sequence<Sequence...>&&)
        {
            return (object->*function)($::get<Sequence>(arguments)...);
        }
    }

    /**
     * A clone of $::apply for Unreal, STL and RangeV3 tuples which also supports function pointers.
     * 
     * TL;DR: It calls a function with arguments supplied from a tuple.
     */
    template <typename Function, CTupleCompatibleWithFunction<Function> Tuple>
    TFunction_Return<Function> InvokeWithTuple(Function&& function, Tuple&& arguments)
    {
        return _private::InvokeWithTuple_Impl(
            Fwd(function), Fwd(arguments),
            $::make_index_sequence<TFunction_ArgCount<Function>>()
        );
    }

    /**
     * A clone of $::apply for Unreal, STL and RangeV3 tuples which also supports function pointers. This overload
     * can bind an object
     * 
     * TL;DR: It calls a function with arguments supplied from a tuple.
     */
    template <
        CFunctionPtr Function,
        CHasFunction<Function> Object,
        CTupleCompatibleWithFunction<Function> Tuple
    >
    TFunction_Return<Function> InvokeWithTuple(Object* object, Function&& function, Tuple&& arguments)
    {
        return _private::InvokeWithTuple_Impl(
            object,
            Fwd(function), Fwd(arguments),
            $::make_index_sequence<TFunction_ArgCount<Function>>()
        );
    }

    /** Concept matching the return of a type with compatible return types, disregarding CV-ref qualifiers. */
    template <typename F, typename Return>
    concept CFunctionCompatible_ReturnDecay =
        CFunctionLike<F>
        && CConvertibleToDecayed<TFunction_ReturnDecay<F>, Return>
    ;

    /** Concept matching the return of a type with compatible return types, preserving CV-ref qualifiers. */
    template <typename F, typename Return>
    concept CFunctionCompatible_Return =
        CFunctionLike<F>
        && CConvertibleTo<TFunction_Return<F>, Return>
    ;

    /** Concept matching function types with compatible set of arguments, disregarding CV-ref qualifiers. */
    template <typename F, typename With>
    concept CFunctionCompatible_ArgumentsDecay =
        CFunctionLike<F>
        && CFunctionLike<With>
        && CTypesConvertibleToDecayed<
            TFunction_ArgumentsDecay<With>,
            TFunction_ArgumentsDecay<F>
        >
    ;

    /** Concept matching function types with compatible set of arguments, preserving CV-ref qualifiers. */
    template <typename F, typename With>
    concept CFunctionCompatible_Arguments =
        CFunctionLike<F>
        && CFunctionLike<With>
        && CTypesConvertibleTo<
            TFunction_Arguments<With>,
            TFunction_Arguments<F>
        >
    ;

    /**
     * Concept constraining a function type to another one which arguments and return types are compatible,
     * disregarding CV-ref qualifiers
     */
    template <typename F, typename With>
    concept CFunctionCompatibleDecay =
        CFunctionLike<F>
        && CFunctionLike<With>
        && CFunctionCompatible_ReturnDecay<F, TFunction_ReturnDecay<With>>
        && CFunctionCompatible_ArgumentsDecay<F, With>
    ;

    /**
     * Concept constraining a function type to another one which arguments and return types are compatible,
     * preserving CV-ref qualifiers
     */
    template <typename F, typename With>
    concept CFunctionCompatible =
        CFunctionLike<F>
        && CFunctionLike<With>
        && CFunctionCompatible_Return<F, TFunction_Return<With>>
        && CFunctionCompatible_Arguments<F, With>
    ;

    /** Concept matching function types returning void. */
    template <typename F>
    concept CFunctionReturnsVoid = CFunctionLike<F> && CVoid<TFunction_Return<F>>;
}