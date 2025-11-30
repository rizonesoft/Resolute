#Region Header

#cs

    Title:          Rizonesoft Operating System Version UDF Library
    Filename:       OSVersion.au3
    Description:
    Author:         Rizonesoft (Derick Payne)
    Version:        3.3.8.0
    Requirements:
    Uses:
    Note:        	The library uses the following system DLLs:

					Kernel32.dll

					Windows Versions:

					Windows 7               6.1
					Windows Server 2008 R2  6.1
					Windows Server 2008     6.0
					Windows Vista           6.0
					Windows Server 2003 R2  5.2
					Windows Server 2003     5.2
					Windows XP              5.1
					Windows 2000            5.0

	Examples:

	ConsoleWrite("Is Vista or Greater:  " & _OsVersionTest($VER_GREATER_EQUAL, 6) & @CRLF)
	ConsoleWrite("Is Win7:  " & _OsVersionTest($VER_EQUAL, 6, 1) & @CRLF)
	ConsoleWrite("Is Less that XP SP2:  " & _OsVersionTest($VER_LESS, 5, 1, 2) & @CRLF

    Available functions:

    _OsVersionTest
	_VersionCompare

#ce

#Include-once

#EndRegion Header


#Region Initialization
#EndRegion Initialization


#Region Global Variables and Constants

; dwTypeBitMask
;~ Global Const $OSVER_BUILDNUMBER = 0x0000004
;~ Global Const $OSVER_MAJORVERSION = 0x0000002
;~ Global Const $OSVER_MINORVERSION = 0x0000001
;~ Global Const $OSVER_PLATFORMID = 0x0000008
;~ Global Const $OSVER_PRODUCT_TYPE = 0x0000080
;~ Global Const $OSVER_SERVICEPACKMAJOR = 0x0000020
;~ Global Const $OSVER_SERVICEPACKMINOR = 0x0000010
;~ Global Const $OSVER_SUITENAME = 0x0000040
; dwConditionMask
;~ Global Const $OSVER_EQUAL = 1
;~ Global Const $OSVER_GREATER = 2
;~ Global Const $OSVER_GREATER_EQUAL = 3
;~ Global Const $OSVER_LESS = 4
;~ Global Const $OSVER_LESS_EQUAL = 5
; if dwTypeBitMask is VER_SUITENAME
;~ Global Const $OSVER_AND = 6
;~ Global Const $OSVER_OR = 7

#EndRegion Global Variables and Constants


#Region Local Variables and Constants
#EndRegion Local Variables and Constants


#Region Public Functions

; #FUNCTION# ;===============================================================================
; Name...........: _OsVersionTest
; Description ...: Compares OS Version Info
; Syntax.........: _OsVersionTest($iTest, $osMajor, $osMinor = 0, $spMajor = 0, $spMinor = 0)
; Parameters ....: $iTest       - type of test to perform
;                  $osMajor     - OS major version number
;                  $osMinor     - OS minor version number
;                  $spMajor     - service pack major version number
;                  $spMinor     - service pack minor version number
; Return values .: Success      - Returns nonzero value if the comparison is true, 0 if it is false
;                  Failure      - Sets @Error
;                  Return values:
;                  | 1          - Check @Extended
;                  | 2          - GetLastError failed, we have no way to know the outcome of the function
;                  @Extended holds the source of @Error:
;                  | 1          - DllCall error
;                  | 2          - Function error from GetLastError
; Author ........: Erik Pilsits
; Modified.......: Rizonesoft (Derick Payne)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ;==========================================================================================
Func _OsVersionTest($iTest, $osMajor, $osMinor = 0, $spMajor = 0, $spMinor = 0)

    Local Const $OSVERSIONINFOEXW = "dword dwOSVersionInfoSize;dword dwMajorVersion;dword dwMinorVersion;dword dwBuildNumber;dword dwPlatformId;" & _
                                    "wchar szCSDVersion[128];ushort wServicePackMajor;ushort wServicePackMinor;ushort wSuiteMask;byte wProductType;byte wReserved"
    Local $dwlConditionalMask = 0
    ; initialize structure
    Local $OSVI = DllStructCreate($OSVERSIONINFOEXW)

    DllStructSetData($OSVI, "dwOSVersionInfoSize", DllStructGetSize($OSVI))
    ; set data we want to compare
    DllStructSetData($OSVI, "dwMajorVersion", $osMajor)
    DllStructSetData($OSVI, "dwMinorVersion", $osMinor)
    DllStructSetData($OSVI, "wServicePackMajor", $spMajor)
    DllStructSetData($OSVI, "wServicePackMinor", $spMinor)

    ; check AutoIt version
    ; -1 = version 2 is greater...this is bad, DllCall() int64 return was fixed in 3.3.1.0
    Local $IsBadAutoIt = (_VersionCompare(@AutoItVersion, "3.3.1.0") = -1)

    ; initialize and set the mask
    __VerSetConditionMask(0x0000002, $iTest, $dwlConditionalMask, $IsBadAutoIt) ;~ $OSVER_MAJORVERSION = 0x0000002
    __VerSetConditionMask(0x0000001, $iTest, $dwlConditionalMask, $IsBadAutoIt) ;~ $OSVER_MINORVERSION = 0x0000001
    __VerSetConditionMask(0x0000020, $iTest, $dwlConditionalMask, $IsBadAutoIt) ;~ $OSVER_SERVICEPACKMAJOR = 0x0000020
    __VerSetConditionMask(0x0000010, $iTest, $dwlConditionalMask, $IsBadAutoIt) ;~ $OSVER_SERVICEPACKMINOR = 0x0000010

    ; perform test
    Return __VerifyVersionInfo(DllStructGetPtr($OSVI), BitOR(0x0000002, 0x0000001, 0x0000020, 0x0000010), $dwlConditionalMask)
	;~ $OSVER_MAJORVERSION = 0x0000002, $OSVER_MINORVERSION = 0x0000001, $OSVER_SERVICEPACKMAJOR = 0x0000020, $OSVER_SERVICEPACKMINOR = 0x0000010

EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _VersionCompare
; Description ...: Compares two file versions for equality
; Syntax.........: _VersionCompare($sVersion1, $sVersion2)
; Parameters ....: $sVersion1   - IN - The first version
;                  $sVersion2   - IN - The second version
; Return values .: Success      - Following Values:
;                  | 0          - Both versions equal
;                  | 1          - Version 1 greater
;                  |-1          - Version 2 greater
;                  Failure      - @error will be set in the event of a catasrophic error
; Author ........: Valik
; Modified.......:
; Remarks .......: This will try to use a numerical comparison but fall back on a lexicographical comparison.
;                  See @extended for details about which type was performed.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _VersionCompare($sVersion1, $sVersion2)

	If $sVersion1 = $sVersion2 Then Return 0

	Local $sep = "."

	If StringInStr($sVersion1, $sep) = 0 Then $sep = ","

	Local $aVersion1 = StringSplit($sVersion1, $sep)
	Local $aVersion2 = StringSplit($sVersion2, $sep)

	If UBound($aVersion1) <> UBound($aVersion2) Or UBound($aVersion1) = 0 Then
		; Compare as strings
		SetExtended(1)
		If $sVersion1 > $sVersion2 Then
			Return 1
		ElseIf $sVersion1 < $sVersion2 Then
			Return -1
		EndIf
	Else
		For $i = 1 To UBound($aVersion1) - 1
			; Compare this segment as numbers
			If StringIsDigit($aVersion1[$i]) And StringIsDigit($aVersion2[$i]) Then
				If Number($aVersion1[$i]) > Number($aVersion2[$i]) Then
					Return 1
				ElseIf Number($aVersion1[$i]) < Number($aVersion2[$i]) Then
					Return -1
				EndIf
			Else ; Compare the segment as strings
				SetExtended(1)
				If $aVersion1[$i] > $aVersion2[$i] Then
					Return 1
				ElseIf $aVersion1[$i] < $aVersion2[$i] Then
					Return -1
				EndIf
			EndIf
		Next
	EndIf

	; This point should never be reached
	Return SetError(2, 0, 0)

EndFunc   ;==>_VersionCompare

#EndRegion Public Functions


#EndRegion Internal Functions

Func __VerSetConditionMask($dwTypeBitMask, $dwConditionMask, ByRef $dwlConditionalMask, $IsBadAutoIt)

    Local $ret = DllCall("Kernel32.dll", "uint64", "VerSetConditionMask", "uint64", $dwlConditionalMask, "dword", $dwTypeBitMask, "byte", $dwConditionMask)

	If Not @error Then
        If $IsBadAutoIt Then
            ; fix for bad DllCall() int64 return value
            $dwlConditionalMask = __ReOrderULONGLONG($ret[0])
        Else
            $dwlConditionalMask = $ret[0]
        EndIf
    EndIf

EndFunc

Func __VerifyVersionInfo($lpVersionInfo, $dwTypeMask, $dwlConditionalMask)

    Local Const $ERROR_OLD_WIN_VERSION = 1150
    ; dwTypeMask is a BitOR'd combination of the conditions we want to test
    Local $ret = DllCall("Kernel32.dll", "int", "VerifyVersionInfoW", "ptr", $lpVersionInfo, "dword", $dwTypeMask, "uint64", $dwlConditionalMask)

	If Not @error Then
        ; test for function error
        If $ret[0] Then
            Return $ret[0] ; comparison is true
        Else
            ; function returned 0, we have to check GetLastError to see if there was an error
            $ret = DllCall("Kernel32.dll", "dword", "GetLastError")
            If Not @error Then
                If $ret[0] = $ERROR_OLD_WIN_VERSION Then
                    Return 0 ; no error, the version comparison was false
                Else
                    Return SetError($ret[0], 2, 1) ; we have a real error
                EndIf
            Else
                Return SetError(1, 0, 2) ; this would suck, but shouldn't happen
            EndIf
        EndIf
    Else
        Return SetError(@error, 1, 1) ; DllCall error
    EndIf

EndFunc

Func __ReOrderULONGLONG($UINT64)

    Local $s_uint64 = DllStructCreate("uint64")
    Local $s_ulonglong = DllStructCreate("ulong;ulong", DllStructGetPtr($s_uint64))

    DllStructSetData($s_uint64, 1, $UINT64)

    Local $val = DllStructGetData($s_ulonglong, 1)

    DllStructSetData($s_ulonglong, 1, DllStructGetData($s_ulonglong, 2))
    DllStructSetData($s_ulonglong, 2, $val)

    Return DllStructGetData($s_uint64, 1)

EndFunc

#EndRegion Internal Functions