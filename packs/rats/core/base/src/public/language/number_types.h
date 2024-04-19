#pragma once

#include <cstdint>
#include <stdfloat>

namespace rats::core::base::language::number_types
{
    using ui8 = uint8_t;
    using ui16 = uint16_t;
    using ui32 = uint32_t;
    using ui64 = uint64_t;
    
    using si8 = int8_t;
    using si16 = int16_t;
    using si32 = int32_t;
    using si64 = int64_t;
    
    using fp16 = std::float16_t;
    using fp32 = std::float32_t;
    using fp64 = std::float64_t;
    using fp128 = std::float128_t;
}