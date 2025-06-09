local PANEL = {}

TLib.Font("RichText", 18)

function PANEL:Init()
    
    self:SetFontInternal("TLib.Font.RichText")
    self:AllowScroll(false)

    self.PerformLayout = function(self, w, h)
        self:SetFontInternal("TLib.Font.RichText")
    end

end

function PANEL:AddText(text, color)
    
    -- 255,250,250
    self:InsertColorChange(color.r or 255, color.g or 250, color.b or 250, color.a or 255)
    self:AppendText(text)

end

function PANEL:AddURL(text, url, color)
    
    self:InsertClickableTextStart(url)
    self:InsertColorChange(color.r or 255, color.g or 250, color.b or 250, color.a or 255)
    self:AppendText(text)
    self:InsertClickableTextEnd()

end

function PANEL:SetTextColor(color)
    
    self:InsertColorChange(color.r or 255, color.g or 250, color.b or 250, color.a or 255)

end

function PANEL:PerformLayout(w, h)
    
    self:SetFontInternal("TLib.Font.RichText")

end

function PANEL:SetFont(font)
    self.PerformLayout = function(self, w, h)
        self:SetFontInternal(font)
    end    
end

function PANEL:AllowScroll(bool)
    self:SetVerticalScrollbarEnabled(bool)
end

vgui.Register("TLib.RichText", PANEL, "RichText")


TLib.RichTextTest = function()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.5, ScrH() * 0.5)
    frame:Center()	
    frame:MakePopup()
    frame:SetTitle("RichText Test")
    

    local richText = frame:Add("TLib.RichText")
    richText:Dock(FILL)
    richText:SetVerticalScrollbarEnabled(true)
    richText:SetWrap(true)
    richText:AddText("Hello World!", Color(255, 255, 255))
    richText:AddText("Hello World!", Color(255, 0, 0))
    richText:AddURL("Hello World!", "https://google.com", Color(0, 255, 0))
end

concommand.Add("tlib_richtext_test", TLib.RichTextTest)



