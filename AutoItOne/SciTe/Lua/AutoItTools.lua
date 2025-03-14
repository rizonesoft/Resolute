--------------------------------------------------------------------------------
-- This library contains tools specific to AutoIt.
--
-- NOTE: Names in parenthesis indicate which tool a function or lines of code
-- belong to.  The tools are not listed by function name, merely feature name.
--
-- Current tools:
--	UserList - Invoke FunctionList() to display a user list of all functions
--	in the active file.
--------------------------------------------------------------------------------
AutoItTools = EventClass:new(Common)

--------------------------------------------------------------------------------
-- OnStartup()
--
-- Initializes variables.
--------------------------------------------------------------------------------
function AutoItTools:OnStartup()
	-- The pattern to search for.  This pattern is applied across the entire
	-- document.  The empty capture at the beginning returns the position,
	-- useful for getting the line number.
	-- NOTE: This will not match a function on the first line of the file
	-- unless it has whitespace before it.
	self.Pattern = "()[%s][Ff][Uu][Nn][Cc][%s]+([%w%s_]*%(.-%))"

	-- The list seperator. (UserList)
	self.Seperator = ";"
	self.SeperatorByte = self.Seperator:byte()
	-- The unique ID identifying our user list. (UserList)
	self.ID = 12
	-- Specifies the marker type to use (default: Bookmark).
	self.Marker = 1
	-- A table where the keys are the function strings and the values are the
	-- line where the string is found. (UserList)
	self.DataTable = { }

	--Load keywords table used by propercase
	f = io.open(props['SciteDefaultHome'].."\\api\\au3.api")
	if f ~= nil then
		self.ProperWords = f:read('*a')
		f:close()
		-- remove the ?x at the end of the lines of each keyword record
		self.ProperWords = string.gsub(self.ProperWords,"?%d","")
		self.l_ProperWords = string.lower(self.ProperWords)
	else
		self.ProperWords = ""
	end
	-- Check for Beta and set the BETA_AUTOIT= in au3.properties to the correct value
	f = io.open(props['SciteDefaultHome'].."\\..\\beta\\au3check.dat")
	if f ~= nil then
		-- Beta Exists
		f:close()
		for cmd  = 0, 50, 1 do
			if props['command.'..cmd..'.beta'] ~= '' then
				props['command.name.'..cmd..'.$(au3)']=props['command.'..cmd..'.beta']
--~ 				print('beta command.name.'..cmd..'.$(au3)=' .. props['command.name.'..cmd..'.$(au3)'])
			end
		end

--~		print("Beta exists.")
	else
		for cmd  = 0, 50, 1 do
			if props['command.'..cmd..'.beta'] ~= '' then
				props['command.name.'..cmd..'.$(au3)']=''
--~ 				print('no Beta command.name.'..cmd..'.$(au3)=' .. props['command.name.'..cmd..'.$(au3)'])
			end
		end
--~		print("Beta missing.")
	end
end	-- OnStartup()

--------------------------------------------------------------------------------
-- FunctionList()
--
-- Iterates over the document building a list of functions and displaying them
-- in a user list.
--
-- Tool: AutoItTools.FunctionsList $(au3) savebefore:no Ctrl+L List Functions
--------------------------------------------------------------------------------
function AutoItTools:FunctionsList()
	-- Local table used to build the list of strings.
	local data = { }
	-- Process the entire document at once.
	local doc = "\n" .. editor:GetText()
	for pos, str in doc:gmatch(self.Pattern) do
		-- If we have a multi-line function definition, show it all on one line.
		str = str:gsub("[\r\n]*", "")
		-- Insert the string into both tables.
		table.insert(data, str)
		self.DataTable[str] = editor:LineFromPosition(pos)
	end
	-- Sort the table and build a string out of it.
	table.sort(data, function(a, b) return string.lower(a) < string.lower(b) end)
	local list = table.concat(data, self.Seperator)
	-- Store the seperator, set our new one, show the list and restore the
	-- original seperator.
	local old_seperator = editor.AutoCSeparator
	editor.AutoCSeparator = self.SeperatorByte
	editor:ScrollCaret()
	editor:UserListShow(self.ID, list)
	editor.AutoCSeparator = old_seperator
end	-- FunctionsList

--------------------------------------------------------------------------------
-- OnUserListSelection(id, str)
--
-- Marks the current line and jumps to the line containing the selected
-- function.
--
-- Parameters:
--	id - The ID of the event to make sure it is ours.
--	str - The selected item.
--
-- Returns:
--	The value true if the event was for us.
--------------------------------------------------------------------------------
function AutoItTools:OnUserListSelection(id, str)
	if id == self.ID then
		-- Look up the line we jump to using the string as the table key.
		local line = self.DataTable[str]
		if line then
			-- Clear our marker and set a new one.
			editor:MarkerDeleteAll(self.Marker)
			editor:MarkerAdd(editor:LineFromPosition(editor.CurrentPos), self.Marker)
			editor:GotoLine(line)
			editor:EnsureVisible(line)
		end
		return true
	end
end	-- OnUserListSelection()

--------------------------------------------------------------------------------
-- InsertRegion()
--
-- Inserts #Region...#EndRegion around the selected text.
--
-- Tool: AutoItTools.InsertRegion $(au3) savebefore:no,groupundo:yes Ctrl+Alt+R Insert Region
--------------------------------------------------------------------------------
function AutoItTools:InsertRegion()
	local nl = self:NewLineInUse()
	local word = self:GetWord()
	local name = word:match("Func ([%w_]*)")
	if name == nil then
		name = ""
	else
		name = name .. "()"
	end
	pos = editor.SelectionStart
	editor:ReplaceSel("#Region " .. name .. nl .. word .. nl .. "#EndRegion " .. name)
	editor:SetSel(pos, pos)
end	-- InsertRegion()

--------------------------------------------------------------------------------
-- DebugMsgBoxAdd()
--
-- Add debug MsgBox to the selected text (original by Jos van der Zande).
--
-- Tool: AutoItTools.DebugMsgBoxAdd $(au3) savebefore:no,groupundo:yes Alt+D Debug: Add MsgBox
--------------------------------------------------------------------------------
function AutoItTools:DebugMsgBoxAdd()
	local word = self:GetWord2()
	if word == "" then
		print("Cursor not on any text.")
		return
	end
	local word = word:gsub("\r", "")     -- remove CR
	local word = word:gsub("\n", "")     -- remove LF
	local word2 = word:gsub("'", "''")     -- replace quote by 2 quotes
	local line = editor:LineFromPosition(editor.CurrentPos) + 1
	editor:LineEnd()
	editor:NewLine()
--~ 	editor:AddText("MsgBox(262144, 'Debug line ~" .. line .. "' , \'" .. word2 .. "\:' & @CRLF & " .. word .. ") ;### Debug MSGBOX" )
	local option = tonumber(props['debug.msgbox.option'])
	if option == 2 then
		editor:AddText("MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & \'" .. word2 .. "\' & @CRLF & @CRLF & 'Return:' & @CRLF & " .. word .. " & @CRLF & @CRLF & '@error:' & @CRLF & @error & @CRLF & @CRLF & '@extended:' & @CRLF & @extended & ' (0x' & Hex(@extended) & ')') ;### Debug MSGBOX" )
	elseif option == 1 then
		editor:AddText("MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & \'" .. word2 .. "\' & @CRLF & @CRLF & 'Return:' & @CRLF & " .. word .. " & @CRLF & @CRLF & '@error:' & @CRLF & @error) ;### Debug MSGBOX" )
	elseif option == 0 then
		editor:AddText("MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & \'" .. word2 .. "\' & @CRLF & @CRLF & 'Return:' & @CRLF & " .. word .. ") ;### Debug MSGBOX" )
	elseif option == -1 then
		editor:AddText("MsgBox(262144, 'debug line ~' & @ScriptLineNumber, \'" .. word2 .. ":' & @CRLF & " .. word .. ") ;### Debug MSGBOX" )
	end
	editor:LineDown()
	editor:Home()
end	-- DebugMsgBoxAdd()

--------------------------------------------------------------------------------
-- DebugConsoleWriteAdd()
--
-- Add debug ConsoleWrite to the selected text (original by Jos van der Zande).
--
-- Tool: AutoItTools.DebugConsoleWriteAdd $(au3) savebefore:no,groupundo:yes Ctrl+D Debug: Add ConsoleWrite
--------------------------------------------------------------------------------
function AutoItTools:DebugConsoleWriteAdd()
	local word = self:GetWord2()
	if word == "" then
		print("Cursor not on any text.")
		return
	end
	local word = word:gsub("\r", "")     -- replace quote by 2 quotes
	local word = word:gsub("\n", "")     -- replace quote by 2 quotes
	local word2 = word:gsub("'", "''")     -- replace quote by 2 quotes
	local line = editor:LineFromPosition(editor.CurrentPos) + 1
	editor:LineEnd()
	editor:NewLine()
--~ 	editor:AddText("ConsoleWrite('@@ (" .. line .. ") :(' & @min & ':' & @sec & ') " .. word2 .. " = ' & " .. word .. " & @CRLF) ;### Debug Console")
	local option = tonumber(props['debug.console.option'])
	if option == 3 then
		editor:AddText("ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : " .. word2 .. " = ' & " .. word .. " & @CRLF & '>Error code: ' & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended)  & ')    SystemTime: ' & @hour & ':' & @min & ':' & @sec & @CRLF) ;### Debug Console" )
	elseif option == 2 then
		editor:AddText("ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : " .. word2 .. " = ' & " .. word .. " & @CRLF & '>Error code: ' & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended) & ')' & @CRLF) ;### Debug Console" )
	elseif option == 1 then
		editor:AddText("ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : " .. word2 .. " = ' & " .. word .. " & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console" )
	elseif option == 0 then
		editor:AddText("ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : " .. word2 .. " = ' & " .. word .. " & @CRLF) ;### Debug Console" )
	elseif option == -1 then
		editor:AddText("ConsoleWrite('@@ (' & @ScriptLineNumber & ') :(' & @min & ':' & @sec & ') " .. word2 .. " = ' & " .. word .. " & @CRLF) ;### Debug Console" )
	end
	editor:LineDown()
	editor:Home()
end	-- DebugConsoleWriteAdd()

--------------------------------------------------------------------------------
-- OldCodeMark()
--
-- Comments out the selected text and names the section "Old Code".
--
-- Tool: AutoItTools.OldCodeMark $(au3) savebefore:no,groupundo:yes Alt+M Mark Old Code
--------------------------------------------------------------------------------
function AutoItTools:OldCodeMark()
	local word = self:GetWord()
 	if word ~= "" then
		editor:ReplaceSel("#cs Old Code")
		editor:NewLine()
		editor:AddText(word)
		editor:NewLine()
		editor:AddText("#ce Old Code")
	end
end	-- OldCodeMark()

--------------------------------------------------------------------------------
-- OldCodeGoto()
--
-- Jumps to the first line of old code in the document.
--
-- Tool: AutoItTools.OldCodeGoto $(au3) savebefore:no Alt+N Goto Old Code
--------------------------------------------------------------------------------
function AutoItTools:OldCodeGoto()
	local doc = editor:GetText()
	local pos = doc:find("#cs Old Code")
	if pos then
		editor:GotoLine(editor:LineFromPosition(pos))
	else
		print("No Old Code sections found.")
	end
end -- OldCodeGoto()

--------------------------------------------------------------------------------
-- CreateFunctionHeader(s, p)
--
-- Creates a function header for an AutoIt 3 function.
--
-- Parameters:
--  s - The name of a function.
--  p - The parameters to the function.
--
-- Returns:
--  A string containing the function header.
--------------------------------------------------------------------------------
function AutoItTools:CreateFunctionHeader(s, p)
    -- Change these :)
    local defAuthor = props['UDFCreator']    -- Initial Author value
    local defLineMax = 129                   -- Max length of line. AutoIt standard is 129.
    local defSplit = 21                      -- Default index for '-' after param.

    local nl = self:NewLineInUse()

    local outStart   = "FUNCTION"
    local outName    = s
    local outDesc    = ""
    local outSyntax  = ""
    local outParams  = ""
    local outReturn  = "None"
    local outAuthor  = defAuthor
    local outModify  = ""
    local outRemarks = ""
    local outRelated = ""
    local outLink    = ""
    local outExample = "No"

    local name = s
    local params = string.gsub(p, "[Ff][Uu][Nn][Cc].-%((.*)%)","(%1)")

    if name:sub(0, 2) == "__" then
        outStart = "INTERNAL_USE_ONLY"
    end

    outSyntax = name .. "("

    local paramSynt = ""
    local iOptionals = 0
    local fBroken = false
    local sModifiers = ""
    if params ~= "()" and params ~= nil then
        for byref, parameter, optional in string.gmatch(params, "(%w-%s*%w*)%s*($[%w_]+)%s*[=]?%s*(.-)[,%)]") do
            if parameter ~= "" and parameter ~= nil then
                if outParams ~= "" then
                    outParams = outParams .. nl .. ";" .. string.rep(" ", 18)
                end

                outParams = outParams .. parameter .. string.rep(" ", defSplit - string.len(parameter)) .. "- "

                sModifiers = ""
                if optional ~= "" and optional ~= nil then
                    outParams = outParams .. "[optional] "

                    if paramSynt ~= "" then
                        paramSynt = paramSynt .. "[, "
                    else
                        paramSynt = paramSynt .. "["
                    end

                    iOptionals = iOptionals + 1
                else
                    byref = string.gsub(byref:lower(), "%s", "")
                    if byref ~= "" then
                        if byref == "byref" then
                            outParams = outParams .. "[in/out] "
                            sModifiers = "Byref "
                        else
                            if byref == "const" then
                                outParams = outParams .. "[const] "
                                sModifiers = "Const "
                            else
                                if byref == "byrefconst" or byref == "constbyref" then
                                    outParams = outParams .. "[in/out and const] "
                                    sModifiers = "Const Byref "
                                else
                                    print("Unrecognised parameter modifiers: '" .. byref .. "'")
                                end
                            end
                        end
                    end

                    if paramSynt ~= "" then
                        paramSynt = paramSynt .. ", "
                    end
                end

                if fBroken then
                    if string.len(paramSynt) + string.len(parameter) + iOptionals + 2 + 19 > defLineMax then
                        outSyntax = outSyntax .. paramSynt .. nl .. ";" .. string.rep(" ", 18)
                        paramSynt = ""
                        fBroken = true
                    end
                else
                    if string.len(outSyntax) + string.len(paramSynt) + string.len(parameter) + iOptionals + 2 + 19 > defLineMax then
                        outSyntax = outSyntax .. paramSynt .. nl .. ";" .. string.rep(" ", 18)
                        paramSynt = ""
                        fBroken = true
                    end
                end
                paramSynt = paramSynt .. sModifiers .. parameter

                if optional ~= "" and optional ~= nil then
                    paramSynt = paramSynt .. " = " .. optional
                end

                local paramtype = parameter:sub(2, 2)
                local isarray = false
                if paramtype == "a" then
                    paramtype = parameter:sub(3, 3)
                    isarray = true
                end

                local sAdd
                if paramtype == "i" then
                    sAdd = "integer"
                elseif parameter:sub(2, 3) == "fu" then
                    sAdd = "function (first class object)"
                elseif parameter:sub(2, 4) == "tag" then
                    sAdd = "structures definition"
                elseif paramtype == "f" then
                    sAdd = "floating point"
                elseif paramtype == "b" then
                    sAdd = "boolean"
                elseif paramtype == "d" then
                    sAdd = "binary variant"
                elseif paramtype == "n" then
                    sAdd = "general number"
                elseif paramtype == "s" then
                    sAdd = "string"
                elseif paramtype == "h" then
                    sAdd = "handle"
                elseif paramtype == "m" then
                    sAdd = "map"
                elseif paramtype == "v" then
                    sAdd = "variant"
                elseif paramtype == "o" then
                    sAdd = "object"
                elseif paramtype == "id" then
                    sAdd = "AutoIt controlid"
                elseif paramtype == "p" then
                    sAdd = "pointer"
                elseif paramtype == "t" then
                    sAdd = "dll struct"
                else
                    sAdd = "unknown"
                end

                if isarray then
                    outParams = outParams .. "an array of " .. sAdd .. "s."
                else
                    if sAdd == 'object' then
                        outParams = outParams .. "an " .. sAdd .. "."
                    elseif sAdd == 'map' then
                        outParams = outParams .. "a " .. sAdd .. "."
                    elseif sAdd == 'structures definition' then
                        outParams = outParams .. "a " .. sAdd .. "."
                    elseif sAdd == 'function (first class object)' then
                        outParams = outParams .. "" .. sAdd .. "."

                    else
                        if sAdd:sub(1, 1):find("[AEIOUaeiou]") ~= nil then
                            outParams = outParams .. "an " .. sAdd .. " value."
                        else
                            outParams = outParams .. "a " .. sAdd .. " value."
                        end
                    end
                end

                if optional ~= "" and optional ~= nil then
                    outParams = outParams .. " Default is " .. optional .. "."
                end
            end
        end
    else
        outParams = "None"
    end

    outSyntax = outSyntax .. paramSynt .. string.rep("]", iOptionals) .. ")"

    local res = "; #" .. outStart .. "# " .. string.rep("=", defLineMax - 5 - outStart:len()) .. nl
    res = res .. "; Name ..........: " .. outName .. nl
    res = res .. "; Description ...: " .. outDesc .. nl
    res = res .. "; Syntax ........: " .. outSyntax .. nl
    res = res .. "; Parameters ....: " .. outParams .. nl
    res = res .. "; Return values .: " .. outReturn .. nl
    res = res .. "; Author ........: " .. outAuthor .. nl
    res = res .. "; Modified ......: " .. outModify .. nl
    res = res .. "; Remarks .......: " .. outRemarks .. nl
    res = res .. "; Related .......: " .. outRelated .. nl
    res = res .. "; Link ..........: " .. outLink .. nl
    res = res .. "; Example .......: " .. outExample .. nl
    res = res .. "; " .. string.rep("=", defLineMax - 2) .. nl

    return res
end -- CreateFunctionHeader()

--------------------------------------------------------------------------------
-- CreateStructureHeader(s, p)
--
-- Creates a structure header for an AutoIt 3 struct.
--
-- Parameters:
--  s - The name of a structure.
--  p - The complete structure definition.
--
-- Returns:
--  A string containing the structure header.
--------------------------------------------------------------------------------
function AutoItTools:CreateStructureHeader(s, p)
    local defAuthor = props['UDFCreator']    -- Initial Author value

    local defLineMax = 129                   -- Max length of line. AutoIt standard is 129.
    local defSplit = 21                      -- Default index for '-' after param.

    local nl = self:NewLineInUse()

    local outStart   = "STRUCTURE"
    local outName    = s
    local outDesc    = ""
    local outFields  = ""
    local outAuthor  = defAuthor
    local outRemarks = ""
    local outRelated = ""

    local str
    if p ~= "" and p ~= nil then
        p = p:sub(p:find("[\"']"), -1)

        for sect in string.gmatch(p, "%s*(.-)%s*[;\"']") do

            if sect:match("[Aa][Ll][Ii][Gg][Nn]%s+%d+") then
                -- Align statement: Ignore
            else
                str = sect:match("^%s*&%s*$([%w_]+)%s&%s*$")
                if str ~= nil then
                    -- Substruct

                    if outFields ~= "" then
                        outFields = outFields .. nl .. ";" .. string.rep(" ", 18)
                    end

                    outFields = outFields .. str .. string.rep(" ", defSplit - string.len(str)) .. "- A $" .. str .. " structure."
                else
                    if sect == nil or sect == "" or sect:upper() == "STRUCT" or sect:upper() == "ENDSTRUCT" then
                        -- Substruct or empty: Ignore
                    else
                        local datatype, name = sect:match("^(.-)%s+(.-)$")

                        if outFields ~= "" then
                            outFields = outFields .. nl .. ";" .. string.rep(" ", 18)
                        end

                        outFields = outFields .. name .. string.rep(" ", defSplit - string.len(name)) .. "- "

                        if datatype:sub(1, 1):find("[AEIOUaeiou]") ~= nil then
                            outFields = outFields .. "An "
                        else
                            outFields = outFields .. "A "
                        end

                        outFields = outFields .. datatype .. " value."
                    end
                end
            end

        end
    end

    local res = "; #" .. outStart .. "# " .. string.rep("=", defLineMax - 5 - outStart:len()) .. nl
    res = res .. "; Name ..........: " .. outName .. nl
    res = res .. "; Description ...: " .. outDesc .. nl
    res = res .. "; Fields ........: " .. outFields .. nl
    res = res .. "; Author ........: " .. outAuthor .. nl
    res = res .. "; Remarks .......: " .. outRemarks .. nl
    res = res .. "; Related .......: " .. outRelated .. nl
    res = res .. "; Link ..........: " .. nl
    res = res .. "; " .. string.rep("=", defLineMax - 2) .. nl
    return res
end -- CreateStructureHeader

--------------------------------------------------------------------------------
-- InsertFunctionHeader()
--
-- Generates a function header and inserts it into the document.
--
-- Tool: AutoItTools.InsertFunctionHeader $(au3) savebefore:no,groupundo:yes Alt+U Insert Function Header
--------------------------------------------------------------------------------
function AutoItTools:InsertFunctionHeader()
    local line, pos = editor:GetCurLine()
    local pos = editor.CurrentPos - pos
    local lineNum = editor:LineFromPosition(pos)
    local from, to, name = line:find("[Ff][Uu][Nn][Cc]%s+([%w%s_]*)")
    local struct = false

    if to == nil then
        from, to, name = line:find("[Gg][Ll][Oo][Bb][Aa][Ll]%s+[Cc][Oo][Nn][Ss][Tt]%s+($[%w_]+)")
        struct = true
        if to == nil then
            print("Function or struct definition not found, unable to insert header. Ensure your cursor in on a Func or Global Struct line!")
            return
        end
    end

    -- remove comments from the line
    from, to =  line:find(";")
    while from ~= nil do
        -- print(pos+from .. " type:" .. editor.StyleAt[pos+from])
        if editor.StyleAt[pos+from] == SCE_AU3_COMMENT then
            line = string.sub (line, 1 , from-1)   -- remove comment
            from = nil                             -- exit loop
        else
            from, to =  line:find(";",from+1)      -- find next ; as this one is not a comment
        end
    end
    -- print(" line:" .. line)
    local pfrom, pto = line:find("%(")    -- check for opening parenthesis
    if struct then
        pfrom, pto = line:find("[\"']")
    end

    if pto ~= nil then
        local i = 0
        local tmp
        while line:find("%s+_%s*$") do    -- found a line continuation
            line = line:gsub("%s+_%s*$", "")    -- remove it
            i = i + 1
            pos = editor:PositionFromLine(lineNum+i)    -- set new position
            tmp = editor:GetLine(lineNum+i)
            -- remove comments from the line
            from, to =  tmp:find(";")
            while from ~= nil do
                -- print(pos+from .. " type:" .. editor.StyleAt[pos+from])
                if editor.StyleAt[pos+from] == SCE_AU3_COMMENT then
                    tmp = string.sub (tmp, 1 , from-1)   -- remove comment
                    from = nil                             -- exit loop
                else
                    from, to =  tmp:find(";",from+1)      -- find next ; as this one is not a comment
                end
            end
            tmp = tmp:gsub("^%s*", "")    -- remove leading white space
            line = line .. tmp
        end
        editor:Home()
        line = line:gsub("[\r\n]", "")    -- remove line breaks
        line = line:gsub("[\"']%s*&%s*[\"']", "") -- remove string joins
        if name:sub(1, 1) == "$" then
            editor:AddText(self:CreateStructureHeader(name, line))
        else
            editor:AddText(self:CreateFunctionHeader(name, line))
        end
    else
        print("Argument list not found, unable to insert header.")
	end
end -- InsertFunctionHeader()
--------------------------------------------------------------------------------
-- ConsoleWritePattern(with_comment)
--
-- Returns the pattern used to find DebugConsoleWrite statements.  This must be
-- a function so NewLineInUse() can be called on the correct document.
--
-- Paramters:
--	with_comment - If true, returns the pattern with a leading comment.
--
-- Returns:
--	The pattern used to find DebugConsoleWrite statements.
--------------------------------------------------------------------------------
function AutoItTools:ConsoleWritePattern(with_comment)
	local nl = self:NewLineInUse()
	if with_comment then
		return nl .. "[ \t]*;[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Debug[^" .. nl .. "]+)"
	else
		return nl .. "[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Debug[^" .. nl .. "]+)"
	end
end	-- ConsoleWritePattern()

--------------------------------------------------------------------------------
-- MsgBoxPattern(with_comment)
--
-- Returns the pattern used to find DebugMsgBox statements.  This must be
-- a function so NewLineInUse() can be called on the correct document.
--
-- Paramters:
--	with_comment - If true, returns the pattern with a leading comment.
--
-- Returns:
--	The pattern used to find DebugMsgBox statements.
--------------------------------------------------------------------------------
function AutoItTools:MsgBoxPattern(with_comment)
	local nl = self:NewLineInUse()
	if with_comment then
		return nl .. "[ \t]*;[ \t]*(MsgBox%([^" .. nl .. "]-%)[ \t]*;### Debug[^" .. nl .. "]+)"
	else
		return nl .. "[ \t]*(MsgBox%([^" .. nl .. "]-%)[ \t]*;### Debug[^" .. nl .. "]+)"
	end
end	-- MsgBoxPattern()

--------------------------------------------------------------------------------
-- DebugComment()
--
-- Comment all Debug lines.
--
-- Tool: AutoItTools.DebugComment $(au3) savebefore:no,groupundo:yes Ctrl+Shift+D Debug: Comment all lines
--------------------------------------------------------------------------------
function AutoItTools:DebugComment()
	-- Callback function.
	local function pat_match(m1)
		return self:NewLineInUse() .. ";\t" .. m1
	end
	-- Perform replacement.
	self:ReplaceDocByPattern(self:ConsoleWritePattern(), pat_match)
	self:ReplaceDocByPattern(self:MsgBoxPattern(), pat_match)
end	-- DebugComment()

--------------------------------------------------------------------------------
-- DebugUncomment()
--
-- Uncomment all Debug lines.
--
-- Tool: AutoItTools.DebugUncomment $(au3) savebefore:no,groupundo:yes Ctrl+Alt+D Debug: Uncomment all lines
--------------------------------------------------------------------------------
function AutoItTools:DebugUncomment()
	-- Callback function.
	local function pat_match(m1)
		return self:NewLineInUse() .. m1
	end
	-- Perform replacement.
	self:ReplaceDocByPattern(self:ConsoleWritePattern(true), pat_match)
	self:ReplaceDocByPattern(self:MsgBoxPattern(true), pat_match)
end	-- DebugUncomment()

--------------------------------------------------------------------------------
-- DebugRemove()
--
-- Remove all Debug MsgBox/Console lines.
--
-- Tool: AutoItTools.DebugRemove $(au3) savebefore:no,groupundo:yes Ctrl+Alt+Shift+D Debug: Remove all lines
--------------------------------------------------------------------------------
function AutoItTools:DebugRemove()
	-- Callback function.
	local function pat_match()
		return ""
	end
	-- Remove any commented functions first
	self:DebugUncomment()
	-- Perform replacement.
	self:ReplaceDocByPattern(self:ConsoleWritePattern(), pat_match)
	self:ReplaceDocByPattern(self:MsgBoxPattern(), pat_match)
end	-- DebugRemove()
--------------------------------------------------------------------------------
-- FunctionTracePattern(with_comment)
--
-- Returns the pattern used to find FunctionTrace statements.  This must be
-- a function so NewLineInUse() can be called on the correct document.
--
-- Paramters:
--	with_comment - If true, returns the pattern with a leading comment.
--
-- Returns:
--	The pattern used to find FunctionTrace statements.
--------------------------------------------------------------------------------
function AutoItTools:FunctionTracePattern(with_comment)
	local nl = self:NewLineInUse()
	if with_comment then
		return nl .. "[ \t]*;[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Trace[^" .. nl .. "]+)"
	else
		return nl .. "[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Trace[^" .. nl .. "]+)"
	end
end	-- FunctionTracePattern()

--------------------------------------------------------------------------------
-- FunctionTraceAdd()
--
-- Inserts a ConsoleWrite() for each function.
--
-- Tool: AutoItTools.FunctionTraceAdd $(au3) savebefore:no,groupundo:yes Ctrl+T Debug: Add Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:FunctionTraceAdd()
    -- Pattern to match
    local sPattern = "()([Ff][Uu][Nn][Cc]%s+([%w_]*)%(.-%))([^\r\n]*)"

    -- Used as a counter in pat_match to offset the line numbers
    local i = 0
    -- Callback function.  If the comment "FunctionTraceSkip" is found after
    -- the closing ), then that function will not get a trace statement added.
    local function pat_match(m1, m2, m3, m4)
        if editor.StyleAt[m1] == SCE_AU3_COMMENT or
            editor.StyleAt[m1] == SCE_AU3_COMMENTBLOCK or
            m4:find(";[ \t]*[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn][Tt][Rr][Aa][Cc][Ee][Ss][Kk][Ii][Pp]") then
            return m2 .. m4
        end
        i = i + 1
        return m2 .. m4 .. self:NewLineInUse() .. "\tConsoleWrite('@@ (" .. editor:LineFromPosition(m1)+i .. ") :(' & @MIN & ':' & @SEC & ') " .. m3 .. "()' & @CR) ;### Trace Function"
    end
    -- Remove any previous traces so we don't get duplicates
    self:FunctionTraceRemove()
    -- Perform replacement
    self:ReplaceDocByPattern(sPattern, pat_match)
end    -- FunctionTraceAdd()
--------------------------------------------------------------------------------
-- FunctionTraceRemove()
--
-- Remove all Function Trace statements.
--
-- Tool: AutoItTools.FunctionTraceRemove $(au3) savebefore:no,groupundo:yes Ctrl+Alt+Shift+T Debug: Remove Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:FunctionTraceRemove()
	-- Callback function.
	local function pat_match()
		return ""
	end
	-- Remove any commented functions first
	self:FunctionTraceUncomment()
	-- Perform replacement
	self:ReplaceDocByPattern(self:FunctionTracePattern(), pat_match)
end	-- FunctionTraceRemove()

--------------------------------------------------------------------------------
-- FunctionTraceComment()
--
-- Comment all Function Trace statements.
--
-- Tool: AutoItTools.FunctionTraceComment $(au3) savebefore:no,groupundo:yes Ctrl+Shift+T Debug: Comment Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:FunctionTraceComment()
	-- Callback function.
	local function pat_match(m1)
		return self:NewLineInUse() .. ";\t" .. m1
	end
	-- Perform replacement
	self:ReplaceDocByPattern(self:FunctionTracePattern(), pat_match)
end	-- FunctionTraceComment()

--------------------------------------------------------------------------------
-- FunctionTraceUncomment()
--
-- Uncomment all Function Trace statements.
-- Tool: AutoItTools.FunctionTraceUncomment $(au3) savebefore:no,groupundo:yes Ctrl+Alt+T Debug: Uncomment Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:FunctionTraceUncomment()
	-- Callback function.
	local function pat_match(m1)
		return self:NewLineInUse() .. "\t" .. m1
	end
	-- Perform replacement
	self:ReplaceDocByPattern(self:FunctionTracePattern(true), pat_match)
end	-- FunctionTraceUncomment()

--------------------------------------------------------------------------------
-- GetWord2()
--
-- Alternate GetWord() implementation specific to AutoIt.  If the caret is on a
--	function, the entire function call is returned.
--
--	If a word can be found, it is returned, otherwise an empty string.
--------------------------------------------------------------------------------
function AutoItTools:GetWord2()
	local word = editor:GetSelText()
	if word == "" then
		-- When on an ( or space, go to the start of the previous word.
		if editor.CharAt[editor.CurrentPos] == 40 or editor.CharAt[editor.CurrentPos] == 32 then
			editor:WordLeft()
		end
		-- Cache the style as it's used numerous times.
		local style = editor.StyleAt[editor.CurrentPos]
		-- The start and end of the text range.
		local from = editor:WordStartPosition(editor.CurrentPos)
		local to = editor:WordEndPosition(editor.CurrentPos)
		-- Use a variable to shorten the for loop code.
		local line = editor:LineFromPosition(editor.CurrentPos)
		-- Caret is on a function.
		if style == SCE_AU3_FUNCTION or style == SCE_AU3_DEFAULT or style == SCE_AU3_UDF then
			-- A counter of the number of opening brackets encountered.
			local brackets = 0
			-- A flag set to true if an opening bracket is encountered.
			local found = false
			-- Iterate the line looking for the end of the function call.
			for i = editor.CurrentPos, editor.LineEndPosition[line] do
				-- Make sure we don't count brackets in strings.
				if editor.StyleAt[i] ~= SCE_AU3_STRING then
					-- Found an opening bracket, increment counter and set flag.
					if editor.CharAt[i] == 40 then
						brackets = brackets + 1
						found = true
					end
					-- Found a closing bracket, decrement counter.
					if editor.CharAt[i] == 41 then
						brackets = brackets - 1
					end
				end
				-- We found a bracket and we found the end, set to and break.
				if found and brackets == 0 then
					to = i + 1
					break
				end
			end
			-- If we didn't find any brackets, just return the simple GetWord().
			if not found then
				return self:GetWord()
			end
		-- Caret is in a string.
		elseif style == SCE_AU3_STRING then
			-- Find the start of the string.  To do this, we iterate backwards
			-- to the indentation.
			for i = editor.CurrentPos, editor.LineIndentPosition[line] - 1, -1 do
				if editor.StyleAt[i] ~= SCE_AU3_STRING then
					-- We have to add 1 or we'll pick up the non-string
					-- character as well.
					from = i + 1
					break
				end
			end
			-- Find the end of the string.  To do this, we iterate forwards to
			-- the end of the string.
			for i = editor.CurrentPos, editor.LineEndPosition[line] do
				if editor.StyleAt[i] ~= SCE_AU3_STRING then
					to = i
					break
				end
			end
		end
		-- Get the text range.
		word = editor:textrange(from, to)
	end
	return word
end    -- GetWord2()

--------------------------------------------------------------------------------
-- ValidateFunctions()
--
-- Validates a function has the proper comment header and #Region section.
--
-- Tool: AutoItTools.ValidateFunctions $(au3) savebefore:no Ctrl+Alt+V Validate Functions
--------------------------------------------------------------------------------
function AutoItTools:ValidateFunctions()
	local doc = "\n" .. editor:GetText()

	for pos, str in doc:gmatch(self.Pattern) do
		-- We need to concatenate multi-line function definitions into a single
		-- line.
		str = str:gsub("_%s-" .. self:NewLineInUse() .. "%s*", "")
		local pattern = "; " .. str .. self:NewLineInUse() .. ";" .. self:NewLineInUse()
		local func = str:match("^(.-)[%(%s]")
		local intro = "@@ (" .. editor:LineFromPosition(pos) + 1 .. ") :(" .. os.date("%I:%S") .. ") "
		-- Validate function header
		if not doc:find(pattern, 1, true) then
			self:DebugPrint("Pattern\r\n|" .. pattern .. "|")
			print(intro .. "Function header not present or out of sync for: " .. func)
		end
		-- Validate #Region
		if not doc:find("#Region " .. func .. "()", 1, true) then
			print(intro .. "#Region missing for: " .. func)
		end
		-- Validate EndFunc
		if not doc:find("[Ee][Nn][Dd][Ff][Uu][Nn][Cc]\t; " .. func .. "()") then
			print(intro .. "Incorrect EndFunc comment for: " .. func .. "\tExpected: EndFunc\t; " .. func .. "()")
		end
	end
	print("Validate Functions for " .. props["FileNameExt"] .. " is complete.")
end	-- ValidateFunctions()

--------------------------------------------------------------------------------
-- ExportLibrary()
--
-- Creates an exports section in an AutoIt file containing comments describing
-- 	the functions in the file.
--
-- Tool: AutoItTools.ExportLibrary $(au3) savebefore:no,groupundo:yes Ctrl+Alt+E Export Library
--------------------------------------------------------------------------------
function AutoItTools:ExportLibrary()
	-- These are constants used throughout.
	local region_text = "#Region Members Exported"
	local comment_start = "#cs Exported Functions"
	local comment_end = "#ce Exported Functions"
	local nl = self:NewLineInUse()

	-- We work over the entire document.
	local doc = editor:GetText()
	if not doc:find(region_text, 1, true) then
		print("Error: Unable to find \"" .. region_text .. "\" in the library, no export list created.")
	else
		local from, to, found = false
		if not doc:find(comment_start, 1, true) then
			print("Warning: Unable to find \"" .. comment_start .. "\" in the library, there may be multiple export lists.")
			from = doc:match(region_text .. nl .. "()")
			to = from
		else
			from = doc:match(comment_start .. nl .. "()")
			to = doc:match("()" .. comment_end)
			found = true
		end
		-- This should never happen due to the checks above.
		if not from or not to then
			print("Error, unable to determine where to add the export list.")
		else
			-- Store the list in this variable.
			local text = ""
			-- We only build the list for functions we can find in the code.
			-- Orphaned comments will not be found.
			for pos, str in doc:gmatch(self.Pattern) do
				-- Pull the name out of string so we can build a pattern.
				local name = str:match("^(.-)[%(%s]")
				-- First check that the name doesn't start with __ which means
				-- it's private.
				if not str:find("^__") then
					-- Build the pattern.  It's a bit complicated to keep it
					-- from running over lines it shoudn't.
					local pattern = ";%s+(" .. name .. "%s*%([^" .. nl .. "]+)" .. nl .. ";%s+;(.-);%s+Parameters"
					-- Get the two parts.
					local func, desc = doc:match(pattern)
					-- Ensure they are valid.
					if func and desc then
						-- Clean up the text, put on a single line, remove trailing spaces.
						func = func:gsub("%s*$", "")	-- Trailing spaces
						desc = desc:gsub("%s*;%s*", " ")	-- Multiple lines
						desc = desc:gsub("^%s*", "")	-- Leading spaces
						desc = desc:gsub("%s*$", "")	-- Trailing spaces
						-- Concatenate the formatted text.
						text = text .. func .. " - " .. desc .. nl
					end
				end
			end
			-- We have to offset our indices because SciTE is 0-based while Lua
			-- strings are 1-based.
			editor:SetSel(from - 1, to -1)
			-- If the exports section already exists, we are replacing it.
			if found then
				editor:ReplaceSel(text)
			-- Otherwise, we have to insert the exports section.
			else
				editor:ReplaceSel(comment_start .. nl .. text .. comment_end .. nl)
			end
			print("Exports list created. ")
		end
	end
end	-- ExportLibrary()

-- *****************  Extra's **************************************************************************************************************************************
--------------------------------------------------------------------------------
-- OnChar(c)
--
-- Controls propercase Keywords.Functions and Abbreviation expansion
--
-- Parameters:
--	c - The character typed.
--------------------------------------------------------------------------------
function AutoItTools:OnChar(c)
--~ 	print("Char:" .. c)
	if editor.Lexer == SCLEX_AU3 then
		-- set propercase
		if props['proper.case'] == '1' and string.find(c, "[ =(]") then
			self:ProperCase(c)
		end
		-- abbreviations logic will auto expand on space when SCE_AU3_EXPAND. written by Jos van der Zande (Jos)
		local ls = editor.StyleAt[editor.CurrentPos-2]
		if ls == SCE_AU3_EXPAND and c == " "  then
			self:Abbreviations(1)
		end
	end
end -- OnChar()


--------------------------------------------------------------------------------
-- TracePattern(with_comment)
--
-- Returns the pattern used to find FunctionTrace statements.  This must be
-- a function so NewLineInUse() can be called on the correct document.
--
-- Paramters:
--	with_comment - If true, returns the pattern with a leading comment.
--
-- Returns:
--	The pattern used to find FunctionTrace statements.
--------------------------------------------------------------------------------
function AutoItTools:TracePattern(with_comment)
	local nl = self:NewLineInUse()
	if with_comment then
		return nl .. "[ \t]*;[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Trace[^" .. nl .. "]+)"
	else
		return nl .. "[ \t]*(ConsoleWrite%([^" .. nl .. "]-%)[ \t]*;### Trace[^" .. nl .. "]+)"
	end
end	-- TracePattern()

--------------------------------------------------------------------------------
-- TraceAdd()
--
-- Inserts a ConsoleWrite() for each function.
--
-- Tool: AutoItTools.FunctionTraceAdd $(au3) 2 Ctrl+T Debug: Add Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:TraceAdd()
	editor:BeginUndoAction()
	local sels = editor.SelectionStart
	local sele = editor.SelectionEnd
	--   when nothing is selected then Whole script
	if sels==sele then
		AutoItTools:FunctionTraceRemove()    -- Remove any previous traces so we don't get duplicates
		sels = 0
		sele = editor.Length
	end
	local FirstLine = editor:LineFromPosition(sels)
	local LastLine = editor:LineFromPosition(sele)
	local CurrentLine = FirstLine
	editor:GotoLine(FirstLine)
	PrevLineCont = 0
	while (CurrentLine <= LastLine) do
		local LineCode = editor:GetLine(editor:LineFromPosition(editor.CurrentPos))
		local LineCodeprev = editor:GetLine(editor:LineFromPosition(editor.CurrentPos)-1)
		-- Avoid adding a line ontop on the first line in the editor.Anchor
		if CurrentLine == 0 then
			LineCode = ""
			LineCodeprev = ""
		end
		-- fill LineCode with "" when nul to avoid function errors
		if LineCode == nul then LineCode = "" end
		-- Skip the Select and Switch statements since the trow an error with AU3Check
		place = string.find(LineCodeprev, "%#*[Ss][Ee][Ll][Ee][Cc][Tt]" )
		if place then LineCode = ""  end
		place = string.find(LineCodeprev, "%#*[Ss][Ww][Ii][Tt][Cc][Hh]" )
		if place then LineCode = ""  end
		-- Skip the debug consolewrite lines
		place = string.find(LineCode, "ConsoleWrite%('@@" )
		if place then LineCode = "" end
		-- Skip the line contains test for @error else it could break logic
		place = string.find(LineCode, "@[Ee][Rr][Rr][Oo][Rr]" )
		-- Skip the line contains test for @extended else it could break logic
		place = string.find(LineCode, "@[Ee][Xx][Tt][Ee][Nn][Dd][Ee][Dd]" )
		if place then LineCode = "" end
		-- Remove CRLF
		LineCode = string.gsub(LineCode,"\r\n","")
		-- Only go WordRight when its not already on a Keyword and LineCode not Empty
		if editor.StyleAt[editor.CurrentPos] ~= SCE_AU3_KEYWORD and LineCode ~= "" then
			editor:WordRight()
		end
		ls = editor.StyleAt[editor.CurrentPos]
		--_ALERT("ls:" .. ls .. "   line:|" .. LineCode .. "|")
		if LineCode ~= "" and ls ~= SCE_AU3_COMMENTBLOCK and ls ~= SCE_AU3_COMMENT and ls ~= SCE_AU3_STRING and ls ~= SCE_AU3_PREPROCESSOR and ls ~= SCE_AU3_SPECIAL then
			editor:LineEnd()
			editor:CharLeft()
			-- check for continuation lines since that would create a syntax error
			if editor.CharAt[editor.CurrentPos] == 95 and editor.StyleAt[editor.CurrentPos] ~= SCE_AU3_COMMENT then
				CurLineCont = 1
			else
				CurLineCont = 0
			end
			if LineCode ~= "" and PrevLineCont == 0 then
				LineCode = 	string.gsub(LineCode,"'","''")
				cl = editor:LineFromPosition(editor.CurrentPos) +2
				editor:Home()
				--- mhz's proposal
				local option = tonumber(props['debug.trace.option'])
				if option == 3 then
					editor:AddText("ConsoleWrite('>Error code: ' & @error & '    Extended code: ' & @extended & '    SystemTime: ' & @hour & ':' & @min & ':' & @sec & @CRLF & @CRLF & '@@ Trace(" .. cl .. ") :    " .. LineCode .. "'  & @CRLF) ;### Trace Console\r\n" )
				elseif option == 2 then
					editor:AddText("ConsoleWrite('>Error code: ' & @error & '    Extended code: ' & @extended & @CRLF & @CRLF & '@@ Trace(" .. cl .. ") :    " .. LineCode .. "'  & @CRLF) ;### Trace Console\r\n" )
				elseif option == 1 then
					editor:AddText("ConsoleWrite('>Error code: ' & @error & @CRLF & @CRLF & '@@ Trace(" .. cl .. ") :    " .. LineCode .. "'  & @CRLF) ;### Trace Console\r\n" )
				elseif option == 0 then
					editor:AddText("ConsoleWrite('@@ Trace(" .. cl .. ") :    " .. LineCode .. "'  & @CRLF) ;### Trace Console\r\n" )
				elseif option == -1 then
					editor:AddText("ConsoleWrite('@@ (" .. cl .. ") : ***Trace :" .. LineCode .. "'  & @CRLF) ;### Trace Console\r\n" )
				end
				editor:LineDown()
				editor:Home()
			else
				-- If continuation line then just move down
				editor:LineDown()
				editor:Home()
			end
			PrevLineCont = CurLineCont
			CurrentLine = CurrentLine + 1
		else
			-- just move down on comment and empty lines
			editor:LineDown()
			editor:Home()
			CurrentLine = CurrentLine + 1
		end
	end
	editor:EndUndoAction()
end	-- TraceAdd()

--------------------------------------------------------------------------------
-- TraceRemove()
--
-- Remove all Trace statements.
--
-- Tool: AutoItTools.TraceRemove $(au3) 1 * Debug: Remove Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:TraceRemove()
	-- Callback function.
	local function pat_match()
		return ""
	end
	editor:BeginUndoAction()
	-- Remove any commented functions first
	self:TraceUncomment()
	-- Perform replacement
	self:ReplaceDocByPattern(self:TracePattern(), pat_match)
	editor:EndUndoAction()
end	-- TraceRemove()

--------------------------------------------------------------------------------
-- TraceComment()
--
-- Comment all Function Trace statements.
--
-- Tool: AutoItTools.TraceComment $(au3) 1 * Debug: Comment Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:TraceComment()
	-- Callback function.
	local function pat_match(m1)
		return self:NewLineInUse() .. ";\t" .. m1
	end
	editor:BeginUndoAction()
	-- Perform replacement
	self:ReplaceDocByPattern(self:TracePattern(), pat_match)
	editor:EndUndoAction()
end	-- TraceComment()

--------------------------------------------------------------------------------
-- TraceUncomment()
--
-- Uncomment all Function Trace statements.
-- Tool: AutoItTools.TraceUncomment $(au3) 1 * Debug: Uncomment Trace Functions
--------------------------------------------------------------------------------
function AutoItTools:TraceUncomment()
	-- Callback function.
	local function pat_match(m1)
		--return self:NewLineInUse() .. "\t" .. m1
		return self:NewLineInUse() .. "" .. m1
	end
	editor:BeginUndoAction()
	-- Perform replacement
	self:ReplaceDocByPattern(self:TracePattern(true), pat_match)
	editor:EndUndoAction()
end	-- TraceUncomment()


--------------------------------------------------------------------------------
-- AllComment()
--
-- Comment all Debug and Trace statements.
-- Tool: AutoItTools.AllComment $(au3) 2 Alt+Ctrl+D Debug: Comment ALL lines
--------------------------------------------------------------------------------
function AutoItTools:AllComment()
	self:TraceComment()
	self:FunctionTraceComment()
	self:DebugComment()
end	-- TraceComment()

--------------------------------------------------------------------------------
-- AllUncomment()
--
-- Uncomment all Debug and Trace statements.
-- Tool: AutoItTools.AllUncomment $(au3) 2 Alt+Ctrl+D Debug: UnComment ALL lines
--------------------------------------------------------------------------------
function AutoItTools:AllUncomment()
	self:TraceUncomment()
	self:FunctionTraceUncomment()
	self:DebugUncomment()
end	-- TraceUncomment()

--------------------------------------------------------------------------------
-- AllTraceRemove()
--
-- Remove all Trace statements.
-- Tool: AutoItTools.AllTraceRemove $(au3) 2 Alt+Ctrl+D Debug: UnComment ALL lines
--------------------------------------------------------------------------------
function AutoItTools:AllTraceRemove()
	self:TraceRemove()
	self:FunctionTraceRemove()
end	-- AllTraceRemove()

--------------------------------------------------------------------------------
-- OpenInclude(version)
--
-- Open the #Include file from your script.
--
-- Tool: AutoItTools.OpenInclude $(au3) 2 Alt+I Open Include
--------------------------------------------------------------------------------
function AutoItTools:OpenInclude(version)
    local IncFile, Filename
	-- currentline text
	local CurrentLine = editor:GetLine(editor:LineFromPosition(editor.CurrentPos))
	-- Exclude #include-once
	if CurrentLine == nil then
	    print("Not on #include line.")
		return true
	end
	if string.find(CurrentLine, "%#[Ii][Nn][Cc][Ll][Uu][Dd][Ee][-][Oo][Nn][Cc][Ee]" ) then
		return true
	end
	-- find #include
	local place = string.find(CurrentLine, "%#[Ii][Nn][Cc][Ll][Uu][Dd][Ee]" )
	-- strip every thing after opening bracket when found
	if place then
		IncFile = string.sub(CurrentLine,place + 8)
		IncFile = string.gsub(IncFile,"\t", " ")  -- replace Tabs with space
		IncFile = string.gsub(IncFile,"\r","")  -- strip CR characters
		IncFile = string.gsub(IncFile,"\n","")	-- strip LF characters
		IncFile = string.gsub(IncFile, "^%s*(.-)%s*$", "%1")	-- strip leading and trailing whitespace characters
	else
	    print("Not on #include line.")
		return true
	end
	--
	if version ~= "beta" then
		version = ""
	end
	--
	IncFile = string.gsub(IncFile,";(.*)","")
	-- get list of directories to check
	local directories = AutoItGotoDefinition:GetDirectories(version)
	local start, stop, step, found
	if string.find(IncFile, "<" ) then
		IncFile = string.gsub(IncFile,"<","")
		IncFile = string.gsub(IncFile,">","")
		start = 1
		stop = #directories
		step = 1
	else  -- Else it is a include file in the script dir
		IncFile = string.gsub(IncFile,"\"","")
		IncFile = string.gsub(IncFile,"'","")
		start = #directories
		stop = 1
		step = -1
	end
	-- loop through the defined directories
	found = false
	for i = start, stop, step do
		Filename = directories[i] .. IncFile
		self:DebugPrint("Checking: " .. Filename)
		if self:FileExists(Filename) then
			-- If we found the include file so open it
			print("Opened: " .. Filename)
			AutoItGotoDefinition:ShowFunction("", Filename)
			found = true
			break
		end
	end
	if not found then
		print("Couldn't locate include file: " .. IncFile)
	end
end

--------------------------------------------------------------------------------
-- OpenInclude(version)
--
-- Open the #Include file from your script.
--
-- Tool: AutoItTools.OpenInclude $(au3) 2 Alt+Shift+I Open Beta Include
--------------------------------------------------------------------------------
function AutoItTools:OpenBetaInclude()
	self:OpenInclude("beta")
end

--------------------------------------------------------------------------------
-- run a cmd command and capture the output
--------------------------------------------------------------------------------
function perform_oscommand(cmd)
   local handle=io.popen("" .. cmd)
   local consoleoutput = handle:read('*all')
   handle:close()
   return consoleoutput
end

--------------------------------------------------------------------------------
-- OnBeforeSave(filename)
--
-- keep the number of backups as defined by backup.files = ?    by Jos van der Zande (Jos)
--
-- AutoItTools.OnBeforeSave
--------------------------------------------------------------------------------
function AutoItTools:OnBeforeSave(filename)
	-- skip making the backup when file isn't changed
	if not editor.Modify  then
        return false
    end
	local backupfiles = tonumber(props['backup.files'])
	-- backup specified and bigger than 0 ?
	if backupfiles == nil or backupfiles == 0 then
		return false
	end
	-- get file directory
	fdir = filename:match(".+[/\\]")
	fname = filename:match(".+[/\\](.+)")
	fext = fname:match(".+(%..+)") or ""
	if fext ~= "" then
		fname = fname:match("(.+)%..+")
	end
	-- set backup directory
	if props['backup.directory'] == "" then
		bdir = fdir .. "backup"             -- no fixed backupdirectory location defined
	else
		bdir = props['backup.directory']    -- use the backupdirectory location defined for backup.directory
	end
	-- set backup rename to extra string. default   Filename_bakx.Fileext
	if props['backup.renameto'] == "" then
		bmid = "_bak"                      -- default
	else
		bmid = props['backup.renameto']    -- use the backupdirectory location defined for backup.directory
	end
	-- ensure the backup directory exists
	perform_oscommand('mkdir "'..bdir..'"')
	--
	-- check for all current existing backup files
	local currentbackupfiles = 1
	local tfile = ""
	local fh=0
	while (1) do
		tfile = bdir.."\\".. fname..bmid..currentbackupfiles..fext
		tfile2 = bdir.."\\".. fname..bmid..string.format("%02d",currentbackupfiles)..fext
		fh = io.open (tfile, "r")
		if fh == nil then
			fh = io.open (tfile2, "r")
			if fh == nil then break end
			io.close(fh)
		else
			io.close(fh)
			os.rename (tfile,tfile2)
		end
		currentbackupfiles = currentbackupfiles + 1
	end
	-- move old backupfiles to 1 to (backupfiles-1)
	if backupfiles > 0 and backupfiles < currentbackupfiles then
		for y=1,currentbackupfiles-1 do
			y2 = y + backupfiles - currentbackupfiles
			local fn1 = bdir.."\\".. fname..bmid..string.format("%02d",y)..fext
			local fn2 = bdir.."\\".. fname..bmid..string.format("%02d",y2)..fext
			if currentbackupfiles - y < backupfiles then
				os.remove (fn2)
				os.rename (fn1,fn2)
			else
				os.remove (fn1)
			end
		end
		currentbackupfiles = backupfiles
	end
	local fn1 = bdir.."\\"..fname..bmid..string.format("%02d",currentbackupfiles)..fext
	os.remove (fn1)
	os.rename (filename, fn1)
	return false
end

--------------------------------------------------------------------------------
-- AutoItTools:ProperCase(c)
--
-- Function which will Proper case keywords/functions as defined in au3.api.
--------------------------------------------------------------------------------
function AutoItTools:ProperCase(c)
	local repword = ""
    -- get word infront of cursor
	local from = editor:WordStartPosition(editor.CurrentPos-1)
	local to = editor:WordEndPosition(from)
	local word = editor:textrange(from, to)
	style = editor.StyleAt[from]
	if (style == SCE_AU3_DEFAULT) or (style == SCE_AU3_FUNCTION) or (style == SCE_AU3_KEYWORD) or (style == SCE_AU3_MACRO) then
		word= string.gsub(word,"%s","")	-- strip whitespace characters
		word= string.gsub(word,"%s","")	-- strip whitespace characters
		--print("Word:" .. word .. "|")
		if word == nil or string.len(word) < 2 then return true end
		--print("Word:" .. word .. "|  Style:" .. style)
		if self.ProperWords ~= nil and self.ProperWords ~= "" then
			local rep_start = string.find("\n" .. self.l_ProperWords  .. "\n", "\n" .. string.lower(word)  .. "\n")
			if rep_start == nil then
				rep_start = string.find("\n" .. self.l_ProperWords .. "\n","\n" .. string.lower(word) .. " ")
			end
			if rep_start ~= nil and rep_start ~= 0 then
				rep_start = rep_start
			   repword = string.sub(self.ProperWords .. "\n",rep_start,rep_start + string.len(word) -1)
			else
				return true
			end
		end
		-- if found process it
		repword = string.gsub(repword,"%s","")
		repword = string.gsub(repword,"\n","")
		if repword ~= nil and repword ~= word and repword ~= "" then
			local savepos = editor.CurrentPos
			editor:remove(from, to)
			editor:insert(from, repword)
			editor:GotoPos(savepos)
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- AutoItTools:OnKey()
--
-- Override the Ctrl+b Expand abbreviation shortcut to allow for Uppercase characters (MrCreatoR)
--------------------------------------------------------------------------------
--
function AutoItTools:OnKey(code, shift, control, alt)
    if editor.Lexer == SCLEX_AU3 then
        local ls = editor.StyleAt[editor.CurrentPos-2]
        if ls == SCE_AU3_EXPAND and string.char(code):lower() == 'b' and control and not shift and not alt then
            self:Abbreviations(0)
        end
    end
end
--------------------------------------------------------------------------------
-- AutoItTools:Abbreviations()
--
-- Expand abbreviations  by Jos van der Zande (Jos) & MrCreatoR
--------------------------------------------------------------------------------
--
function AutoItTools:Abbreviations(i)
    if i==1 then editor:DeleteBack() end
    local from = editor:WordStartPosition(editor.CurrentPos-i)
    local to = editor:WordEndPosition(from)
    local word = editor:textrange(from, to)
    editor.SelectionStart = editor.CurrentPos - #word
    editor:ReplaceSel(word:lower())
    scite.MenuCommand(IDM_ABBREV)
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Insert a copy of the Bookmarked line(s) by Jos van der Zande (Jos)
-- shortcut Ctrl+Shift+B Insert Copy of Bookmark(s)
function AutoItTools:Copy_BookMarks()
   editor:Home()                     -- goto beginning of the line
   ml = editor:MarkerNext(0,2)       -- Find first bookmarked line
   s_text = ""
   while (ml > -1) do
      _ALERT("Inserted bookmarked line:" .. ml + 1 )
      s_text = s_text .. editor:GetLine(ml)      -- Add text to var
      ml = editor:MarkerNext(ml+1,2)             -- Find next bookmarked line
   end
   editor:AddText(s_text)            -- Add found text to Script
end
