
VoidLib.Tracker = VoidLib.Tracker or {}
VoidLib.Tracker.Watermark = false

VoidLib.Tracker.BlacklistedAddons = VoidLib.Tracker.BlacklistedAddons or {}

VoidLib.Tracker.Alert = nil

VoidLib.Tracker.Addons = VoidLib.Tracker.Addons or {}

net.Receive("VoidLib.Tracker.SyncAddon", function ()
    local addonName = net.ReadString()
    local onlyLocal = net.ReadBool()
    
    VoidLib.Lang:Init(addonName, onlyLocal) -- clientside init
end)

function VoidLib.Tracker:ShowLeakAlert(license, licenseNick, msg)
    if (IsValid(VoidLib.Tracker.Alert)) then return end

    local affectedAddons = table.GetKeys(VoidLib.Tracker.BlacklistedAddons)

    local alert = vgui.Create("VoidUI.LeakAlert")
    alert:Center()
    alert:MakePopup()
    alert:InitInfo(affectedAddons, license, licenseNick, msg)

    VoidLib.Tracker.Alert = alert
end


function VoidLib.Tracker:DrawWatermark(addonName)
    hook.Add("HUDPaint", "VoidLib.Tracker.Watermark", function ()

        local msg = string.format("You are playing on a server with an illegal copy of %s!", addonName)
        local msg2 = "Your personal data is at risk!"

        local col = table.Copy(VoidUI.Colors.Red)

        col.r = TimedSin(0.7, 185, 255, 2)

        draw.SimpleText("WARNING", "VoidUI.B48", 20, 20, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(msg, "VoidUI.B26", 20, 58, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(msg2, "VoidUI.B26", 20, 78, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end)
end

net.Receive("VoidLib.Tracker.Notify", function ()
    local msg = net.ReadString()
    local addonName = net.ReadString()

    local license = net.ReadString()
    local licenseNick = net.ReadString()

    local globalTable = _G[addonName]
    globalTable.PrintError(msg)

    chat.AddText(VoidUI.Colors.Blue, "[", addonName, "] ", VoidUI.Colors.Red, "[WARNING!] ", msg)

    if (!VoidLib.Tracker.Watermark and !string.find(msg, "license")) then
        VoidLib.Tracker:DrawWatermark(addonName)
    end

    VoidLib.Tracker.Watermark = true

    VoidLib.Tracker.BlacklistedAddons[addonName] = true

    timer.Simple(3, function ()
        VoidLib.Tracker:ShowLeakAlert(license, licenseNick, msg)
    end)
    
end)