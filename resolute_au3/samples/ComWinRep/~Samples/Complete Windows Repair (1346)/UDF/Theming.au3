#include-once

Global Const $THEME_DIRECTORY = @ScriptDir & "\Theme"
Global Const $THEME_WAITANI = $THEME_DIRECTORY & "\Wait.ani"
Global Const $THEME_PROCANI = $THEME_DIRECTORY & "\Process.ani"
Global Const $THEME_PROCDOWN = $THEME_DIRECTORY & "\Globe16.ani"


Func _InitializeThemeFiles()
	If Not FileExists($THEME_DIRECTORY) Then DirCreate($THEME_DIRECTORY)
	FileInstall("Resources\Wait.ani", $THEME_WAITANI, 0)
	FileInstall("Resources\Process.ani", $THEME_PROCANI, 0)
	FileInstall("Resources\Globe16.ani", $THEME_PROCDOWN, 0)
EndFunc