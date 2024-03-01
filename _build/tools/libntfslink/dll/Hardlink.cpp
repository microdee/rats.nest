///////////////////////////////////////////////////////////////////////////////
//
// This file is part of libntfslinks.
//
// Copyright (c) 2014, Jean-Philippe Steinmetz
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
///////////////////////////////////////////////////////////////////////////////

#include "Hardlink.h"

#include <strsafe.h>
#include <winioctl.h>

#include "CharUtils.h"
#include "ntfstypes.h"
#include "StringUtils.h"

DWORD GetHardlinkCount(LPCTSTR Path, LPDWORD CountOut)
{
	DWORD result = (DWORD)E_FAIL;
	*CountOut = 0;

	// Grab the file attributes of Target. This allows us to determine the target exists but also if it is a file or
	// directory.
	DWORD fileAttributes = GetFileAttributes(Path);

	if (fileAttributes == INVALID_FILE_ATTRIBUTES || fileAttributes & FILE_ATTRIBUTE_DIRECTORY)
	{
		return E_INVALIDARG;
	}

	HANDLE fileHandle = CreateFile(Path, 0, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, NULL);

	BY_HANDLE_FILE_INFORMATION fileInfo;
	if (!GetFileInformationByHandle(fileHandle, &fileInfo))
	{
		return GetLastError();
	}

	*CountOut = fileInfo.nNumberOfLinks;
	return S_OK;
}

DWORD CreateHardlink(LPCTSTR Link, LPCTSTR Target)
{
	DWORD result = (DWORD)E_FAIL;

	// Grab the file attributes of Target. This allows us to determine the target exists but also if it is a file or
	// directory.
	DWORD fileAttributes = GetFileAttributes(Target);
	if (fileAttributes == INVALID_FILE_ATTRIBUTES)
	{
		// If the target does't exist it could be a relative path from the link instead of the current working
		// directory. In this case, we'll append Target to the base Link path and see if that exists.
		TCHAR AdjTarget[MAX_PATH];
		StringCchCopyN(AdjTarget, MAX_PATH, Link, StrFind(Link, TEXT("\\"), -1, -1)+1);
		StringCchCat(AdjTarget, MAX_PATH, Target);
		fileAttributes = GetFileAttributes(AdjTarget);
		if (fileAttributes == INVALID_FILE_ATTRIBUTES)
		{
			// Okay so that didn't work either. This means that we likely have an unknown path type Windows can't
			// figure out. For this we'll do a dirty trick and assume that a path whose basename does not
			// include an extension is a directory. This should account for the vast majority of circumstances.
			if (StrFind(Target, TEXT("."), -1, -1) < StrFind(Target, TEXT("\\"), -1, -1))
			{
				fileAttributes = FILE_ATTRIBUTE_DIRECTORY;
			}
		}
	}

	if (fileAttributes == INVALID_FILE_ATTRIBUTES || fileAttributes & FILE_ATTRIBUTE_DIRECTORY)
	{
		return E_INVALIDARG;
	}

	// Create the symlink
	if (CreateHardLink(Link, Target, NULL) != 0)
	{
		result = S_OK;
	}
	else
	{
		result = GetLastError();
	}

	return result;
}