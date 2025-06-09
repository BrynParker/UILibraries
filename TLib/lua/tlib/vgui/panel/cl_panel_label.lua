local PANEL = {}


AccessorFunc(PANEL, "rc_TopLeft", "TopLeft")
AccessorFunc(PANEL, "rc_TopRight", "TopRight")
AccessorFunc(PANEL, "rc_BottomLeft", "BottomLeft")
AccessorFunc(PANEL, "rc_BottomRight", "BottomRight")

AccessorFunc( PANEL, "c_OutlineColor",	"OutlineColor" )

-- TLib.Font("Label", 20)

function PANEL:Init()

    self.holder = vgui.Create("TLib.Panel", self)
    self.holder:SetupDock(FILL, 5,5,5,5)
    self.holder.Paint = function(s, w, h)
        draw.RoundedBoxEx(TLib.Config.cornerradius, 0, 0, w, h, TLib.Theme.outline, self:GetRoundCorners())
    end

    self.label = vgui.Create("TLib.Label", self.holder)
    self.label:Dock(FILL)
    self.label:SetContentAlignment(5)

    self:RoundCorners(true, true, true, true)
end

function PANEL:SetOutline(col)
	self.c_OutlineColor = col
end

function PANEL:SetText(text)
    self.label:SetText(text)
end

function PANEL:SetFont(font)
    self.label:SetFont(font)
end

function PANEL:SetupText(text, font, align)
	self:SetText(text)
	self:SetFont(font or "TLib.Font.Button")
    self:Align(align or 5)
end

function PANEL:Align(align)
    self.label:SetContentAlignment(align)

    if align == 4 then
    self.label:SetTextInset(5,0)
    end
end

function PANEL:SizeToContents()
    self.label:SizeToContents()
    self:SetSize(self.label:GetWide() + 16, self.label:GetTall())
end

function PANEL:RoundCorners(tl, tr, bl, br)
	self.rc_TopLeft = tl
	self.rc_TopRight = tr
	self.rc_BottomLeft = bl
	self.rc_BottomRight = br

	return self
end

function PANEL:SetupFunction(func)
	self.DoClick = func
end

function PANEL:SetTextColor(col)
    self.label:SetTextColor(col)
end

function PANEL:Text(text, font, align)
	self:SetText(text)
	self:SetFont(font or "TLib.Font.Button")
	self:SetContentAlignment(align or 5)
end


vgui.Register("TLib.LabelPanel", PANEL, "TLib.Panel")