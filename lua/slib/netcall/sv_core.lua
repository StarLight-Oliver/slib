util.AddNetworkString("netcall.Call")
function MODULE.Call(funcName, ply, ...)

	net.Start("netcall.Call")
		net.WriteString(funcName)
		net.WriteTable({...})
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end