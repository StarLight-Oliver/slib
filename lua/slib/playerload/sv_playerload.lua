util.AddNetworkString("SLIB.PlayerLoaded")

local t = {}



net.Receive("SLIB.PlayerLoaded",function(_, ply)
	if t[ply:SteamID()] then return end
	// Nice try 
	hook.Run("SLIB.PlayerLoaded", ply)
	t[ply:SteamID()] = true
end)

hook.Add("PlayerDisconnected", "SLIB.PlayerLoaded", function(ply)
	t[ply:SteamID()] = nil
end)