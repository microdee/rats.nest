
#pragma once

#include <concepts>
#include <tuple>

namespace rats::core::base::tuples
{
    template <typename Tuple, size_t... Indices>
    using ComposeFrom = std::tuple<std::tuple_element_t<Indices, Tuple>...>;

    template <size_t Count, typename Tuple>
    requires (std::tuple_size_v<Tuple> >= Count)
    struct Skip
    {
        template <size_t... Indices>
        static consteval ComposeFrom<Tuple, (Indices + Count)...> Compose(std::index_sequence<Indices...>&&);

        using type = decltype(
            Compose(std::make_index_sequence<std::tuple_size_v<Tuple> - Count>{})
        );
    };

    template <size_t Count, typename Tuple>
    using Skip_t = typename Skip<Count, Tuple>::type;
}