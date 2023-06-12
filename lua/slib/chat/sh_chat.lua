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

		net.Start("slib_chat")
		net.WriteTable(data)

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