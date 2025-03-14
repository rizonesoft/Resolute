--------------------------------------------------------------------------------
-- SciTE startup script.
--------------------------------------------------------------------------------

-- A table listing all loaded files.
LoadLuaFileList = { }

--------------------------------------------------------------------------------
-- LoadLuaFile(file, directory)
--
-- Helper function for easily loading Lua files.
--
-- Parameters:
--	file - The name of a Lua file to load.
--	directory - If specified, file is looked for in that directory.  By default,
-- 		this directory is $(SciTEDefaultHome)\Lua.
--------------------------------------------------------------------------------
function LoadLuaFile(file, directory)
	if directory == nil then
		directory = props["SciteDefaultHome"] .. "\\Lua\\"
	end
	table.insert(LoadLuaFileList, directory .. file)
	dofile(directory .. file)
end	-- LoadLuaFile()

-- Load all the Lua files.
LoadLuaFile("Class.lua")	-- Always load first.
LoadLuaFile("Common.lua")	-- Always load second.
LoadLuaFile("AutoItPixmap.lua")
LoadLuaFile("AutoHScroll.lua")
LoadLuaFile("AutoItAutoComplete.lua")
LoadLuaFile("LUAAutoComplete.lua")
LoadLuaFile("AutoItIndentFix.lua")
LoadLuaFile("EdgeMode.lua")
LoadLuaFile("SmartAutoCompleteHide.lua")
LoadLuaFile("Tools.lua")
LoadLuaFile("AutoItTools.lua")
LoadLuaFile("AutoItGotoDefinition.lua")
LoadLuaFile("SciTE_extras.lua")
if os.getenv("SCITE_USERHOME") ~= nil then
	f = io.open(os.getenv("SCITE_USERHOME") .. "\\PersonalTools.lua")
	if f ~= nil then
		LoadLuaFile("PersonalTools.lua",os.getenv ("SCITE_USERHOME") .. "\\")
		f:close()
	end
else
	f = io.open(os.getenv("USERPROFILE") .. "\\PersonalTools.lua")
	if f ~= nil then
		LoadLuaFile("PersonalTools.lua",os.getenv ("USERPROFILE") .. "\\")
		f:close()
	end
end

-- Start up the events (Calls OnStartup()).
EventClass:BeginEvents()
