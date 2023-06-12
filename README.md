## SLIB a Light weight library

SLIB is a library that contains utilities that can be useful.
The advantage of slib over other libaries is that we only load what is required by users of our library.
No more will 30 thousand new functions be added for you to only use 3 of them.



# How does it work?
Developers just need to require the modules they use

```
hook.Add("SLIB.Load", "TrackerSystem", function()
	local chat = slib.require("chat")
	local newPlayerMsg = "New %s has spawned in at location %d %d %d"

	hook.Add("PlayerSpawn", "PLayerHasSpawned", function(ply)
		-- send a message to every one
		local msg = string.format(newPlayerMsg, ply:Nick(), ply:GetPos().x, ply:GetPos().y, ply:GetPos().z)

		chat.Send({Color(255, 0, 0), "[Tracker] ", color_white, msg})

		-- send a message to a player, table of tables or CRecipientFilter
		chat.Send({Color(255, 0, 0), "[Tracker] ", color_white, "The trackers have been made aware of you"})
	end)
end)
```