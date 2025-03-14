#include-once

; #INDEX# =======================================================================================================================
; Title .........: AutoIt3 Fatal Exit Codes
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Constants to format @exitCode set by Opt("SetExitCode", 1)
; Author(s) .....: Jpm
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

Global Const $EXITFATALCODES[81][2] = [ _
		[0x7FFFF068, '"EndWith" missing "With".'], _
		[0x7FFFF069, 'Badly formatted "Func" statement.'], _
		[0x7FFFF06A, '"With" missing "EndWith".'], _
		[0x7FFFF06B, 'Missing right bracket '')'' in expression.'], _
		[0x7FFFF06C, 'Missing operator in expression.'], _
		[0x7FFFF06D, 'Unbalanced brackets in expression.'], _
		[0x7FFFF06E, 'Error in expression.'], _
		[0x7FFFF06F, 'Error parsing function call.'], _
		[0x7FFFF070, 'Incorrect number of parameters in function call.'], _
		[0x7FFFF071, '"ReDim" used without an array variable.'], _
		[0x7FFFF072, 'Illegal text at the end of statement (one statement per line).'], _
		[0x7FFFF073, '"If" statement has no matching "EndIf" statement.'], _
		[0x7FFFF074, '"Else" statement with no matching "If" statement.'], _
		[0x7FFFF075, '"EndIf" statement with no matching "If" statement.'], _
		[0x7FFFF076, 'Too many "Else" statements for matching "If" statement.'], _
		[0x7FFFF077, '"While" statement has no matching "WEnd" statement.'], _
		[0x7FFFF078, '"WEnd" statement with no matching "While" statement.'], _
		[0x7FFFF079, 'Variable used without being declared.'], _
		[0x7FFFF07A, 'Array variable has incorrect number of subscripts or subscript dimension range exceeded.'], _
		[0x7FFFF07B, 'Variable subscript badly formatted.'], _
		[0x7FFFF07C, 'Subscript used on non-accessible variable.'], _
		[0x7FFFF07D, 'Too many subscripts used for an array.'], _
		[0x7FFFF07E, 'Missing subscript dimensions in "Dim" statement.'], _
		[0x7FFFF07F, 'No variable given for "Dim", "Local", "Global", "Static" or "Const" statement.'], _
		[0x7FFFF080, 'Expected a "=" operator in assignment statement.'], _
		[0x7FFFF081, 'Invalid keyword at the start of this line.'], _
		[0x7FFFF082, 'Array maximum size exceeded.'], _
		[0x7FFFF083, '"Func" statement has no matching "EndFunc".'], _
		[0x7FFFF084, 'Duplicate function name.'], _
		[0x7FFFF085, 'Unknown function name.'], _
		[0x7FFFF086, 'Unknown macro.'], _
		[0x7FFFF088, 'Unable to get a list of running processes.'], _
		[0x7FFFF08A, 'Invalid element in a DllStruct.'], _
		[0x7FFFF08B, 'Unknown option or bad parameter specified.'], _
		[0x7FFFF08C, 'Unable to load the internet libraries.'], _
		[0x7FFFF08D, '"Struct" statement has no matching "EndStruct".'], _
		[0x7FFFF08E, 'Unable to open file, the maximum number of open files has been exceeded.'], _
		[0x7FFFF08F, '"ContinueLoop" statement with no matching "While", "Do" or "For" statement.'], _
		[0x7FFFF090, 'Invalid file filter given.'], _
		[0x7FFFF091, 'Expected a variable in user function call.'], _
		[0x7FFFF092, '"Do" statement has no matching "Until" statement.'], _
		[0x7FFFF093, '"Until" statement with no matching "Do" statement.'], _
		[0x7FFFF094, '"For" statement is badly formatted.'], _
		[0x7FFFF095, '"Next" statement with no matching "For" statement.'], _
		[0x7FFFF096, '"ExitLoop/ContinueLoop" statements only valid from inside a For/Do/While loop.'], _
		[0x7FFFF097, '"For" statement has no matching "Next" statement.'], _
		[0x7FFFF098, '"Case" statement with no matching "Select" or "Switch" statement.'], _
		[0x7FFFF099, '"EndSelect" statement with no matching "Select" statement.'], _
		[0x7FFFF09A, 'Recursion level has been exceeded - AutoIt will quit to prevent stack overflow.'], _
		[0x7FFFF09B, 'Cannot make existing variables static.'], _
		[0x7FFFF09C, 'Cannot make static variables into regular variables.'], _
		[0x7FFFF09D, 'Badly formated Enum statement'], _
		[0x7FFFF09F, 'This keyword cannot be used after a "Then" keyword.'], _
		[0x7FFFF0A0, '"Select" statement is missing "EndSelect" or "Case" statement.'], _
		[0x7FFFF0A1, '"If" statements must have a "Then" keyword.'], _
		[0x7FFFF0A2, 'Badly formated Struct statement.'], _
		[0x7FFFF0A3, 'Cannot assign values to constants.'], _
		[0x7FFFF0A4, 'Cannot make existing variables into constants.'], _
		[0x7FFFF0A5, 'Only Object-type variables allowed in a "With" statement.'], _
		[0x7FFFF0A6, '"long_ptr", "int_ptr" and "short_ptr" DllCall() types have been deprecated.  Use "long*", "int*" and "short*" instead.'], _
		[0x7FFFF0A7, 'Object referenced outside a "With" statement.'], _
		[0x7FFFF0A8, 'Nested "With" statements are not allowed.'], _
		[0x7FFFF0A9, 'Variable must be of type "Object".'], _
		[0x7FFFF0AA, 'The requested action with this object has failed.'], _
		[0x7FFFF0AB, 'Variable appears more than once in function declaration.'], _
		[0x7FFFF0AC, 'ReDim array can not be initialized in this manner.'], _
		[0x7FFFF0AD, 'An array variable can not be used in this manner.'], _
		[0x7FFFF0AE, 'Can not redeclare a constant.'], _
		[0x7FFFF0AF, 'Can not redeclare a parameter inside a user function.'], _
		[0x7FFFF0B0, 'Can pass constants by reference only to parameters with "Const" keyword.'], _
		[0x7FFFF0B1, 'Can not initialize a variable with itself.'], _
		[0x7FFFF0B2, 'Incorrect way to use this parameter.'], _
		[0x7FFFF0B3, '"EndSwitch" statement with no matching "Switch" statement.'], _
		[0x7FFFF0B4, '"Switch" statement is missing "EndSwitch" or "Case" statement.'], _
		[0x7FFFF0B5, '"ContinueCase" statement with no matching "Select" or "Switch" statement.'], _
		[0x7FFFF0B6, 'Assert Failed!'], _
		[0x7FFFF0B8, 'Obsolete function/parameter.'], _
		[0x7FFFF0B9, 'Invalid Exitcode (reserved for AutoIt internal use).'], _
		[0x7FFFF0BA, 'Variable cannot be accessed in this manner.'], _
		[0x7FFFF0BB, 'Func reassign not allowed.'], _
		[0x7FFFF0BC, 'Func reassign on global level not allowed.'] _
		]
; ===============================================================================================================================
