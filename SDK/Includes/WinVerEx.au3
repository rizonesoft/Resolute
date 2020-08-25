ConsoleWrite((0x0A00 > 0x0601) & @CRLF)

Local $__WINVER_GetVersionExW = "0x" & Hex(__WINVER_GetVersionExW(), 4)
Local $__WINVER_RtlGetVersion = __WINVER_RtlGetVersion()

ConsoleWrite("$__WINVER_GetVersionExW" & @TAB & @TAB & $__WINVER_GetVersionExW & @CRLF)
ConsoleWrite("$__WINVER_RtlGetVersion" & @TAB & @TAB & $__WINVER_RtlGetVersion & @CRLF)

If $__WINVER_RtlGetVersion >= 0x0604 Then ; Current OS is "Win10 - Technical Preview" or up
    ConsoleWrite("+" & @TAB & $__WINVER_RtlGetVersion & @CRLF)
Else
    ConsoleWrite("-" & @TAB & $__WINVER_RtlGetVersion & @CRLF)
EndIf

