TLib.Font("TNRP_Head", 25, "Bauhaus Md BT")
TLib.Font("TNRP_Text", 16)


function TNRP:Notify( main_color , header_text , main_text, img )

    local type_color = main_color or Color(255, 0, 0)
    local value_head = header_text or ""
    local value_text = main_text or ""

    self = vgui.Create("TLib.Panel")
    self:SetPos(ScrW() * 0.74, ScrH() * 0.86)
    self:SetSize(ScrW() * 0.25, ScrH() * 0.1)
    self:SetDrawOnTop(true)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.75, 0)
    self:AlphaTo(0, 0.75, 4.5 + 0.75)
    function self:PaintOver(w, h)
        draw.RoundedBox(6, 0, 0, w, 32, type_color)
        draw.RoundedBox(6, 0, 0, w, 30, TLib.Theme.outline)

        draw.DrawText(value_head, "TLib.Font.TNRP_Head", 10, 2, type_color, TEXT_ALIGN_LEFT)

        if img then
            TLib.DrawImage(440, 0, 25, 25, img, TLib.Theme.green)
        end
    end

    self.richtext = vgui.Create("TLib.RichText", self)
    self.richtext:Dock(FILL)
    self.richtext:DockMargin(8,40,10,10)
    self.richtext:AppendText(value_text)
    self.richtext:SetVerticalScrollbarEnabled(false)
    function self.richtext:PerformLayout()
        self:SetFontInternal("TLib.Font.TNRP_Text")
    end

    timer.Simple(6, function()
        self:Remove()
    end)
    
    -- AdvancedNotify:NotifyPrint( main_color , header_text , main_text)
end


-- net.Receive("Steuerzahler.Notify", function(len)
--     Steuerzahler:Notify(net.ReadString(), net.ReadString(), net.ReadString())
-- end)

-- Steuerzahler:Notify(TLib.Theme.green, "Rechnungen", "Es stehen neue Rechnungen offen, Schau doch mal im Rechnungsmenü vorbei!")