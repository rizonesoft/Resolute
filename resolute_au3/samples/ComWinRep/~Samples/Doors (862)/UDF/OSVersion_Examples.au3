#include <OSVersion.au3>

ConsoleWrite("Is Vista or Greater:  " & _OsVersionTest($VER_GREATER_EQUAL, 6) & @CRLF) ;~ $VER_GREATER_EQUAL = 3
ConsoleWrite("Is Win7:  " & _OsVersionTest(1, 6, 1) & @CRLF) ;~ $OSVER_EQUAL = 1
ConsoleWrite("Is Less that XP SP2:  " & _OsVersionTest(4, 5, 1, 2) & @CRLF) ;~ $OSVER_LESS = 4