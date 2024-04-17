local MODULE = MODULE

if SERVER then
	util.AddNetworkString("slib_chat")

	--[[
		@Docs Function Module
		@Name Send
		@Description Send a message to a client or clients
		@Param Table: data The message sent
		@ParamOptional any players: The players to send the message to, if not included sends to all players
	]]
	MODULE.Send = function(data, players)
		if not data or type(data) ~= "table" then
			error("data must be a table")

			return
		end

		local newData = {}
		local i = 1
		for k, v in ipairs(data) do
			local dataType = type(v)

			if dataType == "string" then
				newData[i] = v
				i = i + 1
			elseif dataType == "Player" then
				newData[i] = team.GetColor(v:GetTeam())
				newData[i + 1] = v:Nick()
				i = i + 2
			elseif (dataType == "table" or dataType == "Color") and IsColor(dataType) then
				newData[i] = v
				i = i + 1
			else

			end
		end


		net.Start("slib_chat")
		net.WriteTable(newData)

		if not players then
			net.Broadcast()
		else
			net.Send(players)
		end
	end
else
	net.Receive("slib_chat", function()
		local data = net.ReadTable()
		chat.AddText(unpack(data))
	end)
end