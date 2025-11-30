#cs

    Title:          WinAPI Extended UDF Library for AutoIt3
    Filename:       WinAPIEx.au3
    Description:    Additional variables, constants and functions for the WinAPI.au3
    Author:         Yashied
	Modified:		Derick Payne (Rizonesoft)
    Version:        3.3.8.0
    Requirements:   AutoIt v3.3 +, Developed/Tested on Windows XP Pro Service Pack 2 and Windows Vista/7
    Uses:           StructureConstants.au3, WinAPI.au3
    Note:           The library uses the following system DLLs:

                    Kernel32.dll
					Psapi.dll
					Shell32.dll
					User32.dll

    Available functions:

	_WinAPI_AboutDlg
	_WinAPI_EmptyWorkingSet
	_WinAPI_GetKeyState
	_WinAPI_ShellExtractIcon

   * Included in WinAPI.au3

#ce


#Include-once

#Include <WinAPI.au3>


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AboutDlg
; Description....: Displays a Windows About dialog box.
; Syntax.........: _WinAPI_AboutDlg ( $sTitle, $sName, $sText [, $hIcon [, $hParent]] )
; Parameters.....: $sTitle  - The title of the Windows About dialog box.
;                  $sName   - The first line after the text "Microsoft".
;                  $sText   - The text to be displayed in the dialog box after the version and copyright information.
;                  $hIcon   - Handle to the icon that the function displays in the dialog box.
;                  $hParent - Handle to a parent window.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ShellAbout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AboutDlg($sTitle, $sName, $sText, $hIcon = 0, $hParent = 0)

	Local $Ret = DllCall('shell32.dll', 'int', 'ShellAboutW', 'hwnd', $hParent, 'wstr', $sTitle & '#' & $sName, 'wstr', $sText, 'ptr', $hIcon)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AboutDlg


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EmptyWorkingSet
; Description....: Removes as many pages as possible from the working set of the specified process.
; Syntax.........: _WinAPI_EmptyWorkingSet ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; ===============================================================================================================================

Func _WinAPI_EmptyWorkingSet($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x001F0FFF, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EmptyWorkingSet', 'ptr', $hProcess[0])

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1

EndFunc   ;==>_WinAPI_EmptyWorkingSet


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyState
; Description....: Retrieves the status of the specified virtual key.
; Syntax.........: _WinAPI_GetKeyState ( $vKey )
; Parameters.....: $vKey   - Specifies a virtual key ($VK_*). If the desired virtual key is a letter or digit (A through Z,
;                            a through z, or 0 through 9).
; Return values..: Success - The value that specifies the status of the specified virtual key. If the high-order bit is 1, the key is
;                            down; otherwise, it is up. If the low-order bit is 1, the key is toggled. A key, such as the
;                            CAPS LOCK key, is toggled if it is turned on. The key is off and untoggled if the low-order bit is 0.
;                            A toggle key's indicator light (if any) on the keyboard will be on when the key is toggled, and off
;                            when the key is untoggled.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The key status returned from this function changes as a process reads key messages from its message queue.
;                  The status does not reflect the interrupt-level state associated with the hardware. Use the _WinAPI_GetAsyncKeyState()
;                  function to retrieve that information.
; Related........:
; Link...........: @@MsdnLink@@ GetKeyState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyState($vKey)

	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyState', 'int', $vKey)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetKeyState


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractIcon
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_ShellExtractIcon ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - The zero-based index of the icon to extract. If this value is a negative number, the function extracts
;                             the icon whose resource identifier is equal to the absolute value of $iIndex.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon
;                  and change to the specified dimension.
;
;                  When you are finished using the icon, destroy it using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ SHExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_ShellExtractIcon