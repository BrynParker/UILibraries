local PANEL = {}
AccessorFunc(PANEL, "m_fFraction", "Fraction")

Derma_Hook( PANEL, "Paint", "Paint", "Progress" )

TLib.Font("Progressbar", 18)

function PANEL:Init()
    self:SetMouseInputEnabled(false)
    self:SetFraction(0)

    self:RoundCorners(true, true, true, true)
end

function PANEL:GetFraction()
    return self.m_fFraction or 0
end

function PANEL:SetFraction(fFraction)
    self.m_fFraction = math.Clamp(fFraction, 0, 1)
    self:InvalidateLayout()
end

function PANEL:SetProgress(fProgress)
    self:SetFraction(fProgress)
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

function PANEL:ShowText()
    local w, h = self:GetSize()
    local radius = 8
    local thickness = 2

    self.PaintOver = function(self, w, h)
        draw.WordBox(radius, w / 2, h / 2, math.Round(self:GetFraction() * 100) .. "%", "TLib.Font.Progressbar", TLib.Theme.transparent, TLib.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:SetAccentColor(color)
    self.accent = color
end

function PANEL:RoundCorners(tl, tr, bl, br)
	self.rc_TopLeft = tl
	self.rc_TopRight = tr
	self.rc_BottomLeft = bl
	self.rc_BottomRight = br

	return self
end

function PANEL:Paint()
    local w, h = self:GetSize()
    local thickness = 2
    
    -- draw.RoundedBoxEx(TLib.Config.cornerradius, 0, 0, w, h, TLib.Theme.accentalpha, self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight)
    -- draw.RoundedBoxEx(TLib.Config.cornerradius, thickness, thickness, w - thickness * 2, h - thickness * 2, TLib.Theme.accent, self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight)
    
    TLib.DrawOutlinedBox(nil, 0, 0, w, h, nil, nil, self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight)

    draw.RoundedBoxEx(TLib.Config.cornerradius, thickness, thickness, self:GetFraction() * (w - thickness * 2), h - thickness * 2, self.accent or TLib.Theme.accentalpha, self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight)
end

vgui.Register("TLib.Progress", PANEL, "Panel")