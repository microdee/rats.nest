
#pragma once

#include <concepts>
#include "rats.core.base.language.convenience.h"

namespace rats
{
    namespace _private
    {
        /** Base struct recursively chopping away the first template arguments until I is 0 */
        template <sz I, typename First = void, typename... Rest>
        struct TTypeAtPack_Impl
        {
            using Type = typename TTypeAtPack_Impl<I - 1, Rest...>::Type;
        };

        /** Specialization for when I == 0, then take the First type */
        template <typename First, typename... Rest>
        struct TTypeAtPack_Impl<0, First, Rest...>
        {
            using Type = First;
        };
    }

    /** Shim for _private::TTypeAtPack_Impl */
    template <sz I, typename... T>
    struct TTypeAtPack_Struct
    {
        static_assert(I < sizeof...(T), "Indexing parameter pack out of its bounds.");
        using Type = typename _private::TTypeAtPack_Impl<I, T...>::Type;
    };

    /** Specialize shim for empty TypePack */
    template <sz I>
    struct TTypeAtPack_Struct<I>
    {
        using Type = void;
    };

    /**
     * Get a specific item from a parameter pack at given index. This will return `void` on an empty parameter pack.
     */
    template<sz I, typename... Rest>
    using TTypeAtPack = typename TTypeAtPack_Struct<I, Rest...>::Type;

    /**
     * Get a specific item from the end of a parameter pack at given index (0 == last). This will return `void` on an
     * empty parameter pack
     */
    template<sz I, typename... Rest>
    using TLastTypeAtPack = typename TTypeAtPack_Struct<sizeof...(Rest) - I - 1, Rest...>::Type;

    /**
     * Get a specific item from a parameter pack at given index disregarding CV-ref qualifiers. This will return `void`
     * on an empty parameter pack
     */
    template<sz I, typename... Rest>
    using TTypeAtPackDecay = Dc<typename TTypeAtPack_Struct<I, Rest...>::Type>;

    /**
     * Get a specific item from the end of a parameter pack at given index (0 == last) disregarding CV-ref qualifiers.
     * This will return `void` on an empty parameter pack.
     */
    template<sz I, typename... Rest>
    using TLastTypeAtPackDecay = Dc<typename TTypeAtPack_Struct<sizeof...(Rest) - I - 1, Rest...>::Type>;

    /**
     * This template is used to store pack of types in other templates, or to allow parameter pack inference for
     * functions. This template may be referred to as 'type-list' in other parts of the documentation.
     *
     * This may be much safer to use than tuples as they may try to use deleted features of listed types (especially
     * Unreal tuples). `TTypes` will never attempt to use its arguments (not even in `decltype` or `declval` contexts)
     * Included types in runtime will be completely erased (at least in the context of this struct.
     */
    template <typename... T>
    struct TTypes
    {
        static constexpr sz Count = sizeof...(T);

        template <sz I>
        using Get = TTypeAtPack<I, T...>;

        template <sz I>
        using GetDecay = TTypeAtPackDecay<I, T...>;
    };

    template <typename T>
    struct TIsTypeList_Struct { static constexpr bool Value = false; };

    template <typename... T>
    struct TIsTypeList_Struct<TTypes<T...>> { static constexpr bool Value = true; };

    /** Concept constraining a given type to `TTypes` or type-list */
    template <typename T>
    concept CTypeList = TIsTypeList_Struct<T>::Value;

    /** Conveniently get one element of a type-list, so clunky templating keywords are not needed */
    template <CTypeList T, sz I>
    using TTypes_Get = T::template Get<I>;

    /** Conveniently get one element of a type-list erasing qualifiers, so clunky templating keywords are not needed */
    template <CTypeList T, sz I>
    using TTypes_GetDecay = T::template GetDecay<I>;

    //// Manipulating type-lists as collections

    /** Compose a type-list out of the elements of the input type-list based on the input index parameter pack */
    template <CTypeList T, sz... Indices>
    using TComposeTypeListFrom = TTypes<TTypes_Get<T, Indices>...>;

    template <sz Count, CTypeList T>
    requires (T::Count >= Count)
    struct TTypesSkip_Struct
    {
        /** Since this is only meant to be used in decltype, no implementation is needed */
        template <sz... Indices>
        static consteval TComposeTypeListFrom<T, (Indices + Count)...> Compose($::index_sequence<Indices...>&&);

        using Type = decltype(
            Compose($::make_index_sequence<T::Count - Count>{})
        );
    };

    /** Skip the first `Count` elements of the input type-list */
    template <sz Count, CTypeList T>
    using TTypesSkip = typename TTypesSkip_Struct<Count, T>::Type;

    template <sz Count, CTypeList T>
    requires (T::Count >= Count)
    struct TTypesTrimEnd_Struct
    {
        /** Since this is only meant to be used in decltype, no implementation is needed */
        template <sz... Indices>
        static consteval TComposeTypeListFrom<T, Indices...> Compose($::index_sequence<Indices...>&&);

        using Type = decltype(
            Compose($::make_index_sequence<T::Count - Count>{})
        );
    };

    /** @brief Disregard the last `Count` elements of the input type-list */
    template <sz Count, typename T>
    using TTypesTrimEnd = typename TTypesTrimEnd_Struct<Count, T>::Type;

    template <sz Count, typename T>
    requires (T::Count >= Count)
    struct TTypesTake_Struct
    {
        /** Since this is only meant to be used in decltype, no implementation is needed */
        template <sz... Indices>
        static consteval TComposeTypeListFrom<T, Indices...> Compose($::index_sequence<Indices...>&&);

        using Type = decltype(
            Compose($::make_index_sequence<Count>{})
        );
    };

    /** @brief Take only the first `Count` elements of the input type-list */
    template <sz Count, typename T>
    using TTypesTake = typename TTypesTake_Struct<Count, T>::Type;

    //// Extra concepts

    namespace _private
    {
        template <CTypeList From, CTypeList To, sz... Indices>
        consteval bool IsTypeListConvertibleTo($::index_sequence<Indices...>&&)
        {
            return  (
                ... && $::convertible_to<
                    TTypes_Get<From, Indices>,
                    TTypes_Get<To, Indices>
                >
            );
        }
        
        template <CTypeList From, CTypeList To, sz... Indices>
        consteval bool IsTypeListConvertibleToDecay($::index_sequence<Indices...>&&)
        {
            return (
                ... && $::convertible_to<
                    Dc<TTypes_Get<From, Indices>>,
                    Dc<TTypes_Get<To, Indices>>
                >
            );
        }
    }

    /**
     * Is given type-list contains all types convertible to the types of another type-list. The number and order of types
     * are significant.
     */
    template <typename From, typename To>
    concept CTypesConvertibleTo =
        CTypeList<From>
        && CTypeList<To>
        && From::Count == To::Count
        && _private::IsTypeListConvertibleTo<From, To>(
            $::make_index_sequence<From::Count>()
        )
    ;

    /**
     * Is given type-list contains all types convertible to the types of another type-list. The number and order of types
     * are significant. Qualifiers are not taken into account. 
     */
    template <typename From, typename To>
    concept CTypesConvertibleToDc =
        CTypeList<From>
        && CTypeList<To>
        && From::Count == To::Count
        && _private::IsTypeListConvertibleToDecay<From, To>(
            $::make_index_sequence<From::Count>()
        )
    ;
}