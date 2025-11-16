#pragma once

#if defined(_MSVC_LANG)

#define CPP_VERSION_LONG _MSVC_LANG

#else

#define CPP_VERSION_LONG __cplusplus

#endif

#define IS_CPP_17 CPP_VERSION_LONG >= 201703L
#define IS_CPP_20 CPP_VERSION_LONG >= 202002L
#define IS_CPP_23 CPP_VERSION_LONG >= 202302L