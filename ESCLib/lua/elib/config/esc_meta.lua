esclib.addon = esclib:Addon("esclib")
esclib.addon:SetName("ESClib")
esclib.addon:SetBranch("release")
esclib.addon:SetVersion('1.1')
esclib.addon:SetDescription("Brain for addons.")

if CLIENT then
	esclib.addon:SetColor(Color(255,53,73))
	esclib.addon:SetThumbnail(esclib.Materials["esclib_logo.png"])
end