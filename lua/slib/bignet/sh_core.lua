local bignet = MODULE

-- Emulated GMod Net Library
bignet = bignet or {}
local net_file = nil
local currentNetMessage = nil

function bignet.Start(packetType)
	if net_file then
		net_file:Close()
		ErrorNoHalt("bignet.Start: bignet message was already open, closing it error above.\n")
	end

	net_file = file.Open("bignet.txt", "wb", "DATA")
	currentNetMessage = packetType
end

function bignet.WriteBool(value)
	bignet.WriteBit(value and 1 or 0)
end

function bignet.ReadBool()
	return bignet.ReadBit() == 1
end

function bignet.WriteDouble(value)
	net_file:WriteDouble(value)
end

function bignet.ReadDouble() 
	local value = net_file:ReadDouble()
	return value
end

function bignet.WriteUInt(value, numBits)
	net_file:WriteULong(value)
end

function bignet.ReadUInt(numBits)
	local value = net_file:ReadULong()
	return value
end

function bignet.WriteInt(value, numBits)
	net_file:WriteLong(value)
end

function bignet.ReadInt(numBits)
	local value = net_file:ReadLong()
	return value
end

function bignet.WriteString(value)

	value = string.gsub(value, "\n", "/[n]/")

	net_file:WriteString(value)
end

function bignet.ReadString()

	local value = net_file:ReadLine()

	value = string.gsub(value, "/[n]/", "\n")

	return value
end

function bignet.WriteData(data)
	bignet.WriteString(data)
end

function bignet.ReadData() 
	return bignet.ReadString()
end

function bignet.WriteMatrix(matrix)
	for row = 1, 4 do
		for col = 1, 4 do
			bignet.WriteDouble(matrix[row][col])
		end
	end
end

function bignet.ReadMatrix()
	local matrix = Matrix()
	for row = 1, 4 do
		for col = 1, 4 do
			matrix[row][col] = bignet.ReadDouble()
		end
	end
	return matrix
end

function bignet.WriteVector(vector)
	for i = 1, 3 do
		bignet.WriteDouble(vector[i])
	end
end

function bignet.ReadVector()
	local vector = Vector(bignet.ReadDouble(), bignet.ReadDouble(), bignet.ReadDouble())
	return vector
end

function bignet.WriteColor(color)

	bignet.WriteDouble(color.r)
	bignet.WriteDouble(color.g)
	bignet.WriteDouble(color.b)
	bignet.WriteDouble(color.a)
end

function bignet.ReadColor() 
	local color = Color(bignet.ReadDouble(), bignet.ReadDouble(), bignet.ReadDouble(), bignet.ReadDouble())
	return color
end

function bignet.WriteBit(value)
	net_file:WriteByte(value and 1 or 0)
end

function bignet.ReadBit() 
	return net_file:ReadByte()
end

function bignet.WriteAngle(angle)
	for i = 1, 3 do
		bignet.WriteDouble(angle[i])
	end
end

function bignet.ReadAngle() 
	local angle = Angle(bignet.ReadDouble(), bignet.ReadDouble(), bignet.ReadDouble())
	return angle
end

bignet.WriteVars = {
	[TYPE_NIL] = function(t, v)
		bignet.WriteUInt(t, 8)
	end,
	[TYPE_STRING] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteString(v)
	end,
	[TYPE_NUMBER] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteDouble(v)
	end,
	[TYPE_TABLE] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteTable(v)
	end,
	[TYPE_BOOL] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteBool(v)
	end,
	[TYPE_ENTITY] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteEntity(v)
	end,
	[TYPE_VECTOR] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteVector(v)
	end,
	[TYPE_ANGLE] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteAngle(v)
	end,
	[TYPE_MATRIX] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteMatrix(v)
	end,
	[TYPE_COLOR] = function(t, v)
		bignet.WriteUInt(t, 8)
		bignet.WriteColor(v)
	end
}

function bignet.ReadType()
	local typeid = bignet.ReadUInt(8)
	local rv = bignet.ReadVars[typeid]
	if rv then return rv() end
	error("bignet.ReadType: Couldn't read type " .. typeid)
end

-- ReadVars table
bignet.ReadVars = {
	[TYPE_NIL] = function() return nil end,
	[TYPE_STRING] = function() return bignet.ReadString() end,
	[TYPE_NUMBER] = function() return bignet.ReadDouble() end,
	[TYPE_TABLE] = function() return bignet.ReadTable() end,
	[TYPE_BOOL] = function() return bignet.ReadBool() end,
	[TYPE_ENTITY] = function() return bignet.ReadEntity() end,
	[TYPE_VECTOR] = function() return bignet.ReadVector() end,
	[TYPE_ANGLE] = function() return bignet.ReadAngle() end,
	[TYPE_MATRIX] = function() return bignet.ReadMatrix() end,
	[TYPE_COLOR] = function() return bignet.ReadColor() end
}

function bignet.WriteType(v)
	local typeid = nil

	if IsColor(v) then
		typeid = TYPE_COLOR
	else
		typeid = TypeID(v)
	end

	local wv = bignet.WriteVars[typeid]
	if wv then return wv(typeid, v) end
	error("bignet.WriteType: Couldn't write " .. type(v) .. " (type " .. typeid .. ")")
end

function bignet.WriteTable(tab)
	for k, v in pairs(tab) do
		bignet.WriteType(k)
		bignet.WriteType(v)
	end

	-- End of table
	bignet.WriteType(nil)
end

function bignet.ReadTable()
	local tab = {}

	while true do
		local k = bignet.ReadType()
		if (k == nil) then return tab end
		tab[k] = bignet.ReadType()
	end

	return tab
end

function bignet.Send(ply)
	net_file:Close()
	net_file = nil
	local newFile = file.Open("bignet.txt", "r", "DATA")
	local data = newFile:Read()
	local packetcount = math.ceil(#data / 65500)
	local id = math.random(0, 65535)
	net.Start("bignet.start")
	net.WriteString(currentNetMessage)
	net.WriteUInt(packetcount, 16)
	net.WriteUInt(id, 16)
	net.Send(ply)

	for i = 1, packetcount do
		timer.Simple(i/100, function()
			local packet = string.sub(data, (i - 1) * 65500 + 1, i * 65500)
			net.Start("bignet.data")
			net.WriteUInt(id, 16)
			net.WriteUInt(i, 16)
			net.WriteString(packet)
			net.Send(ply)
		end)
	end
end

function bignet.SendToServer()
	net_file:Close()
	net_file = nil
	local newFile = file.Open("bignet.txt", "r", "DATA")
	local data = newFile:Read()
	local packetcount = math.ceil(#data / 65500)
	local id = math.random(0, 65535)
	net.Start("bignet.start")
	net.WriteString(currentNetMessage)
	net.WriteUInt(packetcount, 16)
	net.WriteUInt(id, 16)
	net.SendToServer()

	for i = 1, packetcount do
		timer.Simple(i/100, function()
			local packet = string.sub(data, (i - 1) * 65500 + 1, i * 65500)
			net.Start("bignet.data")
			net.WriteUInt(id, 16)
			net.WriteUInt(i, 16)
			net.WriteString(packet)
			net.SendToServer()
		end)
	end
end

bignet.Packets = {}

if CLIENT then

net.Receive("bignet.start", function(len, ply)
	local packetType = net.ReadString()
	local packetCount = net.ReadUInt(16)
	local id = net.ReadUInt(16)

	bignet.Packets[id] = {
		packetType = packetType,
		packetCount = packetCount,
		packets = {}
	}
end)

net.Receive("bignet.data", function(len, ply)
	local id = net.ReadUInt(16)
	local packetNum = net.ReadUInt(16)
	local packet = net.ReadString()
	bignet.Packets[id].packets[packetNum] = packet

	if table.Count(bignet.Packets[id].packets) == bignet.Packets[id].packetCount then
		local data = ""

		for i = 1, bignet.Packets[id].packetCount do
			data = data .. bignet.Packets[id].packets[i]
		end

		-- bignet.Packets[id] = nil
		local newFile = file.Open("bignet.txt", "w", "DATA")
		newFile:Write(data)
		newFile:Close()
		net_file = file.Open("bignet.txt", "r", "DATA")
		currentLine = net_file:Read()

		if bignet.Receivers[bignet.Packets[id].packetType] then
			xpcall(bignet.Receivers[bignet.Packets[id].packetType](ply), function() end)
			net_file:Close()
			net_file = nil
			-- file = nil
			bignet.Packets[id] = nil
		else
			ErrorNoHalt("bignet: no receiver for packet type " .. bignet.Packets[id].packetType .. "\n")
		end
	end
end)

else 
	bignet.AllowedPlayers = {}

	net.Receive("bignet.start", function(len, ply)
		local packetType = net.ReadString()
		local packetCount = net.ReadUInt(16)
		local id = net.ReadUInt(16)

		if not bignet.AllowedPlayers[ply] then return end
		if not bignet.AllowedPlayers[ply][packetType] then return end

		bignet.Packets[ply] = bignet.Packets[ply] or {}
		bignet.Packets[ply][id] = {
			packetType = packetType,
			packetCount = packetCount,
			packets = {}
		}
	end)

	function bignet.Allow(ply, res)
		bignet.AllowedPlayers[ply] = bignet.AllowedPlayers[ply] or {}
		bignet.AllowedPlayers[ply][res] = true
	end

	function bignet.Deny(ply, res)
		bignet.AllowedPlayers[ply] = bignet.AllowedPlayers[ply] or {}
		bignet.AllowedPlayers[ply][res] = nil

		if table.Count(bignet.AllowedPlayers[ply]) == 0 then
			bignet.AllowedPlayers[ply] = nil
			bignet.Packets[ply] = nil
		end
	end

	function bignet.DenyAll(ply)
		bignet.AllowedPlayers[ply] = nil
		bignet.Packets[ply] = nil
	end

	hook.Add("PlayerDisconnected", "bignet.DenyAll", function(ply)
		bignet.DenyAll(ply)
	end)

	net.Receive("bignet.data", function(len, ply)
		local id = net.ReadUInt(16)
		local packetNum = net.ReadUInt(16)
		local packet = net.ReadString()

		if not bignet.AllowedPlayers[ply] then return end
		if not bignet.Packets[ply] then return end
		if not bignet.Packets[ply][id] then return end

		bignet.Packets[ply][id].packets[packetNum] = packet

		if table.Count(bignet.Packets[ply][id].packets) == bignet.Packets[ply][id].packetCount then
			local data = ""

			for i = 1, bignet.Packets[ply][id].packetCount do
				data = data .. bignet.Packets[ply][id].packets[i] or ""
			end

			-- bignet.Packets[id] = nil
			local newFile = file.Open("bignet.txt", "w", "DATA")
			newFile:Write(data)
			newFile:Close()
			net_file = file.Open("bignet.txt", "r", "DATA")

			if bignet.Receivers[bignet.Packets[ply][id].packetType] then
				xpcall(bignet.Receivers[bignet.Packets[ply][id].packetType](ply), function() end)
				net_file:Close()
				net_file = nil
				-- file = nil
				bignet.Packets[ply][id] = nil
			else
				ErrorNoHalt("bignet: no receiver for packet type " .. bignet.Packets[ply][id].packetType .. "\n")
			end
		end
	end)
end

bignet.Receivers = bignet.Receivers or {}

bignet.Receive = function(name, func)
	bignet.Receivers[name] = func
end

if SERVER then
	util.AddNetworkString("bignet.start")
	util.AddNetworkString("bignet.data")
end