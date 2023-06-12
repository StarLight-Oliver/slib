local PANEL = {}

function PANEL:Init()
	self.data = {} -- The data for the pie chart
	self.hoveredSegment = nil -- The currently hovered segment
end

function PANEL:SetData(data)
	self.data = data
end

function PANEL:SetDataOverTime(data, amount, overrideValue)

	local newData = {}

	for label, segData in pairs(data) do
		newData[label] = table.Copy(segData)
		newData[label].value = self.data[label] and self.data[label].value or 0
	end

	self.data = newData

	hook.Add("Think", self, function()
	
		local countEqual = 0

		for label, segData in pairs(data) do
			self.data[label].value = math.Approach(self.data[label].value, data[label].value, amount * FrameTime())

			if self.data[label].value == data[label].value then
				countEqual = countEqual + 1
			end
		end

		if countEqual == table.Count(data) then
			hook.Remove("Think", self)
		end
		self:OnCursorMoved(gui.MouseX(), gui.MouseY())

	end)

	-- timer.Create("PieChartTimer" .. tostring(self), time / 100, 100, function()
	-- 	for label, segData in pairs(data) do
	-- 		self.data[label].value = newData[label].value + segData.value / 100
	-- 	end

	-- 	self:OnCursorMoved(gui.MouseX(), gui.MouseY())

	-- 	-- self:SetData(newData)
	-- end)
end

function PANEL:OnCursorMoved(x, y)
	local mx, my = self:LocalCursorPos()
	local cx, cy = self:GetWide() / 2, self:GetTall() / 2
	local angle = math.deg(math.atan2(my - cy, mx - cx))
	if angle < 0 then
		angle = angle + 360
	end

	local startAngle = 0
	for label, segData in pairs(self.data) do
		local value = segData.value
		local segmentAngle = (value / self:GetTotal()) * 360
		if angle >= startAngle and angle < startAngle + segmentAngle then
			self.hoveredSegment = label
			break
		end

		startAngle = startAngle + segmentAngle
	end
end

function PANEL:OnCursorExited()
	self.hoveredSegment = nil
end

function PANEL:GetTotal()
	local total = 0
	for _, segData in pairs(self.data) do
		total = total + segData.value
	end
	return total
end

local function DrawPie(x, y, radius, startAngle, endAngle)
	local segments = math.ceil(math.abs(endAngle - startAngle) / 5)
	local segmentAngle = math.rad((endAngle - startAngle) / segments)
	local currentAngle = math.rad(startAngle)

	local vertices = {}

	-- Center point
	table.insert(vertices, { x = x, y = y, u = 0.5, v = 0.5 })

	-- Outer arc points
	for i = 0, segments do
		local xPos = x + math.cos(currentAngle) * radius
		local yPos = y + math.sin(currentAngle) * radius

		table.insert(vertices, { x = xPos, y = yPos, u = 0.5 + math.cos(currentAngle) / 2, v = 0.5 + math.sin(currentAngle) / 2 })

		currentAngle = currentAngle + segmentAngle
	end

	table.insert(vertices, { x = x, y = y, u = 0.5, v = 0.5 })

	-- Draw the polygon
	surface.DrawPoly(vertices)
end

function PANEL:Think()
	if not self:IsHovered() then
		self.hoveredSegment = nil
	end
end


function PANEL:Paint(width, height)
	local total = self:GetTotal()


	self.sizes = self.sizes or {}

	local sizes = self.sizes

	local startAngle = 0
	for label, segData in pairs(self.data) do
		local angle = (segData.value / total) * 360
		
		if not sizes[label] then
			sizes[label] = width/2 - 10
		end
		
		local size = sizes[label]
		local tagetSize = width/2 - 10
		if self.hoveredSegment == label then
			tagetSize = tagetSize + 10
		end

		if sizes[label] != tagetSize then
			sizes[label] = math.Approach(sizes[label], tagetSize, 100 * FrameTime())
		end

		size = sizes[label]

		if segData.Render then
			segData:Render(width / 2, height / 2, size, startAngle, startAngle + angle)
		else

			if segData.Color then
				surface.SetDrawColor(segData.Color)
			else
				surface.SetDrawColor( HSLToColor( (startAngle + angle / 2) % 360, 1, 0.5 ) ) -- Set the color to a random color
			end
	
			if segData.Texture then
				surface.SetMaterial( segData.Texture )
			else
				draw.NoTexture()
			end
			DrawPie(width / 2, height / 2, size, startAngle, startAngle + angle) -- Draw the pie slice
		end


		startAngle = startAngle + angle
	end

	-- Draw tooltip
	if self.hoveredSegment then
		local tooltipText = self.hoveredSegment .. ": " .. (self.data[self.hoveredSegment].value or "")
		local tooltipWidth, tooltipHeight = surface.GetTextSize(tooltipText)
		tooltipWidth = tooltipWidth + 10
		local tooltipX, tooltipY = self:LocalCursorPos()

		tooltipX = math.Clamp(tooltipX + 10, 0, width - tooltipWidth)
		tooltipY = math.Clamp(tooltipY, 0, height - tooltipHeight)
		surface.SetDrawColor(Color(255, 255, 255)) -- Set tooltip background color
		surface.DrawRect(tooltipX, tooltipY, tooltipWidth, 20)

		draw.SimpleText(tooltipText, "DermaDefault", tooltipX + 5, tooltipY + 5, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("PieChart", PANEL, "DPanel")


-- local dframe = vgui.Create("DFrame")
-- dframe:SetSize(500, 525)
-- dframe:MakePopup()
-- local dpanel = vgui.Create("PieChart", dframe)
-- dpanel:Dock(FILL)

-- local renderFn = function(self, x, y, radius, startAngle, endAngle)
-- 	surface.SetDrawColor(self.Color)
-- 	draw.NoTexture()
-- 	DrawPie(x, y, radius, startAngle, endAngle)

-- 	surface.SetDrawColor(Color(255, 255, 255))
-- 	surface.SetMaterial(self.Texture)
-- 	DrawPie(x, y, radius, startAngle, endAngle)
-- end

-- local coreData = {
-- 	["Jedi"] = {
-- 		Color = Color(81, 0, 255),
-- 		Texture = Material("star/jedi.png", "noclamp smooth"),
-- 		value = 10,
-- 		Render = renderFn,
-- 	},
-- 	["Sith"] = {
-- 		value = 20,
-- 		Texture = Material("star/sith.png", "noclamp smooth"),
-- 		Color = Color(255, 0, 0),
-- 		Render = renderFn,
-- 	},
-- }

-- local trueData = table.Copy(coreData)
-- trueData["Jedi"].value = 10
-- trueData["Sith"].value = 20

-- dpanel:SetDataOverTime(trueData, 40)

-- timer.Create("sith_jedi_random", 4, 0, function()

-- 	if not IsValid(dpanel) then return end

-- 	local trueData = table.Copy(coreData)
-- 	trueData["Jedi"].value = math.random(1, 100)
-- 	trueData["Sith"].value = math.random(1, 100)

-- 	dpanel:SetDataOverTime(trueData, 40)
-- end)

-- concommand.Add("add_neutral", function()

-- 	if not IsValid(dpanel) then return end

-- 	coreData["Neutral"] = {
-- 		value = 50,
-- 		Color = Color(103,129,155),
-- 		-- Texture = Material("star/neutral.png", "noclamp smooth"),
-- 		-- Render = renderFn,
-- 	}
-- end)