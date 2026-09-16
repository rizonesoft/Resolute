
Func _CheckCommandPrompt()

	If FileExists(@SystemDir & "\cmd.exe") Then

		If RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") = 1 Or _
		   RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") = 2 Then
			_MemoLogWrite("We detected that the Command Prompt on your computer is disabled.", 3)
			_MemoLogWrite("Enabling the Command Prompt.....")
			RegWrite("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD", "REG_DWORD", 0)
			If Not @error Then
				_MemoLogWrite("The Command Prompt should now be enabled", 1)
			EndIf
		EndIf

	EndIf

EndFunc

Func _StartCommandPrompt()

	If FileExists(@SystemDir & "\cmd.exe") Then

		If IniRead($PowerSettings, "Command", "CommandCompletion", 1) = 1 Then
			If Not RegRead("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "CompletionChar") = 9 Or Not _
				   RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "CompletionChar") = 9 Then
				_MemoLogWrite("Enabling Command Completion.....")
				RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "CompletionChar", "REG_DWORD", 9)
				RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "CompletionChar", "REG_DWORD", 9)
				If Not @error Then
					_MemoLogWrite("Command Completion enabled. (TAB)", 1)
				Else
					_MemoLogWrite("Command Completion could not be enabled.", 2)
				EndIf
			EndIf
		Else
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "CompletionChar")
			RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "CompletionChar")
		EndIf

		If IniRead($PowerSettings, "Command", "DirectoryCompletion", 1) = 1 Then
			If Not RegRead("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "PathCompletionChar") = 4 Or Not _
				   RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "PathCompletionChar") = 4 Then
				_MemoLogWrite("Enabling Directory Completion.....")
				RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "PathCompletionChar", "REG_DWORD", 4)
				RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "PathCompletionChar", "REG_DWORD", 4)
				If Not @error Then
					_MemoLogWrite("Directory Completion enabled. (Ctrl+D)", 1)
				Else
					_MemoLogWrite("Directory Completion could not be enabled.", 2)
				EndIf
			EndIf
		Else
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Command Processor", "PathCompletionChar")
			RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor", "PathCompletionChar")
		EndIf

		ShellExecute("cmd.exe", "/k " & Chr(34) & @ScriptDir & "\Command.bat" & Chr(34), @SystemDir)

	EndIf

EndFunc
