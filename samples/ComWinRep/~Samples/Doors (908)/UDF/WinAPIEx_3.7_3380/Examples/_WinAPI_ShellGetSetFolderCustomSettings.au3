#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tSHFCS, $tIcon, $aIcon, $sPath

; Select folder
$sPath = FileSelectFolder('Select Folder', '', 0, @ScriptDir)
If Not $sPath Then
	Exit
EndIf

; Select icon
$aIcon = _WinAPI_PickIconDlg()
If Not IsArray($aIcon) Then
	Exit
EndIf

; Set icon to selected folder
$tSHFCS = DllStructCreate($tagSHFOLDERCUSTOMSETTINGS & 'wchar[' & (StringLen($aIcon[0]) + 1) & ']')
DllStructSetData($tSHFCS, 'Size', DllStructGetPtr($tSHFCS, 16) - DllStructGetPtr($tSHFCS))
DllStructSetData($tSHFCS, 'Mask', $FCSM_ICONFILE)
DllStructSetData($tSHFCS, 'IconFile', DllStructGetPtr($tSHFCS, 16))
DllStructSetData($tSHFCS, 'SizeIF', 260)
DllStructSetData($tSHFCS, 'IconIndex', $aIcon[1])
DllStructSetData($tSHFCS, 16, $aIcon[0])

_WinAPI_ShellGetSetFolderCustomSettings($sPath, $FCS_FORCEWRITE, $tSHFCS)
