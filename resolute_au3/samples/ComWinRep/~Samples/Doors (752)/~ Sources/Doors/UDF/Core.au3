#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <CoreConstants.au3>


Func _LaunchSomething($sPath)

	If FileExists($sPath) Then
		ShellExecute($sPath)
	EndIf

EndFunc


Func _CloseApplication($CurrentGUI, $ExitProcess = False)

	GUIDelete($CurrentGUI)

	If $ExitProcess = True Then
		Local $ProcessID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
		If $ProcessID Then ProcessClose($ProcessID)
	EndIf

	Exit

EndFunc