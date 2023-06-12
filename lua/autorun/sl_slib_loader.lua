-- GLUA, 
-- load files from slib/folderName/requirements.lua and if dependencies are met load the files in the returned data
-- local loadedModules = {}
-- local failedModules = {}
-- local moduleQueue = {}

-- local attemptLoad = function(folderName, moduleData)
-- 	local clFiles = moduleData.Client or {}
-- 	local svFiles = moduleData.Server or {}
-- 	local shFiles = moduleData.Shared or {}

-- 	for _, fileName in ipairs(clFiles) do
-- 		local filePath = "slib/" .. folderName .. "/" .. fileName

-- 		if SERVER then
-- 			AddCSLuaFile(filePath)
-- 		else
-- 			include(filePath)
-- 		end
-- 	end

-- 	for _, fileName in ipairs(svFiles) do
-- 		local filePath = "slib/" .. folderName .. "/" .. fileName

-- 		if SERVER then
-- 			include(filePath)
-- 		end
-- 	end

-- 	for _, fileName in ipairs(shFiles) do
-- 		local filePath = "slib/" .. folderName .. "/" .. fileName

-- 		if SERVER then
-- 			AddCSLuaFile(filePath)
-- 		end

-- 		include(filePath)
-- 	end

-- 	loadedModules[folderName] = true

-- 	return true
-- end

-- local files, modules = file.Find("slib/*", "LUA")

-- -- build a load queue based on dependencies
-- for _, moduleName in pairs(modules) do
-- 	local moduleData = include("slib/" .. folder .. "/requirements.lua")

-- 	if not moduleData then
-- 		print("[ERROR] Module " .. moduleName .. " has no requirements.lua file")
-- 		continue
-- 	end

-- 	local moduleDependencies = moduleData["dependencies"] or {}
-- 	local canLoad = true

-- 	for _, dependency in pairs(moduleDependencies) do
-- 		if not loadedModules[dependency] then
-- 			canLoad = false
-- 			break
-- 		end
-- 	end

-- 	if not canLoad then
-- 		moduleQueue[moduleName] = moduleData
-- 		continue
-- 	end

-- 	attemptLoad(moduleName, moduleData)
-- end

-- if table.Count(moduleQueue) > 0 then
-- 	local size = 0

-- 	-- Neat little trick to break out with any failed modules
-- 	while size ~= table.Count(moduleQueue) do
-- 		size = table.Count(moduleQueue)

-- 		for moduleName, moduleData in pairs(moduleQueue) do
-- 			local moduleDependencies = moduleData["dependencies"] or {}
-- 			local canLoad = true

-- 			for _, dependency in pairs(moduleDependencies) do
-- 				if not loadedModules[dependency] then
-- 					canLoad = false
-- 					break
-- 				end
-- 			end

-- 			if not canLoad then continue end

-- 			if attemptLoad(moduleName, moduleData) then
-- 				moduleQueue[moduleName] = nil
-- 			end
-- 		end
-- 	end

-- 	-- store failed modules
-- 	for moduleName, moduleData in pairs(moduleQueue) do
-- 		failedModules[moduleName] = moduleData
-- 	end
-- end

if SERVER then
	AddCSLuaFile("slib-core/core.lua")
end

include("slib-core/core.lua") 