--------------------------------------------------------------------------------
-- This library automatically sizes the horizontal scrollbar for the editor and
-- output panes based on the longest line currently visible.
--------------------------------------------------------------------------------
AutoHScroll = EventClass:new()

--------------------------------------------------------------------------------
-- Declare a table to store per-pane cached line numbers.  This prevents the
-- scrollbar from constantly appearing and disappearing during editing.
--------------------------------------------------------------------------------
AutoHScroll.cache = { }
AutoHScroll.cache2 = { }

--------------------------------------------------------------------------------
-- Declare the debugging variable (Defaults to off).
--------------------------------------------------------------------------------
AutoHScroll.Debug = false

--------------------------------------------------------------------------------
-- Special variable that controls which pane will be debugged.  Only one pane
-- can be debugged at a time.  This value should be set to either editor or
-- output.
--------------------------------------------------------------------------------
AutoHScroll.DebugPane = editor

--------------------------------------------------------------------------------
-- OnUpdateUI()
--
-- Update the horizontal scroll width for both the editor and output pane.
--------------------------------------------------------------------------------
function AutoHScroll:OnUpdateUI()
	if ((self.cache[editor] or 0) == 0) then
		self:SetWidth(editor, "editor")
	end
	if ((self.cache[output] or 0) == 0) then
		self:SetWidth(output, "output")
	end
end	-- OnUpdateUI()

--------------------------------------------------------------------------------
-- SetWidth(pane)
--
-- Sets the width of pane's horizontal scrollbar.
--
-- Parameters:
--	pane - Can be either editor or output.
--------------------------------------------------------------------------------
function AutoHScroll:SetWidth(pane,panetxt)
	-- Declare the variable used in the function.
	local width = 0
	local line = 0
	-- Iterate over all the visible lines.
	for visible_line = 0 , pane.LineCount-1 do
		-- check only the first 10000 lines
		if visible_line > 10000 then
			self:DebugPrint("AutoHscroll reached max lines for "..(panetxt or ""))
			break
		end
		-- Get the width of the line based on the X coordinate of it's end
		-- position.  This provides a fast and accurate way of getting the
		-- width regardless of the styling the line may have.
		local width_temp = pane.XOffset + pane:PointXFromPosition(pane.LineEndPosition[visible_line])
		-- Test if the current line is longer than the current longest.
		if (width_temp or 0) > width then
			-- Update the width.
			width = width_temp
			line = visible_line
		end
	end

	-- Set the width.
	if pane.ScrollWidth ~= width then
		self:DebugPrint("AutoHscroll "..(panetxt or "" ).." longest line:"..line.."   change Witdh from:"..pane.ScrollWidth.." to:"..width)
		pane.ScrollWidth = width
		self.cache[pane] = width
	end
end	-- SetWidth()

--------------------------------------------------------------------------------
-- DebugPrintEx(pane, s)
--
-- Set self.Debug = true to allow debug messages to print.  In addition,
-- self.DebugPane must be set to either editor or output in order for any
-- debugging to occur.  This is done to filter the messages so that they are
-- easier to understand.
--
-- Parameters:
--	pane - The pane currently being processed.
--	s - The string to print.
--------------------------------------------------------------------------------
function AutoHScroll:DebugPrintEx(pane, s)
	local pane_name = "Unknown"
	if pane == self.DebugPane then
		if pane == editor then
			pane_name = "Editor"
		elseif pane == output then
			pane_name = "Output"
		end
		return self:DebugPrint(pane_name .. ": " .. s)
	end
end
