#include <Constants.au3>
#include <MsgBoxConstants.au3>

;
; AutoIt Version: 3.0
; Language:       English
; Platform:       Win9x/NT
; Author:         Jonathan Bennett (jon at autoitscript dot com)
; Modified:       mLipok, seadoggie01, argumentum
;
; Script Function:
;   Plays with the calculator.
;

_Example()
Exit
; Finished!

Func _Example()
    ; Prompt the user to run the script - use a Yes/No prompt with the flag parameter set at 4 (see the help file for more details)
    Local $iAnswer = MsgBox(BitOR($MB_YESNO, $MB_SYSTEMMODAL), "AutoIt Example", "This script will run the calculator and type in 2 x 4 x 8 x 16 and then quit.  Do you want to run it?")

    ; Check the user's answer to the prompt (see the help file for MsgBox return values)
    ; If "No" was clicked ($IDNO = 7) then exit the example function
    If $iAnswer = $IDNO Then
        MsgBox($MB_SYSTEMMODAL, "AutoIt", "OK.  Bye!")
        Return
    EndIf

    ; Run the calculator
    Run("calc.exe")

    ; Wait for the calculator to become active. The classname "CalcFrame" or "ApplicationFrameWindow" (Win11) is monitored instead of the window title
    Local $sClass = "[REGEXPCLASS:(?i)(SciCalc|CalcFrame|ApplicationFrameWindow)]"
    Local $hWindow = WinWaitActive($sClass)

    ; Now that the calculator window is active type the values 2 x 4 x 8 x 16
    ; Use AutoItSetOption to slow down the typing speed so we can see it
    AutoItSetOption("SendKeyDelay", 400)

    SendKeepActive($hWindow)
    Local $sString = "2*4*8*16="
    Sleep(1000)
	Send($sString)
    SendKeepActive("")

    Sleep(2000)

    ; Now quit by sending a "close" request to the calculator window using the classname
    WinClose($hWindow)

    ; Now wait for the calculator to close before continuing
    WinWaitClose($hWindow)
EndFunc   ;==>_Example
