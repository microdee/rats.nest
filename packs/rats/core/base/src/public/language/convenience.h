
#pragma once

#include "rats.core.base.language.number_types.h"

namespace rats
{
    namespace $ = std;

    template <typename T>
    constexpr auto&& Fwd(T&& in) { return $::forward<T>(in); }

    template <typename T>
    using Dc = $::decay_t<T>;
}