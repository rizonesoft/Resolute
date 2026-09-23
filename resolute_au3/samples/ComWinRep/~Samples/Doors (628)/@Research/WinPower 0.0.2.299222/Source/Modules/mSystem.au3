Func _LockWorkstation()
	ShellExecute("rundll32.exe", "user32.dll,LockWorkStation")
EndFunc

Func _StartRegistryEditor() ; Ctrl+Alt+R
	ShellExecute("regedit.exe", "", @WindowsDir)
EndFunc

Func _StartTaskManager()
	ShellExecute("taskmgr.exe", "", @SystemDir)
EndFunc

Func _ShowShutDownDialog()
	; An Undocumented dll function, thanks to nirsoft for revealing it... (and all those who posted it on google!)
	ShellExecute("rundll32.exe", "shell32.dll,#60")
EndFunc

Func _Shutdown()
	Switch @GUI_CtrlId
		Case $lpIcon[11]
			If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
				_ShowShutDownDialog()
			Else
				Shutdown(1)
			EndIf
		Case $SShutdown, $lPSShut
			_MemoLogWrite("Your computer is Shutting Down.....", 1)
			Shutdown(1)
		Case $SShutPower, $lPPower
			_MemoLogWrite("Your computer is Powering Down.....", 1)
			Shutdown(8)
		Case $SSReboot, $lPReboot
			_MemoLogWrite("Your computer is Rebooting.....", 1)
			Shutdown(2)
		Case $SSLogoff, $lPLogoff
			_MemoLogWrite("Your computer is Logging off.....", 1)
			Shutdown(0)
		Case $SSHibernate, $lPHibernate
			_MemoLogWrite("Your computer is going into Hibernation.....", 1)
			Shutdown(64)
		Case $SShutForce, $lPShutForce
			_MemoLogWrite("Your computer is being forced to Shutdown.....", 1)
			Shutdown(5)
		Case $SSRebForce, $lPRebForce
			_MemoLogWrite("Your computer is being forced to Reboot.....", 1)
			Shutdown(6)
	EndSwitch
EndFunc
