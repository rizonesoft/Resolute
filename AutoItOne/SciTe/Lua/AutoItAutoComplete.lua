--------------------------------------------------------------------------------
-- This library provides some convenience when working in AutoIt scripts.  It
-- causes the AutoComplete and CallTips() to behave more intelligently.
--------------------------------------------------------------------------------
AutoItAutoComplete = EventClass:new(Common)

--------------------------------------------------------------------------------
-- OnStartup()
--
-- Initializes variables.
--------------------------------------------------------------------------------
function AutoItAutoComplete:OnStartup()
	-- Variable mappings for SciTE menu commands.
	self.IDM_SHOWCALLTIP = 232
	self.IDM_COMPLETE = 233
	self.IDM_COMPLETEWORD = 234
	self.Check_Calltip = false

	-- List of "valid" styles as used by IsValidStyle().
	self.style_table =
	{
		SCE_AU3_COMMENTBLOCK,
		SCE_AU3_COMMENT,
		SCE_AU3_STRING,
		SCE_AU3_SPECIAL,
		SCE_AU3_COMOBJ
	}
end	-- OnStartup()

--------------------------------------------------------------------------------
-- OnUpdateUI()
--
-- Controls showing CallTips.
--
-- Parameters:
--
--------------------------------------------------------------------------------
function AutoItAutoComplete:OnUpdateUI()
	-- Check for showing Calltip. this is activate by the OnKey check of "," or "(" but moved here because at this time the StyleAt is know for the typed character
	if self:IsLexer(SCLEX_AU3) and self.Check_Calltip then
		self.Check_Calltip = false
		local style = editor.StyleAt[editor.CurrentPos-1]
		-- Only update calltip when an operator is typed
		if style ~= SCE_AU3_OPERATOR then return false end
		scite.MenuCommand(self.IDM_SHOWCALLTIP)
		return
	end
end
--------------------------------------------------------------------------------
-- OnChar(c)
--
-- Controls showing and hiding of AutoComplete and CallTips.
--
-- Parameters:
--	c - The character typed.
--------------------------------------------------------------------------------
function AutoItAutoComplete:OnChar(c)
	-- Make sure we only do this for the AutoIt lexer.
	if self:IsLexer(SCLEX_AU3) then
		if props['autocomplete.au3.disable'] == "1" then
			self:CancelAutoComplete()
			return false
		end

		-- Show Includes dropdown after #include<
		local style = editor.StyleAt[editor:WordStartPosition(editor.CurrentPos, true)]
		curline = editor:GetCurLine()
		if (curline:match("^%s*#[Ii][Nn][Cc][Ll][Uu][Dd][Ee]%s*<"))
		or (curline:match("^%s*#[Ii][Nn][Cc][Ll][Uu][Dd][Ee]%s*") and c == "<")  then
			-- don't popup after closing ">"
			if (curline:match("<.*>"))  then
				return true
			end
			local pos = editor.CurrentPos
			local startPos = editor:WordStartPosition(pos, true)
			local len = pos - startPos
			local IncludeNames
			names = {}
			--Load Include table
			f = io.open(props['SciteUserHome'].."\\includes.txt")
			if f ~= nil then
				IncludeNames = f:read('*a')
				f:close()
				local prefix = string.sub(editor:textrange(startPos, pos),1,len)
				for word in string.gmatch(IncludeNames, "[%a_][%w_.]+") do
					if string.lower(string.sub(word,1,len)) == string.lower(prefix) then
						table.insert(names, word..">")
					end
				end
			end
			--
			editor:AutoCShow(len,table.concat(names, " "))
			return true
		end

		-- Show CallTip when a comma is typed to delimit function parameters.
		if ((c == "," or c == "(")) then
			-- set variable to 1 and let AutoItAutoComplete:OnUpdateUI handle the rest as only then the StyleAt is proper set
			self.Check_Calltip = true
			return
		end

		-- Show variables in AutoComplete.
		if (c == "$" and self:IsValidStyle(style)) then
			scite.MenuCommand(self.IDM_COMPLETEWORD)
			return
		end

		-- Show macros in AutoComplete.
		if (c == "@" and self:IsValidStyle(style)) then
			scite.MenuCommand(self.IDM_COMPLETE)
			return
		end

		-- Skip showing AutoComplete on _ as the first character.
		if c == "_" and editor:WordStartPosition(editor.CurrentPos) + 1 == editor.CurrentPos then
			self:CancelAutoComplete()
			return true
		end

		-- Ensure the character is a valid function character.
		if not self:IsValidFuncChar(c) then
			return
		end

		-- Cancels AutoComplete if the previous character is a period.  It means
		-- we're typing a COM method but the style isn't set yet.
		if c2 == "." then
			return self:CancelAutoComplete()
		end

		-- Show AutoComplete if it isn't showing already.
		if not editor:AutoCActive() then
			scite.MenuCommand(self.IDM_COMPLETE)
			-- fall through
		end

		-- Last attempt to show AutoComplete.
		if not editor:AutoCActive() then
			scite.MenuCommand(self.IDM_COMPLETEWORD)
			return
		end
	end
end	-- OnChar()

--------------------------------------------------------------------------------
-- IsValidStyle(style)
--
-- Checks if the style is _not_ in the table.
--
-- Parameters:
--	style - The style to check.
--
-- Returns:
--	The value true is returned if the style is _not_ in the table.
--	The value false is returned if the style is in the table.
--------------------------------------------------------------------------------
function AutoItAutoComplete:IsValidStyle(style)
	if self.style_table then
		for i, v in ipairs(self.style_table) do
			if style == v then
				return false
			end
		end
	end
	return true
end	-- IsValidStyle()

--------------------------------------------------------------------------------
-- IsValidFuncChar(c)
--
-- Checks to to see if a character is a valid function name character.
--
-- Parameters:
--	c - The character to check.
--
-- Returns:
--	The value true is returned if the charcter is a valid function character.
--	The value false is returned if the characer is not valid.
--------------------------------------------------------------------------------
function AutoItAutoComplete:IsValidFuncChar(c)
	return string.find(c, "[_%w]") ~= nil
end	-- IsValidFuncChar()

--------------------------------------------------------------------------------
-- IsQuoteChar(c)
--
-- Checks to see if a character is a single (') or double (") quote.
--
-- Parameters:
--	c - The character to check.
--
-- Returns:
--	The value true is returned if the character is a quote character.
--	The value false is returned if the character is not a quote character.
--------------------------------------------------------------------------------
function AutoItAutoComplete:IsQuoteChar(c)
	return string.find(c, "[\"\']") ~= nil
end	-- IsQuoteChar()
