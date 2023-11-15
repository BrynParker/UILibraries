util.AddNetworkString("VoidLib.NotifyPlayer")

function VoidLib.Notify(ply, upper, text, color, length)

    if (!IsColor(color)) then
        color = Color(color.r, color.g, color.b, color.a)
    end

    net.Start("VoidLib.NotifyPlayer")
        net.WriteString(upper)
        net.WriteString(text)
        net.WriteColor(color)
        net.WriteUInt(length, 8)
    net.Send(ply)
end