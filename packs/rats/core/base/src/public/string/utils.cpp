
#include "utils.h"

namespace rats::core::base::string::utils
{
    sz::string_view OnEmpty(const sz::string_view& ls, const sz::string_view& rs)
    {
        return ls.length() == 0 ? rs : ls;
    }

    sz::string_view OnWhitespace(const sz::string_view& ls, const sz::string_view& rs)
    {
        return ls.length() == 0 || ls.is_space() ? rs : ls;
    }
}