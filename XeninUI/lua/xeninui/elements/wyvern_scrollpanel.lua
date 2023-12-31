local PANEL = {}

AccessorFunc(PANEL, "Padding", "Padding")
AccessorFunc(PANEL, "pnlCanvas", "Canvas")
AccessorFunc(PANEL, "m_scrollbarLeftSide", "ScrollbarLeftSide")
AccessorFunc(PANEL, "m_bBarDockOffset", "BarDockShouldOffset", FORCE_BOOL)

function PANEL:Init()
    self.pnlCanvas = vgui.Create("Panel", self)
    self.pnlCanvas.OnMousePressed = function(self, code)
        self:GetParent():OnMousePressed(code)end
    self.pnlCanvas:SetMouseInputEnabled(true)
    self.pnlCanvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    self.VBar = vgui.Create("XeninUI.Scrollbar.Wyvern", self)
    self.VBar:Dock(RIGHT)

    self:SetPadding(0)
    self:SetMouseInputEnabled(true)


    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)

    self.scrollDelta = 0
    self.scrollReturnWait = 0

    self:SetBarDockShouldOffset(true)


    self:SetBarDockShouldOffset(false)
    self.VBar:SetWide(8)
    self.VBar.Paint = function(pnl, w, h)
        draw.RoundedBox(w / 2, 0, 0, w, h, XeninUI.Theme.Navbar)
    end
    self.VBar.scrollbar.barAlpha = 0
    self.VBar.scrollbar.Paint = function(pnl, w, h)
        if self.VBar:GetEnabled() then
            pnl.barAlpha = pnl.barAlpha + (1 - pnl.barAlpha) * 10 * FrameTime()
        else
            pnl.barAlpha = pnl.barAlpha + (0 - pnl.barAlpha) * 10 * FrameTime()
        end

        draw.RoundedBox(w / 2, 0, 0, w, h, Color(75, 75, 75, 255 * pnl.barAlpha))
    end
    self.VBar:SetVisibleFullHeight(true)
end

function PANEL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

function PANEL:OnChildAdded(child)
    self:AddItem(child)
end

function PANEL:SizeToContents()
    self:SetSize(self.pnlCanvas:GetSize())
end

function PANEL:GetVBar()
    return self.VBar
end

function PANEL:GetCanvas()
    return self.pnlCanvas
end

function PANEL:InnerWidth()
    return self:GetCanvas():GetWide()
end

AccessorFunc(PANEL, "m_scrollbarLeftSide", "ScrollbarLeftSide")

function PANEL:Rebuild()
    self:GetCanvas():SizeToChildren(false, true)

    if self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall() then
        self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
    end
end

function PANEL:Think()
    if not self.lastThink then self.lastThink = CurTime()end
    local elapsed = CurTime() - self.lastThink
    self.lastThink = CurTime()

    if self.scrollDelta > 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll >= 0 then
            self.scrollDelta = self.scrollDelta - 10 * elapsed
        end
        if self.scrollDelta < 0 then self.scrollDelta = 0 end
    elseif self.scrollDelta < 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll <= self.VBar.CanvasSize then
            self.scrollDelta = self.scrollDelta + 10 * elapsed
        end
        if self.scrollDelta > 0 then self.scrollDelta = 0 end
    end

    if self.scrollReturnWait >= 1 then
        if self.VBar.Scroll < 0 then
            if self.VBar.Scroll <= -75 and self.scrollDelta > 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + (self.VBar.Scroll / 1500 - 0.01) * 100 * elapsed

        elseif self.VBar.Scroll > self.VBar.CanvasSize then
            if self.VBar.Scroll >= self.VBar.CanvasSize + 75 and self.scrollDelta < 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + ((self.VBar.Scroll - self.VBar.CanvasSize) / 1500 + 0.01) * 100 * elapsed
        end
    else
        self.scrollReturnWait = self.scrollReturnWait + 10 * elapsed
    end
end

function PANEL:OnMouseWheeled(delta)
    if (delta > 0 and self.VBar.Scroll <= self.VBar.CanvasSize * 0.005) or (delta < 0 and self.VBar.Scroll >= self.VBar.CanvasSize * 0.995) then
        self.scrollDelta = self.scrollDelta + delta / 10
        return
    end

    self.scrollDelta = delta / 2
    self.scrollReturnWait = 0

end

function PANEL:OnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel)
    self:PerformLayout()

    local x, y = self.pnlCanvas:GetChildPosition(panel)
    local w, h = panel:GetSize()




    self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end


function PANEL:PerformLayout()
    if self:GetScrollbarLeftSide() then
        self.VBar:Dock(LEFT)
    else
        self.VBar:Dock(RIGHT)
    end

    local wide = self:GetWide()
    local xPos = 0
    local yPos = 0

    self:Rebuild()

    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    yPos = self.VBar:GetOffset()

    if self.VBar.Enabled or not self:GetBarDockShouldOffset() then
        wide = wide - self.VBar:GetWide()

        if self:GetScrollbarLeftSide() then
            xPos = self.VBar:GetWide()
        end
    end

    self.pnlCanvas:SetPos(xPos, yPos)
    self.pnlCanvas:SetWide(wide)

    self:Rebuild()
end

function PANEL:Clear()
    return self.pnlCanvas:Clear()
end

function PANEL:Paint(w, h) end

vgui.Register("XeninUI.Scrollpanel.Wyvern", PANEL, "DPanel")
