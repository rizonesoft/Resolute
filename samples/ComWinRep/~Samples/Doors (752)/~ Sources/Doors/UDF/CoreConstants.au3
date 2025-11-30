#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once


Global Const $CORE_WINLAME = @ScriptDir & "\Structure\winLAME2010\winLAME.exe"
Global Const $CORE_DIVXREPAIR = @ScriptDir & "\Structure\DivXRepair.exe"
Global Const $CORE_MP3TAGTOOLS = @ScriptDir & "\Structure\mtt.exe"
Global Const $CORE_MP3REPAIR = @ScriptDir & "\Structure\MP3Repair\mp3val-frontend.exe"
Global Const $CORE_EVILPLAYER = @ScriptDir & "\Structure\EvilPlayer\Evil_Player.exe"
Global Const $CORE_HOMECINEMA = @ScriptDir & "\Structure\HomeCinema\mpc-hc.exe"

Global Const $FOUND_WINLAME = FileExists($CORE_WINLAME)
Global Const $FOUND_DIVXREPAIR = FileExists($CORE_DIVXREPAIR)
Global Const $FOUND_MP3TAGTOOLS = FileExists($CORE_MP3TAGTOOLS)
Global Const $FOUND_MP3REPAIR = FileExists($CORE_MP3REPAIR)
Global Const $FOUND_EVILPLAYER = FileExists($CORE_EVILPLAYER)
Global Const $FOUND_HOMECINEMA = FileExists($CORE_HOMECINEMA)