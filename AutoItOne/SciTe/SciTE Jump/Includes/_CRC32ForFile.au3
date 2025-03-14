#include-once
#include <APIConstants.au3>
#include <WinAPIEx.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _CRC32ForFile
; Description ...: Calculates CRC32 value for the specific file.
; Syntax ........: _CRC32ForFile($sFilePath)
; Parameters ....: $sFilePath           - Full path to the file to process.
;                  $iPercentageRead     - [optional] Percentage of file to read. Default is 100.
; Return values .: Success - Returns CRC32 value in the form of a hex string
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - CreateFile function or call to it failed.
;                  |2 - CreateFileMapping function or call to it failed.
;                  |3 - MapViewOfFile function or call to it failed.
;                  |4 - RtlComputeCrc32 function or call to it failed.
; Author ........: trancexx
; Modified ......: guinness
; Link ..........: http://www.autoitscript.com/forum/topic/95558-crc32-md4-md5-sha1-for-files/
; Example .......: No
; ===============================================================================================================================
Func _CRC32ForFile($sFilePath, $iPercentageRead = 100)
	$iPercentageRead = Int($iPercentageRead)
	If ($iPercentageRead > 100) Or ($iPercentageRead <= 0) Then
		$iPercentageRead = 100
	EndIf
	$iPercentageRead = ($iPercentageRead / 100) * FileGetSize($sFilePath)
	Local $iError = 0
	Local Const $hFilePath = _WinAPI_CreateFileEx($sFilePath, $OPEN_EXISTING, $GENERIC_READ, BitOR($FILE_SHARE_READ, $FILE_SHARE_WRITE), $SECURITY_ANONYMOUS, 0, 0)
	If @error Then
		Return SetError(1, 0, '')
	EndIf

	Local Const $hFilePathMappingObject = _WinAPI_CreateFileMapping($hFilePath, 0, 0, $PAGE_READONLY)
	$iError = @error
	_WinAPI_CloseHandle($hFilePath)
	If $iError Then
		Return SetError(2, 0, '')
	EndIf

	Local Const $pFilePath = _WinAPI_MapViewOfFile($hFilePathMappingObject, 0, $iPercentageRead, $FILE_MAP_READ)
	$iError = @error
	_WinAPI_CloseHandle($hFilePathMappingObject)
	If $iError Then
		Return SetError(3, 0, '')
	EndIf

	Local Const $iBufferSize = $iPercentageRead ; FileGetSize($sFilePath)
	Local Const $iCRC32 = _WinAPI_ComputeCrc32($pFilePath, $iBufferSize)
	$iError = @error
	_WinAPI_UnmapViewOfFile($pFilePath)
	_WinAPI_CloseHandle($hFilePathMappingObject)
	If $iError Then
		Return SetError(4, 0, '')
	EndIf
	Return SetError(0, 0, Hex($iCRC32, 8))
EndFunc   ;==>_CRC32ForFile
