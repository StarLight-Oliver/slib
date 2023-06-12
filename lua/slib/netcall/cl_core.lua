
net.Receive("netcall.Call", function()
	local funcName = net.ReadString()
	local args = net.ReadTable()

	local stack = string.Explode(".", funcName)

	local tbl = _G

	for x = 1, #stack - 1 do
		tbl = tbl[stack[x]]
		if not tbl then
			ErrorNoHalt("netcall.Call: Could not find table " .. stack[x] .. " in " .. funcName .. "\n")
			return
		end
	end

	local finalName = stack[#stack]

	local isColon = string.find(finalName, ":")

	if isColon then
		tbl = tbl[string.sub(finalName, 1, isColon - 1)]
		finalName = string.sub(finalName, isColon + 1)
	end

	local func = tbl[finalName]

	if not func then
		ErrorNoHalt("netcall.Call: Could not find function " .. finalName .. " in " .. funcName .. "\n")
		return
	end
	if isColon then
		table.insert(args, 1, tbl)
	end

	local ret = {func(unpack(args))}
end)