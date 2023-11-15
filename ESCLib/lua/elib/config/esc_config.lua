esclib.config = esclib.config or {}

esclib.config.AdminAccess = esclib.config.AdminAccess or {}

function esclib:ChangeAdminAccess(user_group,access)
	self.config.AdminAccess[user_group] = access
end

function esclib:HasAdminAccess(ply)
	return self.config.AdminAccess[esclib:GetUserGroup(ply)]
end

-----------------------
/// CLIENT SETTINGS ///
-----------------------
if CLIENT then
local settings = esclib:InitSettings("esclib")

local tab = settings:AddTab("general")
tab:SetNameTranslateKey("tab_general")

tab:AddVar("debug", "bool")
:SetNameTranslateKey("s_debug_name")
:SetValue(true)
:CanChange("steamid","STEAM_0:1:81619963") --example of using CanChange

tab:AddVar("drawblur", "bool")
:SetNameTranslateKey("s_drawblur_name")
:SetValue(true)

tab:AddVar("animtime", "float")
:SetNameTranslateKey("s_animationspeed_name")
:SetValue(0.15)
:SetMin(0.01)
:SetMax(3)

settings:End()
end