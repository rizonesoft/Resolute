#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sPath1 = 'C:\\Test\\'
Global Const $sPath2 = 'C:/Test/Test.txt'
Global Const $sPath3 = 'Notepad.exe'

ConsoleWrite($sPath1 & ' => ' & _WinAPI_PathSearchAndQualify($sPath1) & @CR)
ConsoleWrite($sPath2 & ' => ' & _WinAPI_PathSearchAndQualify($sPath2) & @CR)
ConsoleWrite($sPath3 & ' => ' & _WinAPI_PathSearchAndQualify($sPath3) & @CR)
