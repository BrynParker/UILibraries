esclib.default_cl_settings = esclib.default_cl_settings or {}
esclib.server_uid = nil
esclib.net_cooldown = {}

local c_systime = SysTime
local sv_tab = "sv_esclib"
local settings_file_name = sv_tab.."/default_settings.json"
local uid_file_name = sv_tab.."/server_uid.json"

--------------------
/// NET COOLDOWN ///
--------------------
function esclib:SetNetCooldown(uid,ply,time)
	if not IsValid(ply) then return end
	if not self.net_cooldown[uid] then
		self.net_cooldown[uid] = {}
	end

	self.net_cooldown[uid][ply:SteamID64()] = c_systime() + time
end

function esclib:PlyHasNetCooldown(uid,ply)
	if self.net_cooldown[uid] then
		local res = (self.net_cooldown[uid][ply:SteamID64()] or 0) > (c_systime())

		if not res then
			self.net_cooldown[uid][ply:SteamID64()] = nil
			return false
		else
			return true
		end
	end
	return false
end

function esclib:AddCooldownFunc(net_name,ply,cooldown,func,dont_use_timer)
	if not esclib:PlyHasNetCooldown(net_name, ply) then	
		func()
		esclib:SetNetCooldown(net_name, ply, cooldown)
	elseif (not timer.Exists(net_name.."_net_cooldown")) and not (dont_use_timer) then
		timer.Create(net_name.."_net_cooldown", cooldown*1.1, 1, function()
			func()
		end)
	end		
end

--Clear cooldown (per 10 minutes)
timer.Create("esclib.NetCooldownCleaner", 600, 0, function()
	for uid,values in pairs(esclib.net_cooldown) do

		for steamid,time in pairs(values) do
			if time < c_systime() then
				esclib.net_cooldown[steamid] = nil
				continue
			end

			if not player.GetBySteamID64(steamid) then
				esclib.net_cooldown[steamid] = nil
				continue
			end
		end

	end
end)

local function GenerateUIDOnce()
	if file.Exists( uid_file_name, "DATA" ) then return end

	local uid = math.Rand(1, 51200)
	uid = tostring(uid)
	uid = string.gsub(uid, "%.", "0")

	esclib.server_uid = uid
	esclib.file:SaveVar(uid_file_name,{["uid"] = uid})
end



----------------------------------
/// DEFAULT CONFIG FOR PLAYERS ///
----------------------------------
--Load settings from file
table.Merge(esclib.default_cl_settings, esclib.file:ReadVar(settings_file_name,"settings") or {})

--
if not esclib.server_uid then
	esclib.server_uid = esclib.file:ReadVar(uid_file_name,"uid")

	if not esclib.server_uid then
		GenerateUIDOnce()
	end

	SetGlobalString("esclib.serveruid",esclib.server_uid)
end



--Config net strings
util.AddNetworkString("esclib.RequestConfig")
util.AddNetworkString("esclib.RequestServerConfig")
util.AddNetworkString("esclib.SendConfig")
util.AddNetworkString("esclib.SendServerConfig")
util.AddNetworkString("esclib.ClearConfig")
util.AddNetworkString("esclib.ClearServerConfig")

-------------------
/// SEND CONFIG ///
-------------------
local function OnRequestConfig(len,ply,addon)
	if table.IsEmpty(esclib.default_cl_settings) then return end

	local addon = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon or "") then return end

	--esclib:AddCooldownFunc(net_name,ply,cooldown,func,dont_use_timer)
	esclib:AddCooldownFunc(addon.."_".."RequestConfig", ply, 0.1, function()
		if not IsValid(ply) then return end
		if not esclib.default_cl_settings[addon] then return end
		print(string.format("[ESCLIB] Player: %s SteamID: %s requested CLIENT config", ply:Nick(), ply:SteamID()))

		local c_json = util.TableToJSON(esclib.default_cl_settings[addon])
		c_json = util.Compress( c_json )
		local bytes = #c_json

		net.Start("esclib.SendConfig")
			net.WriteString( addon )
			net.WriteUInt( bytes, 16 )
			net.WriteData( c_json, bytes )
			--print(string.format("[ESCLIB] [%s] %s bytes left for send config net.", addon ,65533 - net.BytesWritten()))
		net.Send(ply)
	end)
end
net.Receive("esclib.RequestConfig", OnRequestConfig)

-----------------------------
/// SAVE CONFIG ON SERVER ///
-----------------------------
local function OnGetClientConfig(len,ply,addon)
	if not esclib:HasAdminAccess(ply) then return end

	local net_name = "SendConfig"
	local cooldown = 0.1

	local addon_name = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon_name or "") then return end

	esclib:AddCooldownFunc(addon_name.."_"..net_name, ply, cooldown, function()
		if not IsValid(ply) then return end
		print(string.format("[ESCLIB] Player: %s SteamID: %s requested SAVE CLIENT config", ply:Nick(), ply:SteamID()))

		local all_addons = esclib:GetAddons()
		if not all_addons[addon_name] then return end

		local bytes = net.ReadUInt(16)
		local c_json = net.ReadData(bytes)

		local c_json = util.Decompress(c_json) or "{}"
		local json_string = c_json
		c_json = util.JSONToTable(c_json)

		if not esclib.default_cl_settings[addon_name] then esclib.default_cl_settings[addon_name] = {} end
		table.Merge(esclib.default_cl_settings[addon_name], c_json)

		esclib.file:SaveVar(settings_file_name,{settings=esclib.default_cl_settings})


		--Send config to all connected players
		c_json = util.Compress( json_string )
		local bytes = #c_json

		net.Start("esclib.SendConfig")
			net.WriteString( addon_name )
			net.WriteUInt( bytes, 16 )
			net.WriteData( c_json, bytes )
			-- print(string.format("[ESCLIB] [%s] %s bytes left for send config net.", addon_name ,65533 - net.BytesWritten()))
		net.Broadcast()
	end)
end
net.Receive("esclib.SendConfig", OnGetClientConfig)

------------------------------
/// CLEAR CONFIG ON SERVER ///
------------------------------
local function OnClearConfig(len,ply,addon)
	if not esclib:HasAdminAccess(ply) then return end

	local net_name = "ClearConfig"
	local cooldown = 0.1

	local addon_name = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon_name or "") then return end

	esclib:AddCooldownFunc(addon_name.."_"..net_name, ply, cooldown, function()
		if not IsValid(ply) then return end
		print(string.format("[ESCLIB] [%s] Player: %s SteamID: %s requested CLEAR CLIENT config", addon_name, ply:Nick(), ply:SteamID()))
		esclib.default_cl_settings[addon_name] = nil
		esclib.file:Remove(settings_file_name)
		esclib.file:SaveVar(settings_file_name,{settings=esclib.default_cl_settings})
	end)
end
net.Receive("esclib.ClearConfig", OnClearConfig)





-------------------------------
/// REQUEST SERVER SETTINGS ///
-------------------------------
local function OnRequestServerConfig(len,ply,addon)
	if not esclib:HasAdminAccess(ply) then return end

	local net_name = "RequestSvConfig"
	local cooldown = 0.1

	local addon_name = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon_name or "") then return end

	esclib:AddCooldownFunc(addon_name.."_"..net_name, ply, cooldown, function()
		if not IsValid(ply) then return end

		local to_send = esclib:GetAddon(addon_name)["data"]["settings"]
		if table.IsEmpty(to_send or {}) then return end

		local c_json = util.Compress( util.TableToJSON(to_send) )
		local bytes = #c_json

		net.Start("esclib.SendServerConfig")
			net.WriteString( addon_name )
			net.WriteUInt( bytes, 16 )
			net.WriteData( c_json, bytes )
		net.Send(ply)

	end)
end
net.Receive("esclib.RequestServerConfig", OnRequestServerConfig)


------------------------------------
/// REQUEST SAVE SERVER SETTINGS ///
------------------------------------
local function OnRequestSaveServerConfig(len,ply,addon)
	if not esclib:HasAdminAccess(ply) then return end

	local net_name = "RequestSaveSvConfig"
	local cooldown = 0.1

	local addon_name = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon_name or "") then return end

	esclib:AddCooldownFunc(addon_name.."_"..net_name, ply, cooldown, function()
		if not IsValid(ply) then return end
		print(string.format("[ESCLIB] Player: %s SteamID: %s requested SAVE SERVER config", ply:Nick(), ply:SteamID()))

		local c_json = esclib:NetReadCompressedTable()
		if not istable(c_json) then return end

		local addon = esclib:GetAddon(addon_name)
		table.Merge(addon.data.vars, c_json)
		addon:SyncVars(-1)
		addon:SaveSettings()

	end)
end
net.Receive("esclib.SendServerConfig", OnRequestSaveServerConfig)

-------------------------------------
/// REQUEST CLEAR SERVER SETTINGS ///
-------------------------------------
local function OnRequestClearServerConfig(len,ply,addon)
	if not esclib:HasAdminAccess(ply) then return end

	local net_name = "RequestClearSvConfig"
	local cooldown = 0.1

	local addon_name = net.ReadString() or (addon or "")
	if not esclib:HasAddon(addon_name or "") then return end

	esclib:AddCooldownFunc(addon_name.."_"..net_name, ply, cooldown, function()
		local addon = esclib:GetAddon(addon_name)
		addon:ReturnSettingsToDefault()
	end)
end
net.Receive("esclib.ClearServerConfig", OnRequestClearServerConfig)