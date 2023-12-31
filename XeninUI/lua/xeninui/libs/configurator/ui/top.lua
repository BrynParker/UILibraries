local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Title", 26)
XeninUI:CreateFont("Xenin.Configurator.Admin.Subtitle", 14)

function PANEL:Init()
	self.CloseBtn = self:Add("DButton")
	self.CloseBtn:Dock(RIGHT)
	self.CloseBtn:SetText("")
	self.CloseBtn.CloseButton = Color(100, 100, 100)
	self.CloseBtn.Alpha = 0
	self.CloseBtn.DoClick = function(pnl)
		self:GetParent():Remove()
	end
	self.CloseBtn.Paint = function(pnl, w, h)
		draw.RoundedBox(h / 2, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Red, pnl.Alpha))

		surface.SetDrawColor(pnl.CloseButton)
		surface.SetMaterial(XeninUI.Materials.CloseButton)
		surface.DrawTexturedRect(12, 12, w - 24, h - 24)
	end
	self.CloseBtn.OnCursorEntered = function(pnl)
		pnl:Lerp("Alpha", 255)
		pnl:LerpColor("CloseButton", Color(255, 255, 255))
	end
	self.CloseBtn.OnCursorExited = function(pnl)
		pnl:Lerp("Alpha", 0)
		pnl:LerpColor("CloseButton", Color(100, 100, 100))
	end

	self.Name = self:Add("DPanel")
	self.Name:Dock(LEFT)
	self.Name.Paint = function(pnl, w, h)
		local text = self.Text
		if isstring(text) then
			XeninUI:DrawShadowText(text, "Xenin.Configurator.Admin.Title", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, 150)
		elseif istable(text) then
			XeninUI:DualText({
				text[1],
				"Xenin.Configurator.Admin.Title",
				color_white,
				TEXT_ALIGN_LEFT,
				2,
				150
			}, {
				text[2],
				"Xenin.Configurator.Admin.Subtitle",
				Color(145, 145, 145),
				TEXT_ALIGN_LEFT,
				0,
				0
			}, 0, -2, w, h)
		end
	end

	self.Search = self:Add("Xenin.Configurator.Admin.SearchBar")
	self.Search:Dock(FILL)
	self.Search:DockMargin(36, 0, 250, 0)
	self.Search:SetPlaceholder("Search for anything")
	self.Search:SetIcon(XeninUI.Materials.Search, true)
end

function PANEL:SetText(text)
	self.Text = text
end

function PANEL:PerformLayout(w, h)
	self.CloseBtn:SetWide(h)

	local text = self.Text
	local nW
	if istable(text) then
		surface.SetFont("Xenin.Configurator.Admin.Title")
		local tW = surface.GetTextSize(text[1])
		surface.SetFont("Xenin.Configurator.Admin.Subtitle")
		local sW = surface.GetTextSize(text[2])
		nW = math.max(tW, sW)
	else
		surface.SetFont("Xenin.Configurator.Admin.Title")
		local tW = surface.GetTextSize(text)
		nW = math.max(tW, 170)
	end

	self.Name:SetWide(nW)
end

function PANEL:SetScript(script, ctr)
	self.script = script
	self.ctr = ctr

	self.Search:SetScript(script, ctr)
end

vgui.Register("Xenin.Configurator.Admin.Top", PANEL)
