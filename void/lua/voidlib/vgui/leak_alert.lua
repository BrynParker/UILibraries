
local leakText = [[
Your personal data is at risk!
This server has been detected using leaked copies of addons.

These copies might contain backdoors which allow for remote code execution. 
It is strongly recommended to purchase a legal copy from gmodstore.com to avoid server damage caused by malware.
]]

local infoText = [[
License: %s
Addons: %s
]]

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self.startTime = SysTime()

    self.darkColor = Color(255,255,255,10)
end

function PANEL:InitInfo(affectedAddons, license, licenseNick, msg)

    local leakerInfo = licenseNick .. " (" .. license .. ")"
    affectedAddons = table.concat(affectedAddons, ", ")

    infoText = string.format(infoText, leakerInfo, affectedAddons)

    local contentPanel = self:Add("Panel")
    contentPanel:Dock(FILL)

    contentPanel:MarginSides(440)
    contentPanel:MarginTops(120)

    local warningTitle = contentPanel:Add("VoidUI.BackgroundPanel")
    warningTitle:Dock(TOP)
    warningTitle:SSetTall(95)
    warningTitle:MarginSides(340)

    warningTitle:CenterHorizontal()
    warningTitle:SetText("WARNING!")
    warningTitle:SetFont("VoidUI.B52")
    warningTitle:SetTextColor(VoidUI.Colors.Red)

    local infoPanel = contentPanel:Add("VoidUI.BackgroundPanel")
    infoPanel:Dock(TOP)
    infoPanel:MarginTop(75)
    infoPanel:SSetTall(260)

    infoPanel:SetText(msg or leakText)
    infoPanel:SetFont("VoidUI.R32")
    infoPanel:WrapText()

    local detailPanel = contentPanel:Add("VoidUI.BackgroundPanel")
    detailPanel:Dock(TOP)
    detailPanel:MarginTop(20)
    detailPanel:SSetTall(100)

    detailPanel:SetText(infoText)
    detailPanel:SetFont("VoidUI.R32")
    detailPanel:WrapText()

    local buttonPanel = contentPanel:Add("Panel")
    buttonPanel:Dock(TOP)
    buttonPanel:MarginTop(90)
    buttonPanel:MarginSides(200)
    buttonPanel:SSetTall(75)

    local safeButton = buttonPanel:Add("VoidUI.Button")
    safeButton:Dock(LEFT)
    safeButton:SSetWide(250)
    safeButton:SetText("Stay safe")
    safeButton.DoClick = function ()
        LocalPlayer():ConCommand("disconnect")
    end

    local dangerButton = buttonPanel:Add("VoidUI.Button")
    dangerButton:SetColor(VoidUI.Colors.Red)
    dangerButton:Dock(RIGHT)
    dangerButton:SSetWide(250)
    dangerButton:SetText("Accept risk")
    dangerButton.DoClick = function ()
        self:Remove()
    end

end
function PANEL:Paint(w, h)
    VoidUI.DrawBox(0,0,w,h,self.darkColor)
    VoidUI.DrawPanelBlur(self, 1.5)
end

vgui.Register("VoidUI.LeakAlert", PANEL, "Panel")
