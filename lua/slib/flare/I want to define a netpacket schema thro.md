I want to define a netpacket schema through chain functions.
You would define a packet by calling flare:Receive("name") and then define readings, 
```
flare:Receive("name"):AddArray("playerScores", function(arg)
	arg:AddString("playerName")
	:AddUInt("score", function(arg)
		arg:SetBytes(4)
	end)
end):AddUInt("name", function(arg)
	arg:SetBytes(16)
end):AddString("name"):Receive(function(ply, packet)
	-- do stuff
end)
```