#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

ConsoleWrite('Windows => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_WINDOWS) & @CR)
ConsoleWrite('System => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_SYSTEM) & @CR)
ConsoleWrite('Fonts => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_FONTS) & @CR)
ConsoleWrite('Program Files => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_PROGRAM_FILES) & @CR)
ConsoleWrite('Profile => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_PROFILE) & @CR)
ConsoleWrite('My Documents => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_PERSONAL) & @CR)
ConsoleWrite('Start Menu => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_STARTMENU) & @CR)
ConsoleWrite('Favorites => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_FAVORITES) & @CR)
ConsoleWrite('Desktop => ' & _WinAPI_ShellGetSpecialFolderPath($CSIDL_DESKTOP) & @CR)
