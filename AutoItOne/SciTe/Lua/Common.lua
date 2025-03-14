--------------------------------------------------------------------------------
-- This library contains various functions which can be used in numerous places.
-- New objects should inherit from this object.
--------------------------------------------------------------------------------
Common = Class:new()

--------------------------------------------------------------------------------
-- IsLexer(lexer)
--
-- Provides a clean method for checking the current lexer.
--
-- Parameters:
--	lexer - The lexer to check.
--
-- Returns:
--	The value true if the lexer is currently active.
--	The value false if the lexer is inactive.
--------------------------------------------------------------------------------
function Common:IsLexer(lexer)
	return editor.Lexer == lexer
end	-- IsLexer()

--------------------------------------------------------------------------------
-- CancelAutoComplete()
--
-- Cancels AutoComplete if it's showing.
--
-- Returns:
--	The value true is returned if AutoComplete was hidden.
--	The value false is returned if AutoComplete was not hidden.
--------------------------------------------------------------------------------
function Common:CancelAutoComplete()
	if editor:AutoCActive() then
		editor:AutoCCancel()
		return true
	end
	return false
end	-- CancelAutoComplete()

--------------------------------------------------------------------------------
-- MatchWordAtStart(word, line)
--
-- Checks if word is the first word on line skipping whitespace.
--
-- Parameters:
--	word - The word to search for.
--	line - The line to search on.
--
-- Returns:
--	The value true if word is the first word on the line.
--	The value false if word is not the first word on the line.
-- 	In either case, the word start position, start end position and word itself
--	are returned.
--------------------------------------------------------------------------------
function Common:MatchWordAtStart(word, line)
	local word_pos = editor.LineIndentPosition[line] + 1
	local word_start = editor:WordStartPosition(word_pos)
	local word_end = editor:WordEndPosition(word_pos)
	local word_found = editor:textrange(word_start, word_end)
	return string.lower(word_found) == string.lower(word), word_start, word_end, word_found
end	-- MatchWordAtStart()
--
function Common:FirstWord(line)
	if editor:LineLength(line) == 0 then
		return ""
	end
	local word_pos = editor.LineIndentPosition[line] + 1
	local word_start = editor:WordStartPosition(word_pos)
	local word_end = editor:WordEndPosition(word_pos)
	local word_found = editor:textrange(word_start, word_end)
	word_found = word_found:gsub("^%s*", "")    -- remove leading white space
	word_found = word_found:gsub("[\r\n]", "")    -- remove newlines
	return string.lower(word_found)
end	-- FirstWord()

function Common:LastWord(line)
	-- if line is -1 (parent not found) then return
	if line < 0 then
		return ""
	end
	local linetext = editor:GetLine(line)
	linetext = linetext:gsub("[\r\n]", "")    -- remove newlines
	local last_word = ""

	-- only get the portion not commented
	from, to =  linetext:find(";")
	while from ~= nil do
--~ 		print(from .. " type:" .. editor.StyleAt[from])
		if editor.StyleAt[from] == SCE_AU3_COMMENT then
			linetext = string.sub (linetext, 1 , from-1)   -- remove comment
			from = nil                             -- exit loop
		else
			from, to =  linetext:find(";",from+1)      -- find next ; as this one is not a comment
		end
	end
	-- get the last word of the line
	for w in string.gmatch(linetext, "%a+") do
		last_word = w
	end
	return string.lower(last_word)
end	-- LastWord()
--------------------------------------------------------------------------------
-- GetWord()
--
-- Gets the selected word or the word under the caret.
--
-- Returns:
--	If a word can be found, it is returned, otherwise an empty string.
--------------------------------------------------------------------------------
function Common:GetWord()
	-- This pattern checks to see if a string is empty or all whitespace.
	local pattern = "^%s*$"
	-- First, get the selected text.
	local word = editor:GetSelText()
	if word:match(pattern) then
		-- No text was selected, try getting the word where the caret is.
		word = editor:textrange(editor:WordStartPosition(editor.CurrentPos, true),
			editor:WordEndPosition(editor.CurrentPos, true))
		if word:match(pattern) then
			-- No text found anywhere, set as an empty string.
			word = ""
		end
	end
	return word:gsub("^%s*", "")
end    -- GetWord()

--------------------------------------------------------------------------------
-- ReplaceCharacters(p, r)
--
-- Replace characters in the document and attempt to save the view.
--
-- Parameters:
--	p - The pattern to replace.
--	r - The replacement text.
--------------------------------------------------------------------------------
function Common:ReplaceCharacters(p, r)
	y = editor:PointYFromPosition(editor.CurrentPos)
	x = editor:PointXFromPosition(editor.CurrentPos)
	line = editor:LineFromPosition(editor.CurrentPos)
	s = editor:GetText()
	editor:SetText(s:gsub(p, r))
	pos = editor:PositionFromLine(line)
	editor:SetSel(pos, pos)
	yn = editor:PointYFromPosition(editor.CurrentPos)
	while y ~= yn do
		if yn < y then
			editor:LineScroll(0, -1)
		elseif yn > y then
			editor:LineScroll(0, 1)
		end
		yn = editor:PointYFromPosition(editor.CurrentPos)
	end
	xn = editor:PointXFromPosition(editor.CurrentPos)
	i = 0
	while x ~= xn and i < 50 do
		if xn < x then
			editor:CharRight()
		elseif xn > x then
			editor:CharLeft()
		end
		xn = editor:PointXFromPosition(editor.CurrentPos)
		i = i + 1
	end
end	-- ReplaceCharacters()

--------------------------------------------------------------------------------
-- ReplaceDocByPattern(sPat, fnPatMatch)
--
-- Replaces all occurences of a specific pattern by calling a user-defined
-- callback function.
--
-- Parameters:
-- sPat - The regular expresion pattern to match.
-- fnPatMatch - A callback function which will be called for each match.  The
--		captures from the pattern will be passed as arguments to the function.
--		Return the replacement string.
--------------------------------------------------------------------------------
function Common:ReplaceDocByPattern(sPat, fnPatMatch)
    local pos = editor.CurrentPos    -- Current position before modification
    local caret_line = editor:LineFromPosition(pos)    -- Line number to return to.
    local first_line = editor.FirstVisibleLine    -- The first visible line in the buffer
    local line_offset = 0    -- Number of lines inserted above the caret's original position
    local column = pos - editor:PositionFromLine(caret_line)    -- Convert back to beginning of line
    local old_line_count = editor.LineCount

    sPat = "()" .. sPat    -- Internal capture to record the position of each match.
    -- Local function which builds a string from the pattern matches.
    local function pat_match(p, ...)
        if pos > p then line_offset = line_offset + 1 end
        return fnPatMatch(...)
    end

    local sDoc = editor:GetText()
    -- We style the entire document so that match callbacks can use
    -- styling information to determine replacement data.
    editor:Colourise(0, -1)
    editor:SetText(sDoc:gsub(sPat, pat_match))

    local new_line_count = editor.LineCount

    if old_line_count > new_line_count then
        line_offset = line_offset * -1
    elseif old_line_count == new_line_count then
        line_offset = 0
    end

    pos = editor:PositionFromLine(caret_line + line_offset)
    editor:GotoPos(pos + column)
    editor:LineScroll(0, first_line - editor.FirstVisibleLine + line_offset)
end    -- ReplaceDocByPattern()
--------------------------------------------------------------------------------
-- NewLineInUse()
--
-- Returns the current newline character(s) in use by the document.
--
-- Returns:
--	Either the value of "\n", "\r" or "\r\n" depending on the EOLMode.
--------------------------------------------------------------------------------
function Common:NewLineInUse()
	if editor.EOLMode == 2 then
		return "\n"
	elseif editor.EOLMode == 1 then
		return "\r"
	else
		return"\r\n"
	end
end	-- NewLineInUse()

--------------------------------------------------------------------------------
-- FileExists(file)
--
-- Checks to see if a file exists by attempting to open it.
--
-- Parameters:
--	file - The full path of the file to test.
--
-- Returns:
--	The value true if the file was successfully opened.
--	The value false if the file was not successfully opened.
--------------------------------------------------------------------------------
function Common:FileExists(file)
	local fp = io.open(file)
	if fp then
		fp:close()
	end
	return io.type(fp) == "closed file"
end	-- FileExists()
