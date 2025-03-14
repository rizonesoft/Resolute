--------------------------------------------------------------------------------
-- This library provides class factories and event manager for SciTE events.
-- To create a new class without events, assign the result of Class:new() to a
-- global variable.  For a class with events, use EventClass:new().  Example:
-- 	A basic object:
--	Basic = Class:new()
--	An object with events:
-- 	Event = EventClass:new()
--
-- To receive callbacks for SciTE events, just create a method named after the
-- event. Example:
-- 	function Test:OnChar(c) print(c) end
--
-- In addition to all the standard SciTE events, a special OnStartup() event
-- can be specified.  It will be invoked when BeginEvents() is called.
--
-- The class factories also support inheritance.  Pass each base object as
-- members to a new() method.  The metatable and base member's for each object
-- will be inherited by the new object.
-- NOTE: If more than one object has a member (or metatable member) with the
-- same name, then the right-most object (in the parameter list) takes
-- precedence.  For example, if Test3 inherits from Test1 and Test2 and both of
-- those have a member "Function", then the following will happen:
--	Test3 = Class:new(Test1, Test2) -- Test3:Function() will call Test2:Function().
--	Test3 = Class:new(Test2, Test1) -- Test3:Function() will call Test1:Function().
--
-- To use this file, call dofile("path to file") at the top of the Lua startup
-- script.  Any other modules using the EventClass object should have their
-- dofile() statements after this one.  Lastly, after all dofile() statements
-- and objects have been created, call EventClass:BeginEvents().  Example:
-- 	dofile(props["SciteDefaultHome"] .. "\\EventClass.lua")	-- Must always be loaded first.
-- 	dofile(props["SciteDefaultHome"] .. "\\Sample.lua")
--	EventClass:BeginEvents()
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- NewRawClass()
--
-- Creates a new object ready to go.
-- NOTE: This function should not be called from user scripts.
--
-- Returns:
--	An initialized object.
--------------------------------------------------------------------------------
function NewRawClass()
	return { }
end	-- NewRawClass()

-- Create a base class from which all newly constructed class will derive.
BaseClass = NewRawClass()

--------------------------------------------------------------------------------
-- DebugPrint(s)
--
-- Set self.Debug = true to allow debug messages to print.
--
-- Parameters:
--	s = The string to print.
--------------------------------------------------------------------------------
function BaseClass:DebugPrint(s)
	if self.Debug then print("Debug: " .. s) end
end	-- DebugPrint()


-- Create a class factory for constructing objects.
Class = NewRawClass()

--------------------------------------------------------------------------------
-- Class:new(...)
--
-- Class factory.  This function creates a new object.  Optionally allows an
-- object to inherit from other objects.
-- NOTE: This function should be used to construct all class objects that
-- require events.
--
-- Parameters:
--	... - Base classes to inherit from.  The new object will have each bases'
--	metatable and members.
--
-- Returns:
--	A new object.
--------------------------------------------------------------------------------
function Class:new(...)
	-- First create the object.
	local obj = NewRawClass()

	-- Copy all base members.
	for k,v in pairs(BaseClass) do
		obj[k] = v
	end

	-- We start with BaseClass' metatable or an empty one.
	local mt = getmetatable(BaseClass) or { }

	-- Loop through all the objects we need to inherti from.
	for i = 1, select("#", ...) do
		-- Get the base object and verify it's valid.
		local base = select(i, ...)
		if type(base) == "table" then
			-- Copy base's members to obj.
			for k,v in pairs(base) do
				obj[k] = v
			end
			-- Get base's metatable and verify it's valid.
			local bmt = getmetatable(base)
			if type(bmt) == "table" then
				-- Copy base's metatable to obj's metatable.
				for k,v in pairs(bmt) do
					mt[k] = v
				end
			end
		end
	end

	-- Set the metatable.
	setmetatable(obj, mt)

	return obj
end	-- new()

-- Create a class factory for constructing objects with SciTE events.
EventClass = Class:new()

--------------------------------------------------------------------------------
-- EventClass:new(...)
--
-- Class factory.  This function creates a new object and adds it to the event
-- queue.  Optionally allows an object to inherit from other objects.
-- NOTE: This function should be used to construct all class objects that
-- require events.
--
-- Parameters:
--	... - Base classes to inherit from.  The new object will have each bases'
--	metatable and members.
--
-- Returns:
--	A new object.
--------------------------------------------------------------------------------
function EventClass:new(...)
	local obj = Class:new(...)

	-- Add the object to EventClass' object table (for invoking callbacks).
	-- If this is the first object created, the table will be created.
	local t = EventClass.objects or { }
	table.insert(t, obj)
	EventClass.objects = t

	return obj
end	-- new()

--------------------------------------------------------------------------------
-- BeginEvents()
--
-- This enables the events.  It also calls OnStartup() for any already created
-- functions.  Any function created after this *will not* have OnStartup()
-- called.  This should be called after all the dofile() statements.
--------------------------------------------------------------------------------
function EventClass:BeginEvents()
	-- This lists all the SciTE events.
	local events = {
		"OnOpen",
		"OnClose",
		"OnSwitchFile",
		"OnSave",
		"OnBeforeSave",
		"OnChar",
		"OnKey",
		"OnSavePointReached",
		"OnSavePointLeft",
		"OnDwellStart",
		"OnDoubleClick",
		"OnMarginClick",
		"OnUserListSelection",
		"OnUpdateUI",
		"OnClear"
	}

	-- Create a function for each event handler.  We add these directly to
	-- the global table using their string names.
	for index, event in ipairs(events) do
		_G[event] = function (...) return EventClass:HandleEvent(event, ...) end
	end

	-- Call OnStartup() for each object (that has it).
	if self.objects then
		for index, obj in pairs(self.objects) do
			if obj.OnStartup then obj:OnStartup() end
		end
	end
end	-- BeginEvents()

--------------------------------------------------------------------------------
-- HandleEvent(event, ...)
--
-- This function handles all the events.  It looks up the functions by string
-- name and forwards all the parameters.
--
-- Parameters:
--		event - The name of the event/function.
--		... - The remaining arguments passed to us, which are forwarded to the
--			callback.
--
-- Returns:
--	The value true is returned if any one callback function returns true.
--	Otherwise the return value will be false.
--------------------------------------------------------------------------------
function EventClass:HandleEvent(event, ...)
	-- We return true back to SciTE if a callback returns true,
	-- however we don't actually abort as recommended.
	local block = false
	if self.objects then
		for index, obj in pairs(self.objects) do
			-- Look up function names in the metatable by string name.
			local fn = obj[event]
			if fn and fn ~= self[event] then
				-- Functions are expecting self so we must simulate this.
				block = fn(obj, ...) or block
			end
		end
	end
	return block
end	-- HandleEvent()
