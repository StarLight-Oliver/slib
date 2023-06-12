slib = slib or {}
slib.modules = slib.modules or {}
slib.vgui = slib.vgui or {}
slib.isLoading = {}

local function LoadModule(moduleName)
	local oldModule = MODULE
	MODULE = {}
	local path = "slib/" .. moduleName .. "/*.lua"
	local files, _ = file.Find(path, "LUA")

	for _, fileName in SortedPairsByValue(files) do
		local startsWith = string.sub(fileName, 1, 3)

		if startsWith == "sv_" then
			if SERVER then
				include("slib/" .. moduleName .. "/" .. fileName)
			end
		elseif startsWith == "cl_" then
			if SERVER then
				AddCSLuaFile("slib/" .. moduleName .. "/" .. fileName)
			else
				include("slib/" .. moduleName .. "/" .. fileName)
			end
		elseif startsWith == "sh_" then
			if SERVER then
				AddCSLuaFile("slib/" .. moduleName .. "/" .. fileName)
			end

			include("slib/" .. moduleName .. "/" .. fileName)
		end
	end

	print("Loaded module: " .. moduleName)
	local module = MODULE
	MODULE = oldModule
	module.Name = moduleName

	return module
end

function slib.require(moduleName)
	if slib.modules[moduleName] then return slib.modules[moduleName] end

	if slib.isLoading[moduleName] then
		ErrorNoHaltWithStack("Circular dependency detected: " .. moduleName .. "\n")

		return
	end

	slib.isLoading[moduleName] = true
	local moduleOverrride = hook.Run("SLIB.PreLoadModule", moduleName)

	if moduleOverrride then
		slib.isLoading[moduleName] = nil
		slib.modules[moduleName] = moduleOverrride

		return moduleOverrride
	end

	print("SLIB: Loading module: " .. moduleName)
	-- ErrorNoHaltWithStack("Loading module: " .. moduleName)
	-- local path = "slib/" .. moduleName .. "/*"
	local module = LoadModule(moduleName)
	slib.modules[moduleName] = module
	slib.isLoading[moduleName] = nil

	return module
end

function slib.requireVgui(moduleName)
	if slib.vgui[moduleName] then return true end

	if file.Find("slib-vgui/" .. moduleName .. ".lua", "LUA") then
		print("SLIB: Loading vgui: " .. moduleName)
		if CLIENT then
			include("slib-vgui/" .. moduleName .. ".lua")
		else
			AddCSLuaFile("slib-vgui/" .. moduleName .. ".lua")
		end
		slib.vgui[moduleName] = true

		return true
	end

	ErrorNoHaltWithStack("SLIB: Vgui Component not found: " .. moduleName .. "\n")
end

slib.Require = slib.require

hook.Add("Initialize", "SLIB.Load", function()
	print("slib loading")
	hook.Run("SLIB.Load")
end)