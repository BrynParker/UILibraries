local PANEL = {}

TLib.Font("InfoPanel", 17)

function PANEL:Init()

    self:SetupDock(TOP, 5,5,5,5)
    self:SetTall(64)
    self:SetWide(200)

    self.infoleft = vgui.Create("DPanel", self)
    self.infoleft:SetupDock(LEFT, nil, nil,2)
    self.infoleft:SetWide(10)
    self.infoleft.Paint = function(s,w,h)
        draw.RoundedBoxEx(TLib.Config.cornerradius,0,0,w,h,self.AccentColor or TLib.Theme.accent, true, false, true, false)
    end

    self.holder = vgui.Create("TLib.Panel", self)
    self.holder:SetupDock(RIGHT)
    self.holder:SetWide(64)
    self.holder:DockPadding(5,5,5,5)
    self.holder:SetVisible(false)
    self.holder.Paint = function(s,w,h)
        TLib.DrawOutlinedBox(nil, 0,0, w, h, TLib.Theme.outline, TLib.Theme.panel)
    end

    self.infotitle = vgui.Create("TLib.Label", self)
    self.infotitle:SetupDock(TOP)
    self.infotitle:SetText("Nydal's Panel")
    self.infotitle:SetTextInset(3,0)

    self.div = vgui.Create("DPanel", self)
    self.div:SetupDock(TOP)
    self.div:SetTall(3)
    self.div.Paint = function(s,w,h)
        draw.RoundedBox(TLib.Config.cornerradius,0,0,self.infotitle:GetTextSize() + 10, h, self.AccentColor or TLib.Theme.accent)
    end


end

function PANEL:SetAccentColor(col)
    self.AccentColor = col 
end

function PANEL:SetTitle(title)
    self.infotitle:SetText(title)
end

function PANEL:SetContent(text)

    self.contents = vgui.Create("TLib.RichText", self)
    self.contents:SetupDock(FILL)

    self.contents:AddText(text, TLib.Theme.text.h1)
end

function PANEL:GetContent()
    return self.contents:GetText()
end

function PANEL:GetAccentColor()
    return self.AccentColor
end

function PANEL:Paint(w,h)
    -- draw.RoundedBox(TLib.Config.cornerradius,0,0,w,h,TLib.Theme.outline)
    TLib.DrawOutlinedBox(nil, 0,0, w, h, TLib.Theme.outline, TLib.Theme.outline)
end

function PANEL:SetAvatar(Player)
    local avatar = vgui.Create("AvatarImage", self.holder)
    avatar:SetupDock(FILL)
    avatar:SetPlayer( Player, 64 )
    self.holder:SetVisible(true)
end

function PANEL:URLImage(url, color)
    local img = vgui.Create("DPanel", self.holder)
    img:SetupDock(FILL)
    img.Paint = function(s,w,h)
        TLib.DrawImage(0,0, w,h, url, color or color_white)
    end
    self.holder:SetVisible(true)
end

function PANEL:SetModel(model)
    local mdl = vgui.Create("ModelImage", self.holder)
    mdl:SetupDock(FILL)
    mdl:SetModel(model)
    self.holder:SetVisible(true)
end

function PANEL:PerformLayout(w,h)
    self.holder:SetWide(h)
end

function PANEL:AddAction(text, func)

    local btn = vgui.Create("TLib.Button", self)
    btn:SetupDock(BOTTOM, 5,5,5,5)
    btn:SetText(text)
    btn:SetTall(32)
    btn.DoClick = func
    btn:SetAccentColor(self.AccentColor or nil)
    self:SetTall(self:GetTall() + 32 + 5)
    return btn
end

vgui.Register("TLib.InfoPanel", PANEL, "TLib.Panel")    