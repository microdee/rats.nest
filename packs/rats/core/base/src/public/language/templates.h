
#pragma once

#include "rats.core.base.language.type_pack.h"

namespace rats
{
    template <template <typename...> typename Template>
    struct TTemplate_Match
    {
        template <typename T>
        static constexpr bool Match = false;

        template <typename... Params>
        static constexpr bool Match<Template<Params...>> = true;
    };

    template <typename>
    struct TTemplate_Struct
    {
        static constexpr bool IsTemplate = false;
    };

    /**
     * Base struct containing traits of specified template instance (which only accepts type parameters)
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <template <typename...> typename Template, typename... Params>
    struct TTemplate_Struct<Template<Params...>>
    {
        static constexpr bool IsTemplate = true;
        
        static constexpr sz ParameterCount = sizeof...(Params);
        using Parameters = TTypes<Params...>;
        using ParametersDecay = TTypes<Dc<Params>...>;

        template <sz I>
        using Param = TTypeAtPack<I, Params...>;

        template <sz I>
        using ParamDecay = TTypes_Get<ParametersDecay, I>;
    };

    /**
     * Checks if input is a template which only has type parameters 
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <typename T>
    concept CTypeOnlyTemplate = TTemplate_Struct<T>::IsTemplate;

    /**
     * Get template type parameters
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <CTypeOnlyTemplate Instance>
    using TTemplate_Params = typename TTemplate_Struct<Instance>::Parameters;

    /**
     * Get decayed template type parameters
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <CTypeOnlyTemplate Instance>
    using TTemplate_ParamsDecay = typename TTemplate_Struct<Instance>::ParametersDecay;

    /**
     * Get a type parameter at a specified position of a templated instance. 
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <CTypeOnlyTemplate Instance, sz I>
    using TTemplate_Param = typename TTemplate_Struct<Instance>::template Param<I>;

    /**
     * Get a decayed type parameter at a specified position of a templated instance. 
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <CTypeOnlyTemplate Instance, sz I>
    using TTemplate_ParamDecay = typename TTemplate_Struct<Instance>::template ParamDecay<I>;

    /**
     * Check if given type is an instantiation of a given template (which only accepts type parameters)
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <typename Instance, template <typename...> typename Template>
    concept CMatchTemplate =
        CTypeOnlyTemplate<Instance>
        && TTemplate_Match<Template>::template Match<Dc<Instance>>
    ;

    /**
     * Get the number of template type parameters from a specified templated instance (which only has type parameters) 
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <CTypeOnlyTemplate Instance>
    inline constexpr sz TTemplate_ParamCount = TTemplate_Struct<Instance>::ParameterCount;

    template <template <typename...> typename, typename>
    struct TTemplateMap_Struct
    {
        using Type = void;
    };

    template <
        template <typename...> typename TemplateOut,
        template <typename...> typename TemplateIn,
        typename... Params
    >
    struct TTemplateMap_Struct<TemplateOut, TemplateIn<Params...>>
    {
        using Type = TemplateOut<Params...>;
    };

    /**
     * Transfer parameters from one template to another. Or in other words replace the template part of the input
     * template instance with `TemplateOut`.
     *
     * @warning
     * Until this proposal https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1985r0.pdf or equivalent is
     * considered seriously, template traits only work with templates which only have type-parameters. Non-type
     * parameters even when a default is specified for them will result in compile error.
     */
    template <template <typename...> typename TemplateOut, CTypeOnlyTemplate FromInstance>
    using TTemplateMap = typename TTemplateMap_Struct<TemplateOut, FromInstance>::Type;
}