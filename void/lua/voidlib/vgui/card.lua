local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self.accent = VoidUI.Colors.Blue

    self.gradientStart = VoidUI.Colors.BlueLineGradientEnd
    self.gradientEnd = VoidUI.Colors.BlueGradientStart

    self.titleUpper = "Testing"
    self.titleLower = "Card"

    self.content = "Lorem ipsum, placeholder, placeholder. Blah blah blah blah, no one really cares."

    self.button = self:Add("VoidUI.Button")
    self.button:Dock(BOTTOM)
    self.button:SSetTall(45)

    self.button:MarginSides(45)
    self.button:MarginBottom(40)
end

function PANEL:SetTitle(lower, upper)
    self.titleUpper = upper
    self.titleLower = lower
end

function PANEL:SetContent(text)
    self.content = text
end

function PANEL:SetAccent(col)
    self.accent = col
    self.button:SetColor(col)
end

function PANEL:SetGradient(startCol, endCol)
    self:SetGradientStart(startCol)
    self:SetGradientEnd(endCol)
end

function PANEL:SetGradientStart(col)
    self.gradientStart = col
end
function PANEL:SetGradientEnd(col)
    self.gradientEnd = col
end

function PANEL:SetFooter(text)
    self.footer = text
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

    local x, y = self:LocalToScreen(0, 0)

    local baseX = sc(220)
    local verts = {
        {x = baseX + sc(15), y = 0},
        {x = baseX + sc(30), y = 0},
        {x = baseX + sc(15) - sc(30), y = h},
        {x = baseX - sc(30), y = h}
    }
    baseX = baseX + sc(25)
    local verts2 = {
        {x = baseX + sc(15), y = 0},
        {x = baseX + sc(40), y = 0},
        {x = baseX + sc(25) - sc(30), y = h},
        {x = baseX - sc(30), y = h}
    }

    VoidUI.StencilMaskStart()
        surface.SetDrawColor(VoidUI.Colors.White)
        draw.NoTexture()
        surface.DrawPoly(verts)
        surface.DrawPoly(verts2)
    VoidUI.StencilMaskApply()
        VoidUI.SimpleLinearGradient(x+sc(100), y, w-sc(100), h, self.gradientStart, self.gradientEnd)
    VoidUI.StencilMaskEnd()

    draw.SimpleText(self.titleUpper, "VoidUI.B28", sc(25), sc(25), self.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(self.titleLower, "VoidUI.B38", sc(25), sc(25) + sc(23), VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local wrappedText = VoidUI.TextWrap(self.content, "VoidUI.R18", sc(180))
    draw.DrawText(wrappedText, "VoidUI.R18", sc(25), sc(100), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if (self.footer) then
        draw.SimpleText(self.footer, "VoidUI.R14", sc(15), h-sc(10), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end

vgui.Register("VoidUI.Card", PANEL, "Panel")