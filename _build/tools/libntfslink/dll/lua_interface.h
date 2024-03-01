
#ifndef LIBNTFSLINK_LUA_INTERFACE_H
#define LIBNTFSLINK_LUA_INTERFACE_H
#pragma once

#include "Api.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>

LIBNTFSLINKS_API int CreateHardlink_Lua(lua_State* L);
LIBNTFSLINKS_API int GetHardlinkCount_Lua(lua_State* L);

LIBNTFSLINKS_API int IsJunction_Lua(lua_State* L);
LIBNTFSLINKS_API int GetJunctionTarget_Lua(lua_State* L);
LIBNTFSLINKS_API int CreateJunction_Lua(lua_State* L);
LIBNTFSLINKS_API int DeleteJunction_Lua(lua_State* L);

LIBNTFSLINKS_API int IsSymlink_Lua(lua_State* L);
LIBNTFSLINKS_API int GetSymlinkTarget_Lua(lua_State* L);
LIBNTFSLINKS_API int CreateSymlink_Lua(lua_State* L);
LIBNTFSLINKS_API int DeleteSymlink_Lua(lua_State* L);

LIBNTFSLINKS_API int luaopen_libntfslink(lua_State* L);

#ifdef __cplusplus
}
#endif

#endif //LIBNTFSLINK_LUA_INTERFACE_H
