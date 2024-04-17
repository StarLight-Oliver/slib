
local matHelper = slib.require("mathelper")


local CustomRadialMenu = {}
AccessorFunc(CustomRadialMenu, "m_radius", "Radius", FORCE_NUMBER)
AccessorFunc(CustomRadialMenu, "m_innerRadius", "InnerRadius", FORCE_NUMBER)
AccessorFunc(CustomRadialMenu, "m_outerRadius", "OuterRadius", FORCE_NUMBER)

local function drawarc(x, y, r, startAng, endAng, step, cache)
	local positions = {}

	positions[1] = {
		x = x,
		y = y
	}

	for i = startAng - 180, endAng - 180, step do
		table.insert(positions, {
			x = x + math.cos(math.rad(i)) * r,
			y = y + math.sin(math.rad(i)) * r
		})
	end

	surface.DrawPoly(positions)

	return positions[math.Round(table.Count(positions) / 2 + 1)], positions[1], cache and positions or nil
end

local function drawSubSection(x, y, r, r2, startAng, endAng, step, cache)
	local positions = {}
	local inner = {}
	local outer = {}
	r2 = r + r2
	startAng = startAng or 0
	endAng = endAng or 0

	for i = startAng - 180, endAng - 180, step do
		table.insert(inner, {
			x = (x + math.cos(math.rad(i)) * r2),
			y = (y + math.sin(math.rad(i)) * r2)
		})
	end

	for i = startAng - 180, endAng - 180, step do
		table.insert(outer, {
			x = (x + math.cos(math.rad(i)) * r),
			y = (y + math.sin(math.rad(i)) * r)
		})
	end

	for i = 1, #inner * 2 do
		local outPoints = outer[math.floor(i / 2) + 1]
		local inPoints = inner[math.floor((i + 1) / 2) + 1]
		local otherPoints

		if i % 2 == 0 then
			otherPoints = outer[math.floor((i + 1) / 2)]
		else
			otherPoints = inner[math.floor((i + 1) / 2)]
		end

		table.insert(positions, {outPoints, otherPoints, inPoints})
	end

	for k, v in pairs(positions) do
		surface.DrawPoly(v)
	end

	return positions[math.Round(table.Count(positions) / 2 + 1)][3], {
		x = x,
		y = y
	}, cache and positions or nil
end

function CustomRadialMenu:Init()
	self.segmentCount = 0
	self.m_radius = ScrH() / 6
	self.m_innerRadius = 0
	self.m_outerRadius = ScrH() / 3
	self.outerRadius = 150
	self.selectedSegment = nil
	self.buttons = {}
	local oldSetRadius = self.SetRadius

	self.SetRadius = function(self, radius)
		local r2 = self:GetOuterRadius()
		self:SetSize((radius + r2) * 2, (radius + r2) * 2)
		oldSetRadius(self, radius)
		self:UpdateProperties()
	end

	local btn = vgui.Create("DButton", self)
	btn:SetText("Close")
	btn:SetSize(self:GetWide(), self:GetTall())
	btn:SetPos(0, 0)
	btn.TestHover = function(btn) return self.selectedSegment == nil end
	btn.Paint = function() return true end

	btn.DoClick = function()
		self:Close()
	end
end

function CustomRadialMenu:Close()
	self:Remove()

	if self.OnClose then
		self:OnClose()
	end
end

function CustomRadialMenu:Think()
	local mX, mY = gui.MousePos()
	local count = self.segmentCount

	if count == 0 then
		self.selectedSegment = nil

		return
	end

	mX, mY = self:ScreenToLocal(mX, mY)
	local x, y = self:GetWide() / 2, self:GetTall() / 2
	local ang = math.atan2(mY - y, mX - x)
	local selected = math.ceil((ang + math.pi) / (math.pi * 2) * count)
	local dist = (mX - x) ^ 2 + (mY - y) ^ 2
	local r = self:GetRadius()
	local r2 = self:GetOuterRadius()

	if dist < (r) ^ 2 or dist > (r2 + r) ^ 2 then
		selected = nil
	end

	if selected ~= self.selectedSegment then
		local old = self.selectedSegment
		self.selectedSegment = selected

		if self.OnSegmentHovered then
			self:OnSegmentHovered(selected, old)
		end
	end
end

local lerp = function(p, a, b)
	return a + (b - a) * p
end



function CustomRadialMenu:AddSegment()
	local step = 1
	self.segmentCount = self.segmentCount + 1
	local segID = self.segmentCount
	-- Create a new button
	local button = vgui.Create("DButton", self)
	button:SetText("")
	button:SetSize(self:GetWide(), self:GetTall())
	button:SetPos(0, 0)
	button.TestHover = function(btn) return segID == self.selectedSegment end
	button.DoClick = function() end

	button.SetIcon = function(self, iconName)
		self.icon = Material(iconName)
	end
	button.SetMaterial = function(self, mat)
		print(mat, "mat")
		self.icon = mat
	end

	button.hoverProg = 0

	button.Paint = function(self, w, h)
		
		draw.NoTexture()
		local x, y = w / 2, h / 2
		local startAng = self.startAng
		local endAng = self.endAng
		local halfAng = self.halfAng
		local r = self.radius
		local r2 = self.outerRadius
		local size = r2 / 2

		local cacheID = "radialmenu_" .. r .. "_" .. r2 .. "_"  .. segID .. "_" .. startAng .. "_" .. endAng .. "_" .. halfAng .. "_" .. size


		local centerX = x + math.cos(math.rad(halfAng)) * (r + r2 / 2)
		local centerY = y + math.sin(math.rad(halfAng)) * (r + r2 / 2)

		local hoverOffset = 0

		if self.Hovered then
			self.hoverProg = math.Approach(self.hoverProg or 0, 1, FrameTime() * 10)
		else
			self.hoverProg = math.Approach(self.hoverProg or 0, 0, FrameTime() * 10)
		end

		hoverOffset = -lerp(self.hoverProg, 0, 2)

		if self.Hovered or self.hoverProg != 0 then
			local mat = matHelper.CreateTexture(cacheID, w, h, function()
				surface.SetDrawColor(255, 255, 255, 255)
				draw.NoTexture()
				drawSubSection(x, y, r, r2, startAng, endAng, step)
			end, {
				["$vertexalpha"] = 1,
				["$vertexcolor"] = 1,
			})

			surface.SetMaterial(mat)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawTexturedRect(0, 0, w, h)

			surface.SetDrawColor(255, 210, 0)
			-- local oldSize = size
			size = math.ceil(size * 1.1)

			if self.icon then
				surface.SetMaterial(self.icon)
				surface.DrawTexturedRect(math.floor(centerX - size / 2 - hoverOffset), math.floor(centerY - size / 2 - hoverOffset), size, size)
			else
				draw.SimpleTextOutlined(self:GetText(), "DermaLarge", centerX, centerY, Color(255, 230, 0, 142), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(255, 230, 0, 142))
			end

			-- size = oldSize
		end

		surface.SetDrawColor(255, 255, 255, 255)

		if self.icon then
			surface.SetMaterial(self.icon)
			surface.DrawTexturedRect(math.floor(centerX - size / 2  + hoverOffset), math.floor(centerY - size / 2 + hoverOffset), size, size)
		else
			draw.SimpleText(self:GetText(), "DermaLarge", centerX, centerY, ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		return true
	end

	self.buttons[self.segmentCount] = button
	self:UpdateProperties()

	return button
end

function CustomRadialMenu:UpdateProperties()
	for i, btn in pairs(self.buttons) do
		local startAng = 360 / self.segmentCount * (i - 1)
		local endAng = 360 / self.segmentCount * i
		local halfAng = endAng - (endAng - startAng) / 2 + 180
		btn.startAng = startAng
		btn.endAng = endAng
		btn.halfAng = halfAng
		btn.radius = self:GetRadius()
		btn.outerRadius = self:GetOuterRadius()
		btn.innerRadius = self:GetInnerRadius()
	end
end

function CustomRadialMenu:Paint(w, h)
	if self.segmentCount == 0 then return end
	local cacheID = "radialmenu_" .. self:GetRadius() .. "_" .. self:GetOuterRadius() .. "_" .. self:GetInnerRadius() .. "_" .. w .. "_" .. h
	local x, y = w / 2, h / 2
	local startAng = 0
	local endAng = 360.5
	local r = self:GetRadius()
	local r2 = self:GetOuterRadius()
	local inner = self:GetInnerRadius()

	draw.NoTexture()

	local mat = matHelper.CreateTexture(cacheID, w, h, function()
		surface.SetDrawColor(255, 255, 255, 255)
		draw.NoTexture()
		drawSubSection(x, y, r, r2, startAng, endAng, 1)
		drawarc(x, y, r - inner, startAng, endAng, 1)
	end, {
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
	})

	surface.SetMaterial(mat)
	surface.SetDrawColor(30, 30, 30, 200)
	surface.DrawTexturedRect(0, 0, w, h)
	local selectedBtn = self.buttons[self.selectedSegment]

	if not selectedBtn then
		local mX, mY = self:ScreenToLocal(gui.MousePos())

		local backupBtn = {
			GetText = function() return "Close" end,
			Hovered = false
		}

		local dist = (mX - x) ^ 2 + (mY - y) ^ 2

		if dist < r ^ 2 then
			backupBtn.Hovered = true
		end

		selectedBtn = backupBtn
	end

	draw.SimpleText(selectedBtn:GetText(), "DermaLarge", x, y, Color(255, 255, 255, selectedBtn.Hovered and 255 or 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("SLRadialMenu", CustomRadialMenu, "DPanel")