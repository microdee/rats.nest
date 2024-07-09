
#include "utils.h"

namespace rats::core::base::string::utils
{
    auto OnEmpty(const sz::string_view& rs) -> Infixed<sz::string_view, const sz::string_view&>
    {
        return [&rs](const sz::string_view& ls)
        {
            return ls.length() == 0 ? rs : ls;
        };
    }

    auto OnWhitespace(const sz::string_view& rs) -> Infixed<sz::string_view, const sz::string_view&>
    {
        return [&rs](const sz::string_view& ls)
        {
            return ls.length() == 0 || ls.is_space() ? rs : ls;
        };
    }
}