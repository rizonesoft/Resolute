--------------------------------------------------------------------------------
-- This library hides AutoComplete when typing in certain styles.  For example,
-- when typing strings or comments, AutoComplete is useless and gets in the way.
-- Note, depending on how many events are configured, there may be a small
-- flash as the AutoComplete dropdown is hidden.
--
-- The implementation of this is a two-stage process.  In the OnChar() handler,
-- we check to see if the character is one of the styles.  In the OnUpdateUI()
-- handler, we hide AutoComplete.  This approach is necessary to avoid returning
-- true from OnChar(), which causes other issues.
--------------------------------------------------------------------------------
SmartAutoCompleteHide = EventClass:new(Common)

--------------------------------------------------------------------------------
-- OnStartup()
--
-- Defines the style tables.
--------------------------------------------------------------------------------
function SmartAutoCompleteHide:OnStartup()
	-- This table defines the AutoIt styles when AutoComplete needs hidden.
	local autoit_styles =
	{
		SCE_AU3_COMMENTBLOCK,
		SCE_AU3_COMMENT,
		SCE_AU3_STRING,
		SCE_AU3_SPECIAL,
		SCE_AU3_COMOBJ
	}

	-- This table defines the Lua styles when AutoComplete needs hidden.
	local lua_styles =
	{
		SCE_LUA_COMMENT,
		SCE_LUA_COMMENTLINE,
		SCE_LUA_COMMENTDOC,
		SCE_LUA_STRING,
		SCE_LUA_CHARACTER,
		SCE_LUA_LITERALSTRING
	}

	-- Note: It is perhaps possible to optimize the above tables by making
	-- the keys style values instead of the values.  This would allow a simple
	-- lookup using [] instead of iteration.

	-- The indices of this table are the lexer and the value is the table
	-- associated with that lexer.
	self.style_table =
	{
		[SCLEX_AU3] = autoit_styles,
		[SCLEX_LUA] = lua_styles
	}
end	-- OnStartup()

--------------------------------------------------------------------------------
-- OnChar(...)
--
-- Detects if typing in a style where AutoComplete needs hidden.
--
-- Parameters:
--	... - Not used.
--------------------------------------------------------------------------------
function SmartAutoCompleteHide:OnChar(c)
	local style = editor.StyleAt[editor.CurrentPos - 2]

	-- Prevent AutoComplete from appearing when in certain lexing styles.
	if self:IsStyleInTable(style) then
		editor:AutoCStops(c)
	else
		editor:AutoCStops("")
	end
end	-- OnChar()
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- IsStyleInTable(style)
--
-- Iterates over the internal table of style tables checking to see if the false True editor.Aut
-- style can be found in one of them.
--
-- Parameters:
--	style - The style to check for.
--
-- Returns:
--	The value true is returned if the style is in the internal table.
--	The value false is returned if the style is not in the internal table.
--------------------------------------------------------------------------------
function SmartAutoCompleteHide:IsStyleInTable(style)
	-- As an optimization, the table is keyed with the lexer's numeric value.
	local style_table = self.style_table[editor.Lexer]
	-- don't close when on a #include Line
	curline = editor:GetCurLine()
	if editor.Lexer == SCLEX_AU3 and curline:match("^%s*#[Ii][Nn][Cc][Ll][Uu][Dd][Ee]%s*<") then
		return false
	end
	--
	if style_table then
		for i,v in ipairs(style_table) do
			if style == v then
				return true
			end
		end
	end
	return false
end	-- IsStyleInTable()
