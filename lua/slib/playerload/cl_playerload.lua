hook.Add("HUDPaint", "SLIB.PlayerLoaded", function()

	net.Start("SLIB.PlayerLoaded")
	net.SendToServer()

	hook.Remove("HUDPaint", "SLIB.PlayerLoaded")
end)
