--------------------------------------------------------------------------------
-- This library dynamically loads pixmaps to display in the AutoComplete list.
-- To enabled this feature, set the property:
--	autoit.use.pixmaps=1
--
-- To set the pixmaps for various keywords, set the following properties:
--	autoit.pixmap.function=
--	autoit.pixmap.variable=
--	autoit.pixmap.macro=
--	autoit.pixmap.keyword=
--	autoit.pixmap.library=
--	autoit.pixmap.preprocessor=
--	autoit.pixmap.special=
--
-- The properties are expected to be the string representation of an XPM image.
--------------------------------------------------------------------------------
AutoItPixmap = EventClass:new(Common)

--------------------------------------------------------------------------------
-- LoadPixmap()
--
-- Loads or unloads pixmaps depending on which lexer is active and whether the
-- feature is active.
--------------------------------------------------------------------------------
function AutoItPixmap:LoadPixmap()
	-- Check to see if the user wants pixmaps.
	if self.IsEnabled() and self:IsEditorAvailable() then
		-- Ensure we only do this once.
		if not self:IsLexer(SCLEX_AU3) then
			if self:GetLoaded() then
				-- This doesn't play nice if another script has added an image.
				self:SetLoaded(false)
				self:SetVariableInUse(false)
				self:SetLibraryInUse(false)
				editor:ClearRegisteredImages()
				self:DebugPrint("Clearing")
			end
			return
		elseif self:GetLoaded() then
			self:DebugPrint("Skipping")
			return
		end
		self:DebugPrint("Loading")
		self:SetLoaded(true)

		-- Create a table where the key is the partial name of
		-- a property and the value is the image type.
		local images = {
			["function"] = -1,	-- The default for undefined entries.
			["special"] = 1,
			["preprocessor"] = 2,
			["macro"] = 3,
			["keyword"] = 4
		}

		-- Iterate over the table looking up the properties and
		-- registering any images that are found.
		for key, value in pairs(images) do
			local xpm_data = props["autoit.pixmap." .. key]
			if self:IsValidPixmap(xpm_data) then
				editor:RegisterImage(value, xpm_data)
				self:DebugPrint("Loaded: " .. key)
			end
		end
	end
end	-- LoadPixmaps()

--------------------------------------------------------------------------------
-- IsValidPixmap(data)
--
-- Checks to see if data string is a valid XPM string.
--
-- Parameters:
--	data - A string of data which is expected to contain the string /* XPM */.
--
-- Returns:
--	The value true if the data is a valid pixmap.
--	The value false if the data is not a valid pixmap.
--------------------------------------------------------------------------------
function AutoItPixmap:IsValidPixmap(data)
	return data:find("/%* XPM %*/")
end	-- IsValidPixmap()

--------------------------------------------------------------------------------
-- IsEnabled()
--
-- Gets whether the pixmap feature is enabled or not.
--
-- Returns:
--	The value true if the pixmap feature is enabled.
--	The value false if the pixmap feature is not enabled.
--------------------------------------------------------------------------------
function AutoItPixmap:IsEnabled()
	return props["autoit.use.pixmaps"] == "1"
end	-- IsEnabled()

--------------------------------------------------------------------------------
-- GetVariableInUse()
--
-- Gets whether the variable pixmap is in use.
--
-- Returns:
--	The value true if the variable pixmap is loaded.
--	The value false if the variable pixmap is not loaded.
--------------------------------------------------------------------------------
function AutoItPixmap:GetVariableInUse()
	return props["autoit.pixmap.using.variable"] == "1"
end	-- GetVariableInUse()

--------------------------------------------------------------------------------
-- SetVariableInUse(state)
--
-- Sets whether the variable pixmap is in use.
--
-- Parameters:
--	state - Either true or false depending on the desired state.
--------------------------------------------------------------------------------
function AutoItPixmap:SetVariableInUse(state)
	if state then
		props["autoit.pixmap.using.variable"] = "1"
	else
		props["autoit.pixmap.using.variable"] = "0"
	end
end	-- SetVariableInUse()

--------------------------------------------------------------------------------
-- GetLibraryInUse()
--
-- Gets whether the library pixmap is in use.
--
-- Returns:
--	The value true if the library pixmap is loaded.
--	The value false if the library pixmap is not loaded.
--------------------------------------------------------------------------------
function AutoItPixmap:GetLibraryInUse()
	return props["autoit.pixmap.using.library"] == "1"
end	-- GetLibraryInUse()

--------------------------------------------------------------------------------
-- SetLibraryInUse(state)
--
-- Sets whether the library pixmap is in use.
--
-- Parameters:
--	state - Either true or false depending on the desired state.
--------------------------------------------------------------------------------
function AutoItPixmap:SetLibraryInUse(state)
	if state then
		props["autoit.pixmap.using.library"] = "1"
	else
		props["autoit.pixmap.using.library"] = "0"
	end
end	-- SetLibraryInUse()

--------------------------------------------------------------------------------
-- GetLoaded()
--
-- Gets whether pixmaps are loaded or not.
--
-- Returns:
--	The value true if pixmaps are loaded.
--	The value false if pixmaps are not loaded.
--------------------------------------------------------------------------------
function AutoItPixmap:GetLoaded()
	return props["autoit.pixmaps.loaded"] == "1"
end	-- GetLoaded()

--------------------------------------------------------------------------------
-- SetLoaded(state)
--
-- Sets whether pixmaps are loaded or not.
--
-- Parameters:
--	state - Either true or false depending on the desired state.
--------------------------------------------------------------------------------
function AutoItPixmap:SetLoaded(state)
	if state then
		props["autoit.pixmaps.loaded"] = "1"
	else
		props["autoit.pixmaps.loaded"] = "0"
	end
end	-- SetLoaded()

--------------------------------------------------------------------------------
-- OnChar(...)
--
-- Dynamically changes the default pixmap depending on the context.  This works
-- around some limitations in SciTE.
--
-- Parameters:
--	... - Not Used.
--------------------------------------------------------------------------------
function AutoItPixmap:OnChar(...)
	if not self:IsLexer(SCLEX_AU3) then return end
	if self.IsEnabled() then
		local tCharVal = editor.CharAt[editor:WordStartPosition(editor.CurrentPos)]
		if tCharVal < 0 then 
			tCharVal = 256 + tCharVal 
		end 
		local char = string.char(tCharVal)
		local xpm_data
		if char == "$" then
			if not self:GetVariableInUse() then
				xpm_data = props["autoit.pixmap.variable"]
				if self:IsValidPixmap(xpm_data) then
					editor:RegisterImage(-1, xpm_data)
					self:DebugPrint("Registered: variable")
				else
					self:DebugPrint("Register failed: variable")
				end
				self:SetVariableInUse(true)
				self:SetLibraryInUse(false)
			end
		elseif char == "_"  then
			if not self:GetLibraryInUse() then
				xpm_data = props["autoit.pixmap.library"]
				if self:IsValidPixmap(xpm_data) then
					editor:RegisterImage(-1, xpm_data)
					self:DebugPrint("Registered: library")
				else
					self:DebugPrint("Register failed: library")
				end
				self:SetLibraryInUse(true)
				self:SetVariableInUse(false)
			end
		elseif self:GetVariableInUse() or self:GetLibraryInUse() then
			xpm_data = props["autoit.pixmap.function"]
			if self:IsValidPixmap(xpm_data) then
				editor:RegisterImage(-1, xpm_data)
				self:DebugPrint("Registered: function (default)")
			else
				self:DebugPrint("Register failed: function (default)")
			end
			self:SetVariableInUse(false)
			self:SetLibraryInUse(false)
		end
	end
end	-- OnChar()

--------------------------------------------------------------------------------
-- IsEditorAvailable()
--
-- This function does a safe check to see if the editor pane is accessible.  In
-- some cases, it's not accessible yet (at startup), so we will get a Lua error
-- normally.  However, this guards against the Lua error.
--
-- Returns:
--	The value true is returned if the editor pane is available, false otherwise.
--------------------------------------------------------------------------------
function AutoItPixmap:IsEditorAvailable()
	-- pcall() invokes a function in protected mode so that
	-- errors don't propagate.  Remember to pass editor
	-- as the first parameter since that is whats expected.
	return pcall(editor.WordStartPosition, editor, 0)
end	-- IsEditorAvailable()

--------------------------------------------------------------------------------
-- OnStartup()
--
-- Sets up the Pixmap information on startup.
--
-- Parameters:
--	... - Not Used.
--------------------------------------------------------------------------------
function AutoItPixmap:OnStartup()
	self.Debug = false
	self:LoadPixmap()
end	-- OnStartup()

--------------------------------------------------------------------------------
-- OnSwitchFile(...)
--
-- Sets up the Pixmap information when switching files.
--
-- Parameters:
--	... - Not Used.
--------------------------------------------------------------------------------
function AutoItPixmap:OnSwitchFile(...)
	self:LoadPixmap()
end	-- OnSwitchFile()

--------------------------------------------------------------------------------
-- OnOpen(...)
--
-- Sets up the Pixmap information when switching files.
--
-- Parameters:
--	... - Not Used.
--------------------------------------------------------------------------------
function AutoItPixmap:OnOpen(...)
	self:LoadPixmap()
end	-- OnOpen()
