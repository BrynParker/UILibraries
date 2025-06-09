local PANEL = {}

TLib.Font("Header", 22)

AccessorFunc(PANEL, "m_bIsMenuComponent", "IsMenu", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDraggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSizable", "Sizable", FORCE_BOOL)

function PANEL:Init()

	-- self.btnClose:SetVisible(false)
	-- self.btnMaxim:SetVisible(false)
	-- self.btnMinim:SetVisible(false)
	-- self.lblTitle:SetVisible(false)

	self:SetAccentColor(TLib.Theme.accent)

	self.title = self:Add("TLib.LabelPanel")
    self.title:SetFont("TLib.Font.Header")
    self.title:SetText("")
    self.title:SetTextInset(10, 0)
    self.title.Paint = nil


    self.closeBtn = self:Add("TLib.Button")
    self.closeBtn:SetText("")
    self.closeBtn:RoundCorners(false, true, false, true)
    self.closeBtn:SetOutline(TLib.Colors.red)
    self.closeBtn:SetBackgroundColor(ColorAlpha(TLib.Colors.red, 33))
    self.closeBtn.DoClick = function(pnl)
        self:AlphaTo(0, 0.1, 0, function()
            self:Remove()
        end)
    end
    self.closeBtn.PaintOver = function(pnl, w, h)
        TLib.DrawImage(16, 16, w - (16 * 2), h - (16 * 2), "https://i.ibb.co/SdGvwBp/closebutton.png", TLib.Theme.text.h1)
    end
    
    self.title.PerformLayout = function(pnl)
        pnl:SizeToContents()
		pnl:SetSize(pnl:GetWide() + 16, 48)
    end

    self.reloadbtn = self:Add("TLib.Button")
    self.reloadbtn:SetText("")
    self.reloadbtn:RoundCorners(true, false, true, false)
    self.reloadbtn:SetOutline(TLib.Colors.blue)
    self.reloadbtn:SetBackgroundColor(ColorAlpha(TLib.Colors.blue, 33))
    self.reloadbtn.DoClick = function(pnl)
        self:Remove()
        func()
    end
    self.reloadbtn.PaintOver = function(pnl, w, h)
        TLib.DrawImage(16, 16, w - (16 * 2), h - (16 * 2), "https://i.ibb.co/S5zjC6P/reloadbutton.png", TLib.Theme.text.h1)
    end

    -- self:DockPadding(0, 48, 0, 0)
    self:DockPadding(0, 55, 0, 0)

end

local valid = IsValid
function PANEL:PerformLayout(w, h)
	
    self.btnClose:SetVisible(false)
	self.btnMaxim:SetVisible(false)
	self.btnMinim:SetVisible(false)
	self.lblTitle:SetVisible(false)

	local titlepush = 0
	self.closeBtn:SetPos( self:GetWide() - 48, 0)
	self.closeBtn:SetSize( 48,48 )

	self.title:SetPos( 0, 0 )
	self.title:SetSize(  48, 48 )

	self.reloadbtn:SetPos( self:GetWide() - 96, 0 )
	self.reloadbtn:SetSize( 48,48 )
	titlepush = 48

    if IsValid(self.custombtn) then
        self.custombtn:SetPos(self:GetWide() - 96, 0)
        self.custombtn:SetSize(48, 48)


        self.reloadbtn:SetPos( self:GetWide() - 144, 0)
        self.reloadbtn:SetSize( 48,48 )
        titlepush = 96
    end

end

function PANEL:Close()
    self:Remove()
end

function PANEL:SetTitle(text)
    self.title:SetText(text)
end

function PANEL:SetReloadFunction(func)
    self.reloadbtn.DoClick = function(pnl)
        self:Remove()
        func()
    end
end

function PANEL:ShowCloseButton(bool)
    self.closeBtn:SetVisible(bool)
end

function PANEL:ShowReloadButton(bool)
    self.reloadbtn:SetVisible(bool)
end


function PANEL:SetupFrame(sizeW, sizeH, title, devbool, devbool2)
    self:SetTitle(title)
    self:MakePopup()
    self:ShowCloseButton(devbool or false)
    -- self:Reload(devbool2 or false)
    self:SetSize(sizeW, sizeH)
    self:Center()
    self:SizeTo(sizeW, sizeH, 0.9, 0, .1, function()
        self:Center()        
    end)

    if devbool2 == false then
        self.reloadbtn:SetVisible(false)
    end

    self:SetReloadFunction(devbool2 or false)
end

function PANEL:SetAccentColor(color)
    self.accentcolor = color
end

function PANEL:GetAccentColor()
    return self.accentcolor
end

function PANEL:CustomButton(icon, color, func)
    self.custombtn = self:Add("TLib.Button")
    self.custombtn:SetText("")
    self.custombtn:RoundCorners(false,false,false,false)
    self.custombtn:SetOutline(color or TLib.Colors.orange)
    self.custombtn:SetBackgroundColor(ColorAlpha(color or TLib.Colors.orange, 33))
    self.custombtn.DoClick = function(pnl)
        func()
    end
    self.custombtn.PaintOver = function(pnl, w, h)
        TLib.DrawImage(16, 16, w - (16 * 2), h - (16 * 2), icon, TLib.Theme.text.h1)
    end
end

function PANEL:Paint(w, h)
    -- TLib.DrawOutlinedBox(nil, 0, 55, w, h - 55, TLib.Theme.outline)
    -- TLib.DrawOutlinedBox(nil, 0, 0, w, 48, TLib.Theme.outline)
    
    local x, y = self:LocalToScreen()
	BSHADOWS.BeginShadow()
    TLib.DrawOutlinedBox(nil, x, y + 55, w, h - 55, TLib.Theme.outline)
    draw.RoundedBox(TLib.Config.cornerradius, x, y + 40, w, 10, self:GetAccentColor())
    TLib.DrawOutlinedBox(nil, x, y, w, 48, TLib.Theme.outline)

	BSHADOWS.EndShadow(1, 2, 2)

end

vgui.Register("TLib.Frame", PANEL, "DFrame")