
local PANEL = {}

AccessorFunc( PANEL, "m_bBackground",		"PaintBackground",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bBackground",		"DrawBackground",	FORCE_BOOL ) -- deprecated
AccessorFunc( PANEL, "m_bIsMenuComponent",	"IsMenu",			FORCE_BOOL )
AccessorFunc( PANEL, "m_bDisableTabbing",	"TabbingDisabled",	FORCE_BOOL )

AccessorFunc( PANEL, "m_bDisabled",	"Disabled" )
AccessorFunc( PANEL, "m_bgColor",	"BackgroundColor" )

AccessorFunc( PANEL, "c_OutlineColor",	"OutlineColor" )
AccessorFunc( PANEL, "c_BackgroundColor",	"BackgroundColor" )
AccessorFunc( PANEL, "c_Shadow",	"Shadow" )

Derma_Hook( PANEL, "Paint", "Paint", "Panel" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "Panel" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "Panel" )

function PANEL:Init()

	self:SetPaintBackground( true )
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

	self:RoundCorners(true,true,true,true)
end

function PANEL:SetAccentColor(outlinecol, bgcol)
	self:SetOutline(outlinecol or TLib.Theme.outline)
	self:SetBackground(bgcol or TLib.Theme.background)
end

function PANEL:SetOutline(outlinecol)
	self.c_OutlineColor = col
end

function PANEL:GetOutlineColor()
	return self.c_OutlineColor
end

function PANEL:SetBackground(bgcol)
	self.c_BackgroundColor = col
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

function PANEL:RoundCorners(tl, tr, bl, br)
	self.rc_TopLeft = tl
	self.rc_TopRight = tr
	self.rc_BottomLeft = bl
	self.rc_BottomRight = br

	return self
end

function PANEL:GetRoundCorners()
	return self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight
end


function PANEL:Paint(w, h)
	TLib.DrawOutlinedBox(nil, 0,0,w,h, self.c_OutlineColor or nil, self.c_BackgroundColor or nil, self:GetRoundCorners())
end

function PANEL:SetType(type, ...)
	if type == "HOLDER" then
		self:SetupDock(FILL, 10, 10,10,10)
	elseif type == "DOCK" then
		self:SetupDock(..., 8,8,8,8)
	elseif type == "ELEMENT" then
		self:SetupDock(..., 5,5,5,5)
	end
end

vgui.Register("TLib.Panel", PANEL, "EditablePanel")