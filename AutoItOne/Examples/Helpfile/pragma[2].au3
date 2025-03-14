; use Out option to compile to a3x file
#pragma compile(Out, pragma[2].a3x)
#include <MsgBoxConstants.au3>

MsgBox($MB_ICONINFORMATION, @ScriptName, 'Is compiled ? ... ' & @Compiled)
