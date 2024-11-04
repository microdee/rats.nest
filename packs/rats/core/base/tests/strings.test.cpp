#include <catch2/catch_test_macros.hpp>

#include "rats.core.base.h"

using namespace rats::core::base;
using namespace Catch::Matchers;

TEST_CASE("Path concatenation", "[rats.core.base][strings]")
{
    CHECK_THAT(("/some"_sz / "path"_sz), Equals("/some/path"_sz));
    CHECK_THAT(("/some"_sz / "more"_sz / "path"_sz), Equals("/some/more/path"_sz));
    CHECK_THAT(("/some"_sz / "nested"_sz / "file"_sz | ".txt"), Equals("/some/nested/file.txt"_sz));
}

TEST_CASE("Defaulting", "[rats.core.base][strings]")
{
    CHECK_THAT((""_sz > _(OnEmpty, "foo"_sz)), Equals("foo"_sz));
    CHECK_THAT(("   \n"_sz > _(OnWhitespace, "foo"_sz)), Equals("foo"_sz));
}