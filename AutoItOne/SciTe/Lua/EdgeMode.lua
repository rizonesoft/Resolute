--------------------------------------------------------------------------------
-- This library dynamically enables the EdgeMode feature whenever it's detected
-- that a file is being displayed with a Monospace font.
--------------------------------------------------------------------------------
EdgeMode = EventClass:new()

--
--------------------------------------------------------------------------------
-- OnStartup()
--
-- Caches the monospace font and allows configuration of the EdgeMode to use.
-- Edit self.preferred to one of EDGE_LINE, EDGE_BACKGROUND or EDGE_NONE to
-- set up the behavior.
--------------------------------------------------------------------------------
function EdgeMode:OnStartup()
	-- Set to EDGE_LINE, EDGE_BACKGROUND or EDGE_NONE.
	self.preferred = EDGE_LINE
	-- If changing font.monospace, a restart will be required for this library
	-- to notice the change.
	self.monospace = props["font.monospace"]
end	-- OnStartup()

--------------------------------------------------------------------------------
-- OnUpdateUI()
--
-- Toggles EdgeMode on or off depending on if font.monospace is in use.
--------------------------------------------------------------------------------
function EdgeMode:OnUpdateUI()
	if self.monospace:find(editor.StyleFont[0], 1, true) then
		if editor.EdgeMode ~= self.preferred then
			editor.EdgeMode = self.preferred
		end
	elseif editor.EdgeMode ~= EDGE_NONE then
		editor.EdgeMode = EDGE_NONE
	end
end	-- OnSwitchFile()
