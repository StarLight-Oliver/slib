return {
	Name = "PlayerLoad",
	Version = "1.0.0",
	Description = "This module adds a serverside hook for when a player fully loads on the client side.",
	Author = "StarLight",
	Client = {"cl_playerload.lua"},
	Server = {"sv_playerload.lua"},
	Shared = {},
	Data = {
		Server = {
			Hook = {
				["PlayerLoad"] = {
					Args = {"Player ply"},
				}
			}
		}
	}
}