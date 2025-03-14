#include <MsgBoxConstants.au3>

#RequireAdmin
ConsoleWrite("! TEST1" & @CRLF)
ConsoleWrite("+ TEST1" & @CRLF)
ConsoleWrite("- TEST1" & @CRLF)
ConsoleWrite("> TEST1" & @CRLF)

If IsAdmin() Then MsgBox($MB_SYSTEMMODAL, "", "The script is running with admin rights.")
