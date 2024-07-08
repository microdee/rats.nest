#include <catch2/catch_test_macros.hpp>

#include "rats.core.base.h"

import std;

using namespace rats::core::base;

struct NullableObject
{
    int X, Y, Z = 2;
};

struct NestedObject
{
    std::optional<NestedObject> Member {};
    int Payload = 3;
};

TEST_CASE("Null handling operator", "[null_handling]")
{
    NullableObject* nulled = nullptr;
    int propagationFailure = nulled / [](NullableObject& $) { return $.X; };
    CHECK(propagationFailure == int{});
    
    NullableObject valid {};
    NullableObject* validPtr = &valid;
    int propagationSuccess = validPtr / [](NullableObject& $) { return $.X; };
    CHECK(propagationSuccess == 2);
}