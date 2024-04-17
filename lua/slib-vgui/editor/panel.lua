
local PANEL = {}

function PANEL:Init()
	local scroll = vgui.Create("DScrollPanel", self)
	scroll:Dock(FILL)
	scroll:DockMargin(0, 0, 0, 0)
	scroll:SetPaintBackground(false)
	scroll:DockMargin(10,10,10,10)

	self.scroll = scroll

	local search = vgui.Create("DTextEntry", self)
	search:Dock(TOP)
	search:SetTall(40)
	search:DockMargin(10,10,10,10)
	search:SetPlaceholderText("Search")
	search.OnChange = function(searchNew)
		self:Search(searchNew:GetText())
	end
end

function PANEL:GetPanels()
	return self.Panels or {}
end

function PANEL:GetScroll()
	return self.scroll
end

function PANEL:Search(text)

	local pnls = self:GetPanels()

	text = string.lower(text)

	for key, value in pairs(pnls) do
		if string.find(string.lower(key), text) then
			value:SetVisible(true)
		else
			value:SetVisible(false)
		end
	end

	self:GetScroll():InvalidateChildren(true)

end

function PANEL:Clear()
	self.scroll:GetCanvas():Clear()
end

function PANEL:GetData()
	return self.Data or {}
end

function PANEL:SetData(data, noRebuild)
	self.Data = data
	if noRebuild then return end
	self:Rebuild()
end

function PANEL:SetChanges(changes, noRebuild)
	self.Changes = changes
	if noRebuild then return end
	self:Rebuild()
end

function PANEL:GetChanges()
	self.Changes = self.Changes or {}

	return self.Changes
end
function PANEL:Paint()

end

function PANEL:GetDataAndChanges()

	local newData = {}

	local data = self:GetData()
	local changes = self:GetChanges()

	for key, value in pairs(data) do

		newData[key] = value

		if changes[key] then
			newData[key].value = changes[key]
		end
	end

	return newData
end

function PANEL:Rebuild()
	self:Clear()

	local pnls = {}

	local data = self:GetData()
	local changes = self:GetChanges()

	self.Changes = changes


	local labels = {}

	for key, value in SortedPairs(data) do
		local panel = self.scroll:Add("DPanel")
		panel:Dock(TOP)
		panel:SetTall(20)
		panel:DockMargin(0, 0, 20, 5)
		panel.Paint = function(_, w, h)
			surface.SetDrawColor(0,0,0, 100)
			surface.DrawRect(0,0, w, h)
		end

		pnls[key] = panel

		if value.realm then
			local realm = panel:Add("DPanel")
			realm:Dock(LEFT)
			realm:SetWide(10)
			realm.Paint = function(_, w, h)
				local clr = Color(0,0,0, 100)
				if bit.band(value.realm, 1) == 1 then
					// Client
					clr.r = 255
				end

				if bit.band(value.realm, 2) == 2 then
					// Server
					clr.b = 255
				end

				surface.SetDrawColor(clr)
				surface.DrawRect(0,0, w, h)
			end
		end

		local label = panel:Add("DLabel")
		label:Dock(LEFT)
		label:SetText(key)
		label:SetFont("Trebuchet24")
		label:SetWide(400)
		label:DockMargin(40, 10, 0, 10)
		label:SizeToContents()
		label.Paint = function(_, w, h)
			draw.SimpleText(key, "Trebuchet24", 2, h/2 + 2, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(key, "Trebuchet24", 0, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			return true
		end

		panel:SetTall(label:GetTall() + 20)

		label:SetWide( self:GetWide()/2)

		labels[key] = label

		if value.type == "boolean" then
			local checkbox = panel:Add("DButton")
			checkbox:Dock(FILL)
			checkbox.value = value.value
			checkbox:SetText(value.value == true and "true" or "false")
			checkbox.DoClick = function(check)
				check.value = not check.value
				check:SetText(check.value == true and "true" or "false")

				self.Changes[key] = self.value
			end
			continue
		end

		if value.type == "string" then
			-- check to see if its a sound or a model
			-- if its a sound, add a button to play the sound
			-- if its a model, add a button to set the model from a list of models
			local bg = panel:Add("DPanel")
			bg:Dock(FILL)
			bg:DockPadding(10, 0, 10, 0)
			local label = bg:Add("DTextEntry")
			bg.Paint = function(_, w, h)

				local col = Color(23,23,23, 185)

				if label:HasFocus() then
					col = Color(0,0,0)
				end

				draw.RoundedBox(10, 0, 0, w, h, col)


				if label:HasFocus() then
					local cursor = label:GetCaretPos()
					print(cursor)
					local text = label:GetText()
					surface.SetFont(label:GetFont())
					local textWidth = surface.GetTextSize(text:sub(0, cursor) .. " ")

					local textX = 10

					textX = textX + textWidth

					surface.SetDrawColor(255,255,255)
					local quart = label:GetTall()/4
					-- surface.DrawLine(textX, label:GetTall()/4, textX, quart*3)
				end
			end

			label:Dock(FILL)
			label:SetText( tostring(value.value))

			label:SetUpdateOnType(true)

			label.OnValueChange = function(lab)
				local valueVar = lab:GetText()
				self.Changes[key] = valueVar
			end
			label:SetFont("Trebuchet18")
			label:SetPaintBackground(false)
			label:SetTextColor(Color(255,255,255))
			label:SetCursorColor(Color(255,255,255))

			if string.find(value.value, "sound") then
				local playBtn = panel:Add("DButton")
				playBtn:Dock(RIGHT)
				playBtn:SetText("Play")
				playBtn.DoClick = function(self)
					surface.PlaySound(value.value)
				end
			end

			if string.find(value.value, "models") then
				local playBtn = panel:Add("DButton")
				playBtn:Dock(RIGHT)
				playBtn:SetText("Set Model")
				playBtn.DoClick = function()
					local pnl = vgui.Create("DFrame")

					pnl:SetPos(self:LocalToScreen(0,0))
					pnl:SetSize(self:GetSize())
					pnl:SetTitle("Select Model")
					pnl:SetDraggable(false)

					self:Hide()

					pnl:MakePopup()
					pnl:DoModal()

					local browser = vgui.Create("SLModelBrowser", pnl)
					browser:Dock(FILL)

					pnl.OnClose = function()
						-- changes[key] = pnl:GetModel()
						self:Show()
						-- self:SetPos(pnl:GetPos())
						pnl:Remove()
					end

					browser.OnSelect = function(_, mdl)
						self:Show()
						-- self:SetPos(pnl:GetPos())
						self.Changes[key] = mdl
						label:SetText(mdl)
						pnl:Remove()
					end
				end
			end

			continue
		end

		if value.type == "number" then
			local label = panel:Add("DTextEntry")
			label:Dock(FILL)
			label:SetText( tostring(value.value))

			local baseSize = panel:GetTall()

			label.OnChange = function(pnl)
				if IsValid(pnl.label) then
					pnl.label:Remove()
				end

				local value

				if string.StartWith(pnl:GetText(), "0x") then
					value = tonumber(pnl:GetText(), 16)
				else
					value = tonumber(pnl:GetText())
				end

				if not value then
					local label = panel:Add("DLabel")
					label:Dock(TOP)
					label:SetText("Invalid number")
					label:SetColor(Color(255,0,0))
					label:SizeToContents()

					pnl.label = label
					panel:SetTall(baseSize + label:GetTall())
					self.scroll:InvalidateChildren(true)

					return
				else
					if IsValid(pnl.label) then
						pnl.label:Remove()
					end
					panel:SetTall(baseSize)
					self.scroll:InvalidateChildren(true)
				end
			end

			label.OnEnter = function(label)
				local value

				if string.StartWith(label:GetText(), "0x") then
					value = tonumber(label:GetText(), 16)
				else
					value = tonumber(label:GetText())
				end

				if not value then
					-- emit a warning sound
					surface.PlaySound("buttons/button10.wav")
					return
				end

				self.Changes[key] = value
			end
			continue
		end

		if value.type == "color" then
			local colorMixer = panel:Add("DColorMixer")
			colorMixer:Dock(FILL)
			colorMixer:SetColor(value.value)
			colorMixer.ValueChanged = function(colorMixerSelf, color)
				self.Changes[key] = color
			end

			panel:SetTall(200)
			continue
		end

		hook.Run("SLSettingsAddCustom", panel, key, value, self)

		panel:InvalidateLayout(true)
		-- panel:SizeToContents()
	end

	self.Labels = labels
	self.Panels = pnls
end

function PANEL:OnSizeChanged(w, h)
	self:Rebuild()
end

vgui.Register("SLSettings", PANEL, "DPanel")