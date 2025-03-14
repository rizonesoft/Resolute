-- ==>LUA example file for personal LUA scripts.
-- ==>Copy this file to your %USERPROFILE% directory
-------------------------------------------------------------------------------
-- required line ... do not remove
PersonalTools = EventClass:new(Common)
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- demo() LUA script
-- to be able to use this script you add the following to your SciTEUSer.properties (without the leading "--"):
--#x lua test func
--command.name.41.$(au3)=Test
--command.mode.41.$(au3)=subsystem:lua,savebefore:no
--command.shortcut.41.$(au3)=Ctrl+Shift+F
--command.41.$(au3)=InvokeTool PersonalTools.Demo
--
--------------------------------------------------------------------------------
function PersonalTools:Demo()
    editor:BeginUndoAction()
    local FirstLine = editor:LineFromPosition(editor.SelectionStart)
    local LastLine = editor:LineFromPosition(editor.SelectionEnd)
    local CurrentLine = FirstLine
    editor:GotoLine(FirstLine)
    while (CurrentLine <= LastLine) do
        editor:Home()
        if CurrentLine == FirstLine then
            editor:AddText('$s = "' )
        else
            editor:AddText('\t\t"' )
        end
        editor:LineEnd()
        if CurrentLine == LastLine then
            editor:AddText('"' )
        else
            editor:AddText('" & @CRLF & _' )
        end
        CurrentLine = CurrentLine + 1
        editor:LineDown()
    end
    editor:EndUndoAction()
end
