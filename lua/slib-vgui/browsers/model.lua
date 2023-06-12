-- local pnl = vgui.Create("DFrame")
-- pnl:SetSize(ScrW() * 0.5, ScrH() * 0.5)
-- pnl:Center()
-- pnl:SetTitle("Model View")
-- pnl:MakePopup()

-- local scroll = vgui.Create("DScrollPanel", pnl)
-- scroll:Dock(FILL)


local PANEL = {}

DEFINE_BASECLASS("DScrollPanel")
function PANEL:Init()
	-- BaseClass.Init(self)

	local scroll = vgui.Create("DScrollPanel", self)
	scroll:Dock(FILL)
	self.scroll = scroll

	-- self:BuildLayout()

	self:RebuildModels()
end

function PANEL:BuildLayout()
	local layout = vgui.Create("DIconLayout", self.scroll)
	layout:Dock(FILL)
	layout:SetSpaceX(5)
	layout:SetSpaceY(5)

	self.layout = layout
end

function PANEL:RebuildModels()
	self.scroll:GetCanvas():Clear()

	self:BuildLayout()
	self.scroll:ScrollToChild(self.layout)

	local mdlPath = self.mdlPath or "models"
	local files, folders = file.Find(mdlPath .. "/*", "GAME")

	local up = self.layout:Add("DButton")
	up:SetText("Up")
	up:SetSize(100, 100)
	up.DoClick = function()
		self.mdlPath = mdlPath:match("(.*)/[^/]*$")
		self:RebuildModels()
	end

	for _, folder in ipairs(folders) do
		local btn = self.layout:Add("DButton")
		btn:SetText(folder)
		btn:SetSize(100, 100)
		btn.DoClick = function()
			self.mdlPath = mdlPath .. "/" .. folder
			self:RebuildModels()
		end
	end

	for _, fileName in ipairs(files) do
		if fileName:EndsWith(".mdl") then
			local btn = self.layout:Add("DModelPanel")
			btn:SetModel(mdlPath .. "/" .. fileName)
			btn:SetSize(100, 100)
			btn.DoClick = function()
				self:OnSelect(btn:GetModel())
			end

			function btn:LayoutEntity(ent)
				ent:SetAngles(Angle(0, RealTime() * 10, 0))
			end

			local btn2 = btn:Add("DButton")
			btn2:SetText("")
			btn2:Dock(FILL)
			btn2.DoClick = btn.DoClick
			btn2.Paint = function(self, w, h) 
				if self.Hovered then
					surface.SetDrawColor(255, 255, 255, 84)
					surface.DrawRect(0, 0, w, h)
				end

				if self.Depressed then
					surface.SetDrawColor(255, 0, 0, 128)
					surface.DrawRect(0, 0, w, h)
				end
			end
		end
	end
end

vgui.Register("SLModelBrowser", PANEL, "DPanel")

-- pnl:Rebuild()
-- pnl:DoModal()

-- return pnl