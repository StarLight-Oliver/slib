local wisp = MODULE

if SERVER then
	local packetMeta = {
		Send = function(self, data)
			net.Start("wisp_internal")
				net.WriteUInt(self.id, 16)
				net.WriteBool(false)
				net.WriteTable(data)
			net.Send(self.player)
		end,
		Error = function(self, errMsg)
			net.Start("wisp_internal")
				net.WriteUInt(self.id, 16)
				net.WriteBool(true)
				net.WriteString(errMsg)
			net.Send(self.player)
		end,
	}

	packetMeta.__index = packetMeta

	util.AddNetworkString("wisp_internal")

	wisp.Listeners = wisp.Listeners or {}

	function wisp.Listen(name, func)
		wisp.Listeners[name] = func
	end

	net.Receive("wisp_internal", function(len, ply)

		local name = net.ReadString()
		local id = net.ReadUInt(16)

		local func = wisp.Listeners[name]

		local packet = setmetatable({
			player = ply,
			id = id,
		}, packetMeta)

		if func then
			local data = net.ReadTable()
			func(ply, data, packet)
		end
	end)
else
	wisp.id = wisp.id or 0
	wisp.Listeners = wisp.Listeners or {}


	local backMeta = {
		["Then"] = function(self, func)
			self.thenFunc = func
			return self
		end, 
		["Catch"] = function(self, func)
			self.catchFunc = func
			return self
		end,
		Cancel = function(self)
			self.canncelled = true
			return self
		end,
	}
	backMeta.__index = backMeta

	function wisp.Send(name, data)
		local id = wisp.id
		wisp.id = wisp.id + 1

		
		local back = setmetatable({ name = name}, backMeta)
		back.__index = back

		wisp.Listeners[id] = back
		
		net.Start("wisp_internal")
			net.WriteString(name)
			net.WriteUInt(id, 16)
			net.WriteTable(data)
		net.SendToServer()

		return back
	end

	net.Receive("wisp_internal", function(len)
		local id = net.ReadUInt(16)

		local isErr = net.ReadBool()

		local backer = wisp.Listeners[id]

		wisp.Listeners[id] = nil
		if not backer then return end

		if backer.cannceled then return end

		if isErr then
			local errMsg = net.ReadString()
			if backer.catchFunc then
				backer.catchFunc(errMsg)
			else
				ErrorNoHalt("wisp: no catch function for " .. backer.name .. " " .. id)
			end
		else
			local data = net.ReadTable()
			if backer.thenFunc then
				backer.thenFunc(data)
			else
				ErrorNoHalt("wisp: no then function for " .. backer.name .. " " .. id)
			end
		end
	end)
end



/*if SERVER then
	wisp.Listen("wisp_test", function(ply, data, packet)
		print("wisp_test", data)
		packet:Send({
			test = "test",
		})
	end)
else
	concommand.Add("wisp_test", function()
		wisp.Send("wisp_test", {
			test = "test2",
		}):Then(function(data)
			print(data.test)
		end)
	end)
end*/