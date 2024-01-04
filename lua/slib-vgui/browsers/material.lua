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

	self:RebuildMaterials()
end

function PANEL:BuildLayout()
	local layout = vgui.Create("DIconLayout", self.scroll)
	layout:Dock(FILL)
	layout:SetSpaceX(5)
	layout:SetSpaceY(5)

	self.layout = layout
end

local helperMat = Material("osiris_overrides/helper")

local renderClearMat = function(mat)
	helperMat:SetTexture("$basetexture", mat:GetTexture("$basetexture"))
	surface.SetMaterial(helperMat)
end


function PANEL:RebuildMaterials()
	self.scroll:GetCanvas():Clear()

	self:BuildLayout()
	self.scroll:ScrollToChild(self.layout)

	local mdlPath = self.mdlPath or "materials"
	local files, folders = file.Find(mdlPath .. "/*", "GAME")

	local up = self.layout:Add("DButton")
	up:SetText("Up")
	up:SetSize(100, 100)
	up.DoClick = function()
		self.mdlPath = mdlPath:match("(.*)/[^/]*$")
		self:RebuildMaterials()
	end

	for _, folder in ipairs(folders) do
		local btn = self.layout:Add("DButton")
		btn:SetText(folder)
		btn:SetSize(100, 100)
		btn.DoClick = function()
			self.mdlPath = mdlPath .. "/" .. folder
			self:RebuildMaterials()
		end
	end

	for _, fileName in ipairs(files) do
		if fileName:EndsWith(".png") or fileName:EndsWith(".vmt") then

			local usefulName = fileName

			local isVMT = false

			if fileName:EndsWith(".vmt") then
				usefulName = fileName:sub(1, -5)
				isVMT = true
			end

			local btn = self.layout:Add("DButton")
			btn.mat = mdlPath .. "/" .. usefulName
			-- remove materials/ from the start
			btn.mat = btn.mat:sub( 11 )

			btn:SetSize(100, 100)
			btn.DoClick = function()
				self:OnSelect(btn.mat)
			end

			local mat = Material(btn.mat)
			btn.Paint = function(_, w, h)
				-- disable engine lighting
				render.SuppressEngineLighting(true)
				surface.SetDrawColor(255, 255, 255, 255)

				if isVMT then
					renderClearMat(mat)
				else
					surface.SetMaterial(mat)
				end
				surface.DrawTexturedRect(0, 0, w, h)
				render.SuppressEngineLighting(false)
			end

			local btn2 = btn:Add("DButton")
			btn2:SetText("")
			btn2:Dock(FILL)
			btn2.DoClick = btn.DoClick
			btn2.Paint = function(selfBtn, w, h)
				if selfBtn.Hovered then
					surface.SetDrawColor(255, 255, 255, 84)
					surface.DrawRect(0, 0, w, h)
				end

				if selfBtn.Depressed then
					surface.SetDrawColor(255, 0, 0, 128)
					surface.DrawRect(0, 0, w, h)
				end
			end
		end
	end
end

vgui.Register("SLMaterialBrowser", PANEL, "DPanel")

-- pnl:Rebuild()
-- pnl:DoModal()

-- return pnl