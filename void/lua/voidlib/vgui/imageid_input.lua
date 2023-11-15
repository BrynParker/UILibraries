local PANEL = {}

function PANEL:Init()
	self.entry:SetPaintBackground(true)
	
	self.entry:SetFont("VoidUI.R26")

    self.imageProvider = "i.imgur.com/"
end

function PANEL:SetImageProvider(strProvider)
    self.imageProvider = strProvider
end

function PANEL:PerformLayout(w, h)
	self.entry:Dock(FILL)
	self.entry:DockMargin(ScrH() * 0.1203, 8, 10, 8)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Gray)

	local text = self.imageProvider
	text = string.Replace(text, ".png", "")
	text = string.Replace(text, "%s", "")
	text = string.Replace(text, "https://", "")
	text = string.Replace(text, "http://", "")

	draw.SimpleText(text, "VoidUI.R24", 10, h/2, VoidUI.Colors.TextGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidUI.ImageIDInput", PANEL, "VoidUI.TextInput")
