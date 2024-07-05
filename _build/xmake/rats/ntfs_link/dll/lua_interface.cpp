//
// Created by md on 22/02/2024.
//

#include "lua_interface.h"

extern "C" {
#include <lauxlib.h>
}

#include "CharUtils.h"
#include "Hardlink.h"
#include "Junction.h"
#include "Symlink.h"

int CreateLink(lua_State *L, DWORD(*func)(LPCTSTR linkTchar, LPCTSTR targetTchar))
{
    size_t linkLength;
    const char* link = luaL_checklstring(L, 1, &linkLength);
    size_t targetLength;
    const char* target = luaL_checklstring(L, 2, &targetLength);
    TCHAR linkTchar[MAX_PATH] = {0};
    CHARtoTCHAR(link, linkLength, linkTchar, MAX_PATH);
    TCHAR targetTchar[MAX_PATH] = {0};
    CHARtoTCHAR(target, targetLength, targetTchar, MAX_PATH);

    DWORD result = func(linkTchar, targetTchar);
    lua_pushboolean(L, result == S_OK);
    lua_pushinteger(L, result);
    return 2;
}

int IsLink(lua_State *L, bool(*func)(LPCTSTR linkTchar))
{
    size_t targetLength;
    const char* target = luaL_checklstring(L, 1, &targetLength);
    TCHAR targetTchar[MAX_PATH] = {0};
    CHARtoTCHAR(target, targetLength, targetTchar, MAX_PATH);

    lua_pushboolean(L, func(targetTchar));
    return 1;
}

int GetLink(lua_State *L, DWORD(*func)(LPCTSTR linkTchar, LPTSTR outTarget, size_t TargetSize))
{
    size_t linkLength;
    const char* link = luaL_checklstring(L, 1, &linkLength);
    TCHAR linkTchar[MAX_PATH] = {0};
    CHARtoTCHAR(link, linkLength, linkTchar, MAX_PATH);
    TCHAR targetTchar[MAX_PATH] = {0};

    DWORD result = func(linkTchar, targetTchar, MAX_PATH);
    char target[MAX_PATH] = {0};
    TCHARtoCHAR(targetTchar, MAX_PATH, target, MAX_PATH);
    lua_pushstring(L, result == S_OK ? target : "");
    lua_pushinteger(L, result);
    return 2;
}

int DeleteLink(lua_State *L, DWORD(*func)(LPCTSTR linkTchar))
{
    size_t linkLength;
    const char* link = luaL_checklstring(L, 1, &linkLength);
    TCHAR linkTchar[MAX_PATH] = {0};
    CHARtoTCHAR(link, linkLength, linkTchar, MAX_PATH);

    DWORD result = func(linkTchar);
    lua_pushboolean(L, result == S_OK);
    lua_pushinteger(L, result);
    return 2;
}

int GetHardlinkCount_Lua(lua_State *L)
{
    size_t targetLength;
    const char* target = luaL_checklstring(L, 1, &targetLength);
    TCHAR targetTchar[MAX_PATH] = {0};
    CHARtoTCHAR(target, targetLength, targetTchar, MAX_PATH);
    DWORD count = 0;
    DWORD result = GetHardlinkCount(targetTchar, &count);

    lua_pushinteger(L, count);
    lua_pushinteger(L, result);
    return 2;
}

int CreateHardlink_Lua(lua_State *L)
{
    return CreateLink(L, &CreateHardlink);
}

int IsJunction_Lua(lua_State *L)
{
    return IsLink(L, &IsJunction);
}

int GetJunctionTarget_Lua(lua_State *L)
{
    return GetLink(L, &GetJunctionTarget);
}

int CreateJunction_Lua(lua_State *L)
{
    return CreateLink(L, &CreateJunction);
}

int DeleteJunction_Lua(lua_State *L)
{
    return DeleteLink(L, &DeleteJunction);
}

int IsSymlink_Lua(lua_State *L)
{
    return IsLink(L, &IsSymlink);
}

int GetSymlinkTarget_Lua(lua_State *L)
{
    return GetLink(L, &GetSymlinkTarget);
}

int CreateSymlink_Lua(lua_State *L)
{
    return CreateLink(L, &CreateSymlink);
}

int DeleteSymlink_Lua(lua_State *L)
{
    return DeleteLink(L, &DeleteSymlink);
}

int luaopen(ntfs_link, lua_State *L)
{
    static const luaL_Reg funcs [] = {
        {"CreateHardlink", CreateHardlink_Lua},
        {"GetHardlinkCount", GetHardlinkCount_Lua},
        {"IsJunction", IsJunction_Lua},
        {"GetJunctionTarget", GetJunctionTarget_Lua},
        {"CreateJunction", CreateJunction_Lua},
        {"DeleteJunction", DeleteJunction_Lua},
        {"IsSymlink", IsSymlink_Lua},
        {"GetSymlinkTarget", GetSymlinkTarget_Lua},
        {"CreateSymlink", CreateSymlink_Lua},
        {"DeleteSymlink", DeleteSymlink_Lua},
        {NULL, NULL}
    };
    lua_newtable(L);
    luaL_setfuncs(L, funcs, 0);
    return 1;
}