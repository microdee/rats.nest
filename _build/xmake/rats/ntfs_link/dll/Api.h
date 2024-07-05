#if defined(LIBNTFSLINKS_IMPORT) && LIBNTFSLINKS_IMPORT
#define LIBNTFSLINKS_API __declspec(dllimport)
#else
#define LIBNTFSLINKS_API __declspec(dllexport)
#endif