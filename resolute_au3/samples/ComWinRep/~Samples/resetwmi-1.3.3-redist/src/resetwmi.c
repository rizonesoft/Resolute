#pragma comment(linker, "/version:1.3") // MUST be in the form of major.minor

#include <windows.h>
#include "libs\SimpleString.h"

#define STR_WMIREPO TEXT("\\wbem\\Repository\\FS\\")
#define CCH_WMIREPO 20 // SSLen(STR_WMIREPO) == CCH_WMIREPO

#pragma comment(linker, "/entry:resetwmi")
int resetwmi( )
{
	TCHAR szPath[MAX_PATH << 1];
	PTSTR pszPathAppend = szPath;

	HANDLE hFind;
	WIN32_FIND_DATA finddata;

	// Build the root, part 1: Get the system directory
	UINT uSize = GetSystemDirectory(szPath, MAX_PATH);
	if (uSize < 4 || uSize >= MAX_PATH) return(1);
	pszPathAppend += uSize;

	// Build the root, part 2: Copy the repo path
	pszPathAppend = SSChainNCpy(pszPathAppend, STR_WMIREPO, CCH_WMIREPO);

	// Prepare the path for use by FindFirstFile
	SSCpy2Ch(pszPathAppend, TEXT('*'), 0);

	if ((hFind = FindFirstFile(szPath, &finddata)) != INVALID_HANDLE_VALUE)
	{
		do
		{
			if (!(finddata.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			{
				SSCpy(pszPathAppend, finddata.cFileName);
				MoveFileEx(szPath, NULL, MOVEFILE_DELAY_UNTIL_REBOOT);
			}

		} while (FindNextFile(hFind, &finddata));

		FindClose(hFind);
		return(0);
	}

	return(1);
}
