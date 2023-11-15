VoidLib.CurrentNotification = nil

local prevY = -30
function VoidLib.Notify(upper, text, color, length)

    VoidLib.CurrentNotification = {
        start = CurTime(),
        upper = upper,
        text = text,
        color = color,
        length = length,
        goUp = false,
    }

    prevY = -30

    local origTime = CurTime()
    timer.Simple(length*0.7, function ()
        if (!VoidLib.CurrentNotification) then return end
        if (VoidLib.CurrentNotification.start != origTime) then return end
        VoidLib.CurrentNotification.goUp = true
    end)
    timer.Simple(length, function ()
        if (!VoidLib.CurrentNotification) then return end
        if (VoidLib.CurrentNotification.start != origTime) then return end
        VoidLib.CurrentNotification = nil
    end)
end

net.Receive("VoidLib.NotifyPlayer", function ()
    local upper = net.ReadString()
    local text = net.ReadString()
    local color = net.ReadColor()
    local length = net.ReadUInt(8)

    VoidLib.Notify(upper, text, color, length)
end)

hook.Add("DrawOverlay", "VoidUI.DrawNotifications", function ()
    if (!VoidLib.CurrentNotification) then return end
    local notify = VoidLib.CurrentNotification

    local h = 75

    surface.SetFont("VoidUI.R38")
    local textSize = surface.GetTextSize(notify.text)
    
    local w = textSize + 100

    local x = ScrW() / 2 - w/2

    local y = 0
    -- fake lerp!
    if (notify.goUp) then
        y = Lerp(notify.length * 2 * FrameTime(), prevY, -100)
    else
        y = Lerp(notify.length * 2 * FrameTime(), prevY, 60)
    end


    prevY = y


    surface.SetDrawColor(notify.color)
    surface.DrawRect(x, y, w, h)

    draw.SimpleText(notify.upper, "VoidUI.R24", x+w/2, y+5, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.SimpleText(notify.text, "VoidUI.R38", x+w/2, y+25, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

end)