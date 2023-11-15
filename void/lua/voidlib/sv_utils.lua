
-- https://github.com/Facepunch/garrysmod-requests/issues/718
hook.Add("PlayerInitialSpawn", "VoidLib.FullLoadSetup",function(ply)
    hook.Add("SetupMove", "VoidLib.SetupMove" .. ply:SteamID64(), function(_ply,_,cmd)
        if _ply == ply and not cmd:IsForced() then hook.Remove("SetupMove", "VoidLib.SetupMove" .. ply:SteamID64()) hook.Run("VoidLib.PlayerFullLoad", ply) end
    end)
end)