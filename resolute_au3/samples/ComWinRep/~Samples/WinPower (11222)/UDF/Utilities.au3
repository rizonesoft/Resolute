#include-once

; #FUNCTION# ====================================================================================================
; Name...........: _ReduceMemory
; Description ...: Reduce memory usage of process ID (PID) given.
; Syntax.........: _ReduceMemory($iPID = -1, $hPsAPIdll = 'psapi.dll', $hKernel32dll = 'kernel32.dll')
; Parameters ....: $BugProcess - Process to Close
; Return values .: $iPID - PID of process to reduce memory. If -1 reduce self memory usage.
;                  $hPsAPIdll - Optional handle to psapi.dll.
;                  $hKernel32dll - Optional handle To kernel32.dll.
; Requirement(s) : psapi.dll (Doesn't come with WinNT4 by default)
; Author(s) .....: w0uter,  Saunders (admin@therks.com)
; Modified.......: Venom (Rizone Technologies)
; Remarks .......: If @OSVersion = 'WIN_NT4' Then FileInstall('psapi.dll', @SystemDir & '\psapi.dll')
; Link ..........:
; Example .......:
; ===============================================================================================================
Func _ReduceMemory($iPID = -1, $hPsAPIdll = 'psapi.dll', $hKernel32dll = 'kernel32.dll')
    If $iPID <> -1 Then
        Local $aHandle = DllCall($hKernel32dll, 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
        Local $aReturn = DllCall($hPsAPIdll, 'int', 'EmptyWorkingSet', 'long', $aHandle[0])
        DllCall($hKernel32dll, 'int', 'CloseHandle', 'int', $aHandle[0])
    Else
        Local $aReturn = DllCall($hPsAPIdll, 'int', 'EmptyWorkingSet', 'long', -1)
    EndIf

    Return $aReturn[0]
EndFunc