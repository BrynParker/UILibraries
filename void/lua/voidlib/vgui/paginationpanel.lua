local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self.from = 1
    self.to = 6

    self.page = 1
    self.totalPages = 1


    self.showingPhrase = "Showing :from:-:to:"
    self.pagePhrase = "Page"
    self.fromPhrase = "From"


    local pageSelector = self:Add("Panel")
    pageSelector:Dock(RIGHT)
    pageSelector:SSetWide(220)
    pageSelector.Paint = function (s, w, h)
        draw.SimpleText(string.upper(self.pagePhrase), "VoidUI.R22", 0, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(VoidUI.Colors.Green)
        VoidUI.DrawCircle(sc(85), h/2, sc(10), 1)

        draw.SimpleText(self.page, "VoidUI.B20", sc(85), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.upper(self.fromPhrase), "VoidUI.R22", sc(150), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.totalPages, "VoidUI.B22", w-sc(20), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local pageLeft = pageSelector:Add("DButton")
    pageLeft:Dock(LEFT)
    pageLeft:SetText("")
    pageLeft:MarginLeft(60)
    pageLeft:SSetWide(10)
    pageLeft.Paint = function (s, w, h)
        local color = s:IsHovered() and VoidUI.Colors.Green or VoidUI.Colors.Gray
        draw.SimpleText("<", "VoidUI.B22", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    pageLeft.DoClick = function ()
        self.page = math.max(self.page - 1, 1)
        self.pageChangeFunc(self.page)
    end

    local pageRight = pageSelector:Add("DButton")
    pageRight:Dock(LEFT)
    pageRight:SetText("")
    pageRight:MarginLeft(30)
    pageRight:SSetWide(10)
    pageRight.Paint = function (s, w, h)
        local color = s:IsHovered() and VoidUI.Colors.Green or VoidUI.Colors.Gray
        draw.SimpleText(">", "VoidUI.B22", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    pageRight.DoClick = function ()
        self.page = math.min(self.page + 1, self.totalPages)
        self.pageChangeFunc(self.page)
    end

    self.pageSelector = pageSelector
end

function PANEL:SetTranslations(showing, page, from)
    self.showingPhrase = showing
    self.pagePhrase = page
    self.fromPhrase = from
end

function PANEL:SetFromTo(from, to)
    self.from = from
    self.to = to
end

function PANEL:TotalPages(total)
    self.totalPages = total
end

function PANEL:PageChange(func)
    self.pageChangeFunc = func
end

function PANEL:CurrentPage(page)
    self.page = page
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

    local fShowing = VoidLib.StringFormat(self.showingPhrase, {
        from = self.from,
        to = self.to
    })
    draw.SimpleText(string.upper(fShowing), "VoidUI.R22", sc(20), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidUI.PaginationPanel", PANEL, "Panel")