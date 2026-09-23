#include-once

Func _OpenActivation()
	ShellExecute(@SystemDir & "\oobe\msoobe", "/a")
EndFunc

Func _BackupActivation()
	Local $Result = 1
	_MemoLogWrite("Backing up Windows Product Activation database files.....")
	_MemoLogWrite("Your Activation Database will be located @ [" & $GBacDir & "\Activation]")

	FileSetAttrib($GBacDir & "\Activation\Activation.dbl", "-RASHOT")
	FileSetAttrib($GBacDir & "\Activation\Activation.bak", "-RASHOT")

	_MemoLogWrite("Backing up Windows Product Activation database files.....")
	If FileCopy(@SystemDir & "\wpa.dbl", $GBacDir & "\Activation\Activation.dbl", 9) = 0 Then $Result = 0
	If FileCopy(@SystemDir & "\wpa.bak", $GBacDir & "\Activation\Activation.bak", 9) = 0 Then $Result = 0
	If $Result = 1 Then
		_MemoLogWrite("Windows Product Activation database backup successful.", 1)
	Else
		_MemoLogWrite("Could not backup the Windows Product Activation database.", 2)
	EndIf
EndFunc

Func _RestoreActivation()
	Local $Result = 1

	If FileExists($GBacDir & "\Activation\Activation.dbl") And FileExists($GBacDir & "\Activation\Activation.bak") Then
		_MemoLogWrite("Restoring Windows Product Activation database files.....")
		FileSetAttrib(@SystemDir & "\wpa.dbl", "-RASHOT")
		FileSetAttrib(@SystemDir & "\wpa.bak", "-RASHOT")
		If Not FileExists(@SystemDir & "\wpadbl.nonactivated") Then
			If FileMove(@SystemDir & "\wpa.dbl", @SystemDir & "\wpadbl.nonactivated", 8) = 0 Then $Result = 0
		EndIf
		If Not FileExists(@SystemDir & "\wpabak.nonactivated") Then
			If FileMove(@SystemDir & "\wpa.bak", @SystemDir & "\wpabak.nonactivated", 8) = 0 Then $Result = 0
		EndIf
		If FileCopy($GBacDir & "\Activation\Activation.dbl", @SystemDir & "\wpa.dbl", 9) = 0 Then $Result = 0
		If FileCopy($GBacDir & "\Activation\Activation.bak", @SystemDir & "\wpa.bak", 9) = 0 Then $Result = 0
		If $Result = 1 Then
			_MemoLogWrite("Windows Product Activation database restore successful.", 1)
			_BootMessage()
		Else
			_MemoLogWrite("Could not restore the Windows Product Activation database.", 2)
		EndIf
	Else
		_MemoLogWrite("Could not find Windows Product Activation database backup.", 3)
		_MemoLogWrite("Backup Activation database first.", 3)
	EndIf

EndFunc

Func _OpenRecycleBin()
	ShellExecute("explorer.exe", "::{645FF040-5081-101B-9F08-00AA002F954E}")
EndFunc ; ==> _OpenRecycleBin

Func _ExploreRecycleBin()
	ShellExecute("explorer.exe", "/e,::{645FF040-5081-101B-9F08-00AA002F954E}")
EndFunc ; ==> _OpenRecycleBin

Func _OpenRecycleBinProperties()
	_ShowFileProperties("::{645FF040-5081-101B-9F08-00AA002F954E}")
EndFunc ; ==> _OpenRecycleBinProperties

Func _EmptyRecycleBin()
	_DisableControls()
	_MemoLogWrite("Clearing the Recycle Bin.....")
	FileRecycleEmpty()
	_RefreshRecycleBin()
	_MemoLogWrite("Recycle Bin Cleared.", 1)
	_EnableControls()
EndFunc ; ==> _EmptyRecycleBin

Func _BackupRegistry()
	_DisableControls()
	If FileExists($GERUNTEXE) Then
		_MemoLogWrite("Attempting to backup the registry.....")
		If Not FileExists($GRescueDir) Then DirCreate($GRescueDir)
		ShellExecute($GERUNTEXE, """" & $GRescueDir & """ /noconfirmdelete")

		_MemoLogWrite("Registry backup started.", 1)
		_MemoLogWrite("Your registry backup will be located @ " & $GRescueDir & ".", 1)
	Else
		_MemoLogWrite("Could not find ERUNT.EXE, This file is needed to perform a registry backup.", 2)
		_MemoLogWrite("You can download it from http://www.larshederer.homepage.t-online.de/erunt/", 2)
		_MemoLogWrite("After downloading extract all the files to the '" & $GERUNTEXE & "' directory.", 2)
	EndIf
	_EnableControls()
EndFunc

Func _RestoreRegistry()
	If FileExists($GERDNTEXE) Then
		ShellExecute($GERDNTEXE)
		_MemoLogWrite("Please don't try and restore a registry backup from another Windows installation.", 3)
		_MemoLogWrite("Doing so can damage your Windows installation beyond repair.", 3)
	Else
		_MemoLogWrite("Could not locate a registry backup. Backup the registry first.", 3)
	EndIf
EndFunc

Func _CreateSystemRestore()
	Opt("GUICloseOnESC",1)

	$FRPoint = GUICreate("Create System Restore Point", 410, 130, 199, 128, $WS_SIZEBOX, BitOr($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
	GUISetFont(8.5, 400, 0, "Verdana")
	;GUISetBkColor(0xEBEBEB)
	GUICtrlCreateGroup("Restore Point Name", 8, 10, 393, 89)
	$InRName = GUICtrlCreateInput("Rizone's Restore Point", 16, 30, 377, 21)
	$BCPoint = GUICtrlCreateButton("Create Restore Point", 15, 60, 200, 33, $WS_GROUP)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUISetState(@SW_SHOW, $FRPoint)

	GUISetOnEvent($GUI_EVENT_CLOSE, "CRestore_CLOSEClicked", $FRPoint)
	GUICtrlSetOnEvent($BCPoint, "_CRPointClicked")

EndFunc

Func CRestore_CLOSEClicked()
	GUIDelete(@GUI_WinHandle)
EndFunc

Func _CRPointClicked()
	_DisableControls()
	GUICtrlSetState($InRName, $GUI_DISABLE)
	GUICtrlSetState($BCPoint, $GUI_DISABLE)
	_CreateSystemRestorePoint(GUICtrlRead($InRName))
	GUICtrlSetState($InRName, $GUI_ENABLE)
	GUICtrlSetState($BCPoint, $GUI_ENABLE)
	_EnableControls()
EndFunc

Func _CreateSystemRestorePoint($RPointName)
	_MemoLogWrite("Creating System Restore Point.....")
	$OSRestore = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	If $OSRestore.createrestorepoint($RPointName, 0, 100) = 0 Then
		_MemoLogWrite("System Resore Point created called: """ & $RPointName & """ ", 1)
	Else
		_MemoLogWrite("It seems like System Restore is turned off.", 3)
		_MemoLogWrite("You need to enable System Restore first.", 3)
	EndIf
EndFunc   ;==>_CreateSystemRestorePoint

Func _OpenSystemRestore()
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
		_MemoLogWrite("Starting Windows System Restore.....")
		ShellExecute(@SystemDir & "\restore\rstrui.exe")
	Else
		_MemoLogWrite("Starting Windows System Restore.....")
		ShellExecute("rstrui.exe")
	EndIf
EndFunc

Func _ShowFileProperties($sFile, $sVerb = "properties", $hWnd = 0)

    Local Const $SEE_MASK_INVOKEIDLIST = 0xC
    Local Const $SEE_MASK_NOCLOSEPROCESS = 0x40
    Local Const $SEE_MASK_FLAG_NO_UI = 0x400
    Local $PropBuff, $FileBuff, $SHELLEXECUTEINFO

    $PropBuff = DllStructCreate("char[256]")
    DllStructSetData($PropBuff, 1, $sVerb)
    $FileBuff = DllStructCreate("char[256]")
    DllStructSetData($FileBuff, 1, $sFile)
    $SHELLEXECUTEINFO = DllStructCreate("int cbSize;long fMask;hwnd hWnd;ptr lpVerb;ptr lpFile;ptr lpParameters;ptr lpDirectory;" & _
                                        "int nShow;int hInstApp;ptr lpIDList;ptr lpClass;hwnd hkeyClass;int dwHotKey;hwnd hIcon;" & _
                                        "hwnd hProcess")

    DllStructSetData($SHELLEXECUTEINFO, "cbSize", DllStructGetSize($SHELLEXECUTEINFO))
    DllStructSetData($SHELLEXECUTEINFO, "fMask", $SEE_MASK_INVOKEIDLIST)
    DllStructSetData($SHELLEXECUTEINFO, "hwnd", $hWnd)
    DllStructSetData($SHELLEXECUTEINFO, "lpVerb", DllStructGetPtr($PropBuff, 1))
    DllStructSetData($SHELLEXECUTEINFO, "lpFile", DllStructGetPtr($FileBuff, 1))

    $aRet = DllCall("shell32.dll", "int", "ShellExecuteEx", "ptr", DllStructGetPtr($SHELLEXECUTEINFO))
    If $aRet[0] = 0 Then Return SetError(2, 0, 0)
    Return $aRet[0]

EndFunc
