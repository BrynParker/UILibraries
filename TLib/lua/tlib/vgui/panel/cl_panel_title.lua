
local PANEL = {}

AccessorFunc( PANEL, "m_bBackground",		"PaintBackground",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bBackground",		"DrawBackground",	FORCE_BOOL ) -- deprecated
AccessorFunc( PANEL, "m_bIsMenuComponent",	"IsMenu",			FORCE_BOOL )
AccessorFunc( PANEL, "m_bDisableTabbing",	"TabbingDisabled",	FORCE_BOOL )

AccessorFunc( PANEL, "m_bDisabled",	"Disabled" )
AccessorFunc( PANEL, "m_bgColor",	"BackgroundColor" )

TLib.Font("TitlePanel.SubHeader", 18)

function PANEL:Init()

	self:SetPaintBackground( true )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

    self.titledock = self:Add("DPanel")
    self.titledock:Dock(TOP)
    self.titledock:SetTall(self:GetTall() * 1)
    self.titledock.Paint = function() 
		draw.RoundedBox( TLib.Config.cornerradius, 0, 0, self:GetWide(), self:GetTall(), self.accentcolor or TLib.Theme.outline, true, true, false, false)
    end

    self.title = self.titledock:Add("TLib.Label")
    self.title:SetupDock(FILL)
    self.title:SetText("Title")
    self.title:SetTextInset(5,0)    
end

function PANEL:CenterTitle()
    self.title:SetTextInset(0,0)
    self.title:SetContentAlignment(5)
end

function PANEL:SetupTitle(text, bool, textcolor, font)

	self.title:SetText(text)

	if bool  == true then
		self.title:SetContentAlignment(5)
		self.title:SetTextInset(0,0)
	end

end

function PANEL:SubHeader(text)
	if IsValid(self.subheader) then
		self.subheader:Remove()
	end

	self.subheader = self:Add("TLib.LabelPanel")
	self.subheader:SetupDock(TOP, 0, 0, 0, 10)
	self.subheader:SetTall(30)
	self.subheader:Text(text)
	self.subheader:RoundCorners(false, false, true, true)
	self.subheader:SetFont("TLib.Font.TitlePanel.SubHeader")
end

function PANEL:SetDisabled( bDisabled )

	self.m_bDisabled = bDisabled

	if ( bDisabled ) then
		self:SetAlpha( 75 )
		self:SetMouseInputEnabled( false )
	else
		self:SetAlpha( 255 )
		self:SetMouseInputEnabled( true )
	end

end

function PANEL:SetEnabled( bEnabled )

	self:SetDisabled( !bEnabled )

end

function PANEL:IsEnabled()

	return !self:GetDisabled()

end

function PANEL:OnMousePressed( mousecode )

	if ( self:IsSelectionCanvas() && !dragndrop.IsDragging() ) then
		self:StartBoxSelection()
		return
	end

	if ( self:IsDraggable() ) then

		self:MouseCapture( true )
		self:DragMousePress( mousecode )

	end

end

function PANEL:OnMouseReleased( mousecode )

	if ( self:EndBoxSelection() ) then return end

	self:MouseCapture( false )

	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end

end


vgui.Register("TLib.TitlePanel", PANEL, "TLib.Panel")