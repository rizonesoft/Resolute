; Start Avira AntiVir
Func _StartAviraAntiVir()
	Local $AviraEXE = @ProgramFilesDir & "\Avira\AntiVir Desktop\avcenter.exe"
	_StartSecuritySolution($AviraEXE, "http://www.free-av.com/en/products/1/avira_antivir_personal__free_antivirus.html")
EndFunc

; Start Microsoft Security Essentials
Func _StartSecurityEssentials()
	Local $MSSecEssEXE = @ProgramFilesDir & "\Microsoft Security Essentials\msseces.exe"
	_StartSecuritySolution($MSSecEssEXE, "http://www.microsoft.com/Security_Essentials/")
EndFunc

Func _UpdateSecurityEssentials()
	Local $MSSecEssUp = @ProgramFilesDir & "\Microsoft Security Essentials\Update.exe"
	If FileExists($MSSecEssUp) Then
		ShellExecute($MSSecEssUp)
	Else
		ShellExecute("http://www.microsoft.com/Security_Essentials/")
	EndIf
EndFunc

; Start Panda Cloud AntiVirus
Func _StartAvastAntiVirus()
	Local $avastEXE = @ProgramFilesDir & "\Alwil Software\Avast4\ashAvast.exe"
	_StartSecuritySolution($avastEXE, "http://www.avast.com/eng/avast_4_home.html")
EndFunc

; Start Panda Cloud AntiVirus
Func _StartPandaCloudAntiVirus()
	Local $PanCloudEXE = @ProgramFilesDir & "\Panda Security\Panda Cloud Antivirus\PSUNMain.exe"
	_StartSecuritySolution($PanCloudEXE, "http://www.cloudantivirus.com")
EndFunc

; Start AVG AntiVirus
Func _StartAVGAntiVirus()
	Local $AVGEXE = @ProgramFilesDir & "\AVG\AVG9\avgui.exe"
	_StartSecuritySolution($AVGEXE, "http://free.avg.com/ww-en/download?prd=afg")
EndFunc

; Start ESET Online AntiVirus Scanner
Func _StartESETOnlineScanner()
	Local $ESETOnlScan = @ProgramFilesDir & "\ESET\ESET Online Scanner\OnlineScannerApp.exe"
	If FileExists($ESETOnlScan) Then
		ShellExecute($ESETOnlScan)
	Else
		If FileExists($IEExplEXE) Then
			ShellExecute($IEExplEXE, "http://www.eset.com/onlinescan/")
		Else
			ShellExecute("http://www.eset.com/onlinescan/")
		EndIf
	EndIf
EndFunc

; Start Jotti's Malware Scan
Func _StartJottiMalwareScan()
	ShellExecute("http://virusscan.jotti.org")
EndFunc

; Start Kaspersky Virus File Scanner
Func _StartKasperskyScanner()
	ShellExecute("http://www.kaspersky.com/scanforvirus")
EndFunc

; Start Panda ActiveScan
Func _StartPandaActiveScan()
	If FileExists($IEExplEXE) Then
		ShellExecute($IEExplEXE, "http://www.pandasecurity.com/usa/homeusers/solutions/activescan/")
	Else
		ShellExecute("http://www.pandasecurity.com/usa/homeusers/solutions/activescan/")
	EndIf
EndFunc

Func _StartClamWinAntiVirus()
	ShellExecute($GClamWinEXE)
EndFunc

Func _StopMessengerSpam()

	If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Messenger", "Start") = 4 Then
		_MemoLogWrite("Enabling the Messenger Service.....")
		ShellExecuteWait("sc", "config messenger start= auto", "", "", @SW_HIDE)
		If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Messenger", "Start") = 4 Then
			_MemoLogWrite("The Messenger Service could not be enabled.", 2)
		Else
			_MemoLogWrite("The Messenger Service is now enabled.", 1)
		EndIf
		_MemoLogWrite("Starting the Messenger Service.....")
		If ShellExecuteWait("net", "start messenger", "", "", @SW_HIDE) = 0 Then
			_MemoLogWrite("Messenger Service started.", 1)
		Else
			_MemoLogWrite("The Messenger Service could not be started.", 3)
		EndIf
	Else
		_MemoLogWrite("Stopping the Messenger Service.....")
		If ShellExecuteWait("net", "stop messenger", "", "", @SW_HIDE) = 0 Then
			_MemoLogWrite("Messenger Service stopped.", 1)
		Else
			_MemoLogWrite("The Messenger Service could not be stopped or was not started in the first place.", 3)
		EndIf
		_MemoLogWrite("Disabling the Messenger Service.....")
		ShellExecuteWait("sc", "config messenger start= disabled", "", "", @SW_HIDE)
		If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Messenger", "Start") = 4 Then
			_MemoLogWrite("The Messenger Service is now disabled.", 1)
		Else
			_MemoLogWrite("The Messenger Service could not be disabled.", 2)
		EndIf
	EndIf
	_ConfigureSecurityMenus()
EndFunc

Func _ConfigureSecurityMenus()
	If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Messenger", "Start") = 4 Then
		GuiCtrlSetData($SecMsgSpam, "Enable &Messenger Spam")
	Else
		GuiCtrlSetData($SecMsgSpam, "Stop &Messenger Spam")
	EndIf
EndFunc

Func _StartSecuritySolution($EXE, $URL)
	If FileExists($EXE) Then
		ShellExecute($EXE)
	Else
		ShellExecute($URL)
	EndIf
EndFunc
