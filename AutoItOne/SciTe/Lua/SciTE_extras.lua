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
-- Calltip addition Functions originally written by LaCastiglione

myCallTips = EventClass:new(Common)

-- Load CallTip info at start and update when selecting another file
function myCallTips:OnOpen()
    myCallTips:set_above()
    myCallTips:set_highlight_color()
    return true
end
-- Load CallTip info at start and update when selecting another file
function myCallTips:OnSwitchFile(path)
    myCallTips:set_above()
    myCallTips:set_highlight_color()
    return true
end

--------------------------------------------------------------------------------
-- set_above()
-- Displays the calltip above the function.
--------------------------------------------------------------------------------
function myCallTips:set_above()
    local calltips_set_above = tonumber(props["calltips.set.above"])

    if (calltips_set_above == 1) then
		scite.SendEditor(SCI_CALLTIPSETPOSITION, true)
    else
		scite.SendEditor(SCI_CALLTIPSETPOSITION, false)
    end
end

--------------------------------------------------------------------------------
-- set_highlight_color()
-- Set the color of the highlighted calltip property
--------------------------------------------------------------------------------
function myCallTips:set_highlight_color()
    local calltips_color_highlight = props["calltips.color.highlight"]

    if (calltips_color_highlight == '') then
        calltips_color_highlight = "#FF0000" -- dark blue default
    end

    calltips_color_highlight = myCallTips:BGR2Decimal(calltips_color_highlight)

    if (calltips_color_highlight == nil) then
		print("! invalid property length for: calltips.color.highlight=" )
	else
		scite.SendEditor(SCI_CALLTIPSETFOREHLT, calltips_color_highlight)
	end
end

--------------------------------------------------------------------------------
-- BGR2Decimal()
-- convert BGR to decimal, duh! (albeit in a hack and stab manner)
--------------------------------------------------------------------------------
function myCallTips:BGR2Decimal(BGR)
    if (string.len(BGR) ~= 7) then
        return nil
    end
	-- remove first character = hash
    BGR = string.sub(BGR, 2)
    -- reverse the colors
	BGR = string.reverse(BGR)
	-- add 0x to the start
    BGR = "0x"..BGR
	-- Return decimal value of the found Hex value
    return tonumber(BGR)
end
