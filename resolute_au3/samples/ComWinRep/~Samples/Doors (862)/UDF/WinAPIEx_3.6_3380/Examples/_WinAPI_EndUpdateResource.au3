#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sExe = @ScriptDir & '\MyProg.exe'

Global Const $tagICONRESDIR = 'byte Width;byte Height;byte ColorCount;byte Reserved;ushort Planes;ushort BitCount;dword BytesInRes;ushort IconId;'
Global Const $tagNEWHEADER = 'ushort Reserved;ushort ResType;ushort ResCount;' ; & $tagICONRESDIR[ResCount]

Global $hFile, $hUpdate, $tIcon, $pIcon, $sIcon, $tDir, $pDir, $tInfo, $tData, $iSize
Global $Count, $Bytes = 0, $ID = 400, $Error = 1

; Select icon to update resource
$sIcon = FileOpenDialog('Select File', @ScriptDir & '\Extras', 'Icon Files (*.ico)', 1 + 2, 'Script.ico')
If Not $sIcon Then
	Exit
EndIf

; Create simple executable file (MyProg.exe) in which will be added icon
If Not FileCopy(@ScriptDir & '\Extras\MyProg.exe', $sExe) Then
	MsgBox(16, 'Error', 'Unable to copy MyProg.exe or file already exist in the current directory.')
	Exit
EndIf

Do
	; Begin update resources
	$hUpdate = _WinAPI_BeginUpdateResource($sExe)
	If @error Then
		ExitLoop
	EndIf
	; Read .ico file as raw binary data into the structure
	$tIcon = DllStructCreate('ushort Reserved;ushort Type;ushort Count;byte[' & (FileGetSize($sIcon) - 6) & ']')
	$pIcon = DllStructGetPtr($tIcon)
	$hFile = _WinAPI_CreateFile($sIcon, 2, 2)
	If Not $hFile Then
		ExitLoop
	EndIf
	_WinAPI_ReadFile($hFile, $pIcon, DllStructGetSize($tIcon), $Bytes)
	_WinAPI_CloseHandle($hFile)
	If Not $Bytes Then
		ExitLoop
	EndIf
	; Add all icons from .ico file into the RT_ICON resources identified as 400, 401, etc., and fill group icons structure
	$Count = DllStructGetData($tIcon, 'Count')
	$tDir = DllStructCreate($tagNEWHEADER & 'byte[' & (14 * $Count) & ']')
	$pDir = DllStructGetPtr($tDir)
	DllStructSetData($tDir, 'Reserved', 0)
	DllStructSetData($tDir, 'ResType', 1)
	DllStructSetData($tDir, 'ResCount', $Count)
	For $i = 1 To $Count
		$tInfo = DllStructCreate('byte Width;byte Heigth;byte Colors;byte Reserved;ushort Planes;ushort BPP;dword Size;dword Offset', $pIcon + 6 + 16 * ($i - 1))
		$iSize = DllStructGetData($tInfo, 'Size')
		If Not _WinAPI_UpdateResource($hUpdate, $RT_ICON, $ID, 0, $pIcon + DllStructGetData($tInfo, 'Offset'), $iSize) Then
			ExitLoop 2
		EndIf
		$tData = DllStructCreate($tagICONRESDIR, $pDir + 6 + 14 * ($i - 1))
		DllStructSetData($tData, 'Width', DllStructGetData($tInfo, 'Width'))
		DllStructSetData($tData, 'Height', DllStructGetData($tInfo, 'Heigth'))
		DllStructSetData($tData, 'ColorCount', DllStructGetData($tInfo, 'Colors'))
		DllStructSetData($tData, 'Reserved', 0)
		DllStructSetData($tData, 'Planes', DllStructGetData($tInfo, 'Planes'))
		DllStructSetData($tData, 'BitCount', DllStructGetData($tInfo, 'BPP'))
		DllStructSetData($tData, 'BytesInRes', $iSize)
		DllStructSetData($tData, 'IconId', $ID)
		$ID += 1
	Next
	; Add new RT_GROUP_ICON resource named as "MAINICON"
	If Not _WinAPI_UpdateResource($hUpdate, $RT_GROUP_ICON, 'MAINICON', 0, $pDir, DllStructGetSize($tDir)) Then
		Exitloop
	EndIf
	$Error = 0
Until 1

; Save or discard changes of the resources within an executable file
If Not _WinAPI_EndUpdateResource($hUpdate, $Error) Then
	$Error = 1
EndIf

; Show message if an error occurred
If $Error Then
	MsgBox(16, 'Error', 'Unable to change resources.')
EndIf
