--------------------------------------------------------------------------------
-- This library helps fix indenting issues with AutoIt code..  SciTE doesn't
-- always indent how AutoIt code flows so this fixes some common issues.
--
-- Current issues addressed:
--	The first Case statement is normally indented wrong.
--	Lines after single line If statements have the correct indentation.
--------------------------------------------------------------------------------
AutoItIndentFix = EventClass:new(Common)

--------------------------------------------------------------------------------
-- OnStartup()
--
-- Initializes object variables.
--------------------------------------------------------------------------------
function AutoItIndentFix:OnStartup()
	self.VK_RETURN = 0x0D
	self.Debug = false
	-- The number of lines to look-back when trying to determine indentation.
	self.LookBack = 5
	self.Check_Indent = false
	self.Check_Indent_inProgress = false
	-- The keywords which are statement endings.  See LoadEndStatements()
	-- for a property that may need to be user configured.
	self.EndStatements = self:LoadEndStatements()
end	-- OnStartup()

--------------------------------------------------------------------------------
-- OnKey(code)
--
-- Fixes issues with auto-indent when Return is pressed.
--
-- Parameters:
--	code - The keycode for the key pressed.
--
-- Returns:
--	The value true if default behavior needs blocked.
--	The value false if default behavior doesn't need blocked.
--------------------------------------------------------------------------------
function AutoItIndentFix:OnKey(code)
	if self.Check_Indent_inProgress then
		self:DebugPrint("*** Check_Indent_inProgress")
		return true
	end
	if code == self.VK_RETURN and self:IsLexer(SCLEX_AU3) and not editor:AutoCActive() then
		self:DebugPrint("*** Enter detected => Start Indent checking")
		self.Check_Indent = true
	end
end -- OnKey()

function AutoItIndentFix:OnUpdateUI()
	-- ReWritten fix for the AutoIndent process
	local return_value = false
	-- We do this process after the Return is processed and the GUI will be updated.
	-- Check that no AutoComplete is showing.
	if self.Check_Indent and not editor:AutoCActive() then
		editor:BeginUndoAction()
		-- Set indicators for the prcess.
		self.Check_Indent_inProgress = true
		self.Check_Indent = false
		-- subtract 1 from current line since we do this after the detected Enter was processed.
		local line = editor:LineFromPosition(editor.CurrentPos) -1
		local Curr_firstword = self:FirstWord(line)
		local Next_firstword = self:FirstWord(line+1)
		local Next2_firstword = self:FirstWord(line+2)
		self:DebugPrint ( "+### processing line:" .. line .. " Curr_firstword:" .. Curr_firstword .. ":      Next_firstword:" .. Next_firstword .. ":".. ":      Next2_firstword:" .. Next2_firstword .. ":")
		-- Get all needed information
		local Curr_lev =  editor.FoldLevel[line]
		local Prev_lev =  editor.FoldLevel[line-1]
		local Next_lev =  editor.FoldLevel[line+1]
		local Curr_foldLvl = math.modf(Curr_lev, 4096)
		local Prev_foldLvl = math.modf(Prev_lev, 4096)
		local Next_foldLvl = math.modf(Next_lev, 4096)
		local Parent_line =  editor.FoldParent[line]
		local Parent_foldLvl = math.modf(Parent_line, 4096)
		local Prev_Parent_line =  editor.FoldParent[line-1]
		local Prev_Parent_foldLvl = math.modf(Parent_line-1, 4096)
		local Next_Parent_line =  editor.FoldParent[line+1]
		local Next_Parent_foldLvl = math.modf(Parent_line+1, 4096)
		local Curr_IsFoldHeader = math.modf(math.floor(Curr_lev / 8192), 2) == 1
		local Prev_IsFoldHeader = math.modf(math.floor(Prev_lev / 8192), 2) == 1
		local Next_IsFoldHeader = math.modf(math.floor(Next_lev / 8192), 2) == 1
		local fold_firstword = self:FirstWord(Parent_line)
		local fold_lastword = self:LastWord(Parent_line)   -- Show debug info
		-- Fix If ..then indent level
		if fold_lastword == "then" then
			self:DebugPrint (" found Then fixing Curr_foldLvl:" .. Curr_foldLvl .. " Curr_lev:" .. Curr_lev .. "   Curr_IsFoldHeader    :" .. tostring(Curr_IsFoldHeader)	.. "        Parent_line:" .. Parent_line      .. "        Parent_foldvl: " .. Parent_foldLvl .. "  fold_firstword:" .. fold_firstword .. "  fold_lastword:" .. fold_lastword)
			while (fold_firstword ~= "if" and Parent_line > 0) do
				Parent_line = Parent_line -1
				fold_firstword = self:FirstWord(Parent_line)
			end
			Parent_foldLvl = math.modf(Parent_line, 4096)
			Next_Parent_line=Parent_line
		end
		self:DebugPrint (" Line: " .. line .. " -------------------------------------------------------")
		self:DebugPrint (" Curr_foldLvl:" .. Curr_foldLvl .. " Curr_lev:" .. Curr_lev .. "   Curr_IsFoldHeader    :" .. tostring(Curr_IsFoldHeader)	.. "        Parent_line:" .. Parent_line      .. "        Parent_foldvl: " .. Parent_foldLvl .. "  fold_firstword:" .. fold_firstword .. "  fold_lastword:" .. fold_lastword)
		self:DebugPrint (" Prev_foldLvl:" .. Prev_foldLvl .. " Prev_lev:" .. Prev_lev .. "   Prev_IsFoldHeader    :" .. tostring(Prev_IsFoldHeader) .. "   Prev_Parent_line:" .. Prev_Parent_line .. "   Prev_Parent_foldLvl: " .. Prev_Parent_foldLvl)
		self:DebugPrint (" Next_foldLvl:" .. Next_foldLvl .. " Next_lev:" .. Next_lev .. "   Next_IsFoldHeader    :" .. tostring(Next_IsFoldHeader) .. "   Next_Parent_line:" .. Next_Parent_line .. "   Next_Parent_foldLvl: " .. Next_Parent_foldLvl )
		-- Check for single line If statements => set the Indent of the new line to the If line
		if Curr_firstword == "if"  and Curr_foldLvl == Next_foldLvl then
			self:DebugPrint( "!  Single line If ...  update Indent to: "..editor.LineIndentation[line])
			editor.LineIndentation[line+1] = editor.LineIndentation[line]
			editor:GotoPos(editor.LineIndentPosition[line+1])
		end
		-- Check the current line before the Return was pressed and set its Indent the same as the Header level record (Line starting the fold).
		self:UpdateTab(Curr_firstword, Next_firstword, line, line+1, Parent_line, Prev_Parent_line)
		-- Check the newline that is created with the return. This happens when the Return was pressed with the Caret infront of the Keyword.
		self:UpdateTab(Next_firstword, Next2_firstword, line+1, line+1, Next_Parent_line, Parent_line)
		editor:EndUndoAction()
	end
	self.Check_Indent_inProgress = false
	return return_value
end -- OnUpdateUI()

function AutoItIndentFix:UpdateTab(sCheckWord,sCheckNextWord,nLine,nLine2,nParent_line, nPrev_Parent_line)
	if string.len(sCheckWord) > 0 and string.find(",case,else,endif,elseif,endfunc,endselect,endswitch,next,until,wend,endwith,", ",".. sCheckWord..",", nil, true) ~= nil then
		if sCheckWord == "case" then
			editor.LineIndentation[nLine] = editor.LineIndentation[nParent_line] + editor.Indent
			editor.LineIndentation[nLine+1] = editor.LineIndentation[nParent_line] + editor.Indent + editor.Indent
			self:DebugPrint( "!  Line:" .. nLine .. " => Found Case ...  update Indent." )
		elseif sCheckWord == "else" or sCheckWord == "elseif" then
			if Prev_IsFoldHeader then
				self:DebugPrint( "!  Line:" .. nLine .. " => Found Else/ElseIf statement right after Header...  update Indent." )
				editor.LineIndentation[nLine] = editor.LineIndentation[nLine-1]
			else
				self:DebugPrint( "!  Line:" .. nLine .." => Found Else/ElseIf statement ...  update Indent." )
				editor.LineIndentation[nLine] = editor.LineIndentation[nPrev_Parent_line]
			end
		else
			self:DebugPrint( "!  Line:" .. nLine .. " => Found Case/End*/Else/Next/Until statement ...  update Indent current line." )
			editor.LineIndentation[nLine] = editor.LineIndentation[nParent_line]
			if string.find(",endif,endfunc,endselect,endswitch,next,until,wend,endwith,", ",".. sCheckWord..",", nil, true) ~= nil then
				if string.find(",endif,endfunc,endselect,endswitch,next,until,wend,endwith,", ",".. sCheckNextWord..",", nil, true) == nil then
					self:DebugPrint( "!  Line:" .. nLine+1 .. " => Found End??? statement ...  update Indent next line." )
					editor.LineIndentation[nLine+1] = editor.LineIndentation[nLine]
				end
			end
		end
		editor:GotoPos(editor.LineIndentPosition[nLine2])
	end

end
--------------------------------------------------------------------------------
-- LoadEndStatements()
--
-- Loads the AutoIt end statements into a table.
--
-- Returns:
--	A table containing the end statements. The keys are the statements, the
--	values are not used.
--------------------------------------------------------------------------------
function AutoItIndentFix:LoadEndStatements()
	-- This may need changed depending on the configuration.
	local text = props["block.end.$(au3)"]
	-- Store the names in a table.
	local data = { }
	-- Iterate over all words, clean them up and put them in the table.
	for word in text:gmatch("%a+") do
		-- We store the words in lower case.  This has the side effect of
		-- removing duplicate words.
		data[word:lower()] = true
	end
	return data
end	-- LoadEndStatements()
