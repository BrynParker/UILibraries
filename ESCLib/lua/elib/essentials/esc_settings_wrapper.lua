local settings_temp = {}

local function Capitalize(str)
	return (str:gsub("^%l", string.upper))
end

-----------------
/// VARS META ///
-----------------
local VarsMeta = {}
VarsMeta["__index"] = VarsMeta
function VarsMeta:Set(param, value)
	if not param or not value then return end
	self[param] = value
	return self
end

function VarsMeta:SetName(value)
	self:Set("name", value)
	return self
end

function VarsMeta:SetDesc(value)
	self:Set("desc", value)
	return self
end

function VarsMeta:SetNameTranslateKey(value)
	self:Set("name_tr", value)
	return self
end

function VarsMeta:SetDescTranslateKey(value)
	self:Set("desc_tr", value)
	return self
end

function VarsMeta:SetPosition(value)
	self:Set("sortOrder", value)
	return self
end

--Do nothing, just for support
function VarsMeta:RestartAddon(value)
	self:Set("restart_addon", value)
	return self
end

function VarsMeta:CustomCheck(fun)
	self:Set("customCheck", fun)
	return self
end

function VarsMeta:CanChange(change_type, change_who)
	local fun

	if type(change_type) == "boolean" then
		fun = function() return change_type or esclib:HasAdminAccess(LocalPlayer()) end
		self:Set("change_type",'boolean')
		self:Set("who_can_change",change_type)
	elseif (change_type == "steamid") then
		if type(change_who) ~= "table" then change_who = {change_who} end
		fun = function()
			return change_who[LocalPlayer():SteamID()] or esclib:HasAdminAccess(LocalPlayer())
		end
		self:Set("change_type",'steamid')
		self:Set("who_can_change",change_who)
	elseif (change_type == "usergroup") then
		if type(change_who) ~= "table" then change_who = {change_who} end
		fun = function()
			return change_who[LocalPlayer():GetUserGroup()] or esclib:HasAdminAccess(LocalPlayer())
		end
		self:Set("change_type",'usergroup')
		self:Set("who_can_change",change_who)
	end

	self:Set("customCheck", fun)
	return self
end

-----------------
/// TABS META ///
-----------------
local TabMeta = {}
TabMeta["__index"] = TabMeta
function TabMeta:Set(param, value)
	if not param or not value then return end
	self[param] = value
	return self
end

function TabMeta:SetName(value)
	self:Set("name", value)
	return self
end

function TabMeta:SetNameTranslateKey(value)
	self:Set("name_tr", value)
	return self
end

function TabMeta:SetPosition(value)
	self:Set("sortOrder", value)
	return self
end

function TabMeta:AddVar(var_uid, vtype)

	local vars = settings_temp["__all_vars"]
	if vars[var_uid] then
		print("[ESCLIB] [ERROR HELPER] This name is already exists, please take another one. Busy names:\n")
		for k,v in ipairs(table.GetKeys(vars)) do
			print(k,v)
		end
		print("\nStack trace: ")
		error("Not valid var name ("..tostring(var_uid)..")")
	end

	if not esclib.allowed_settings_types[vtype] then
		print("[ESCLIB] [ERROR HELPER] Valid types are:\n")
		for k,v in ipairs(table.GetKeys(esclib.allowed_settings_types)) do
			print(k,v)
		end
		print("\nStack trace: ")
		error("Not valid var type ("..tostring(vtype)..")")
	end


	local need_vars = table.Copy(esclib.allowed_settings_types[vtype]["important_vars"])
	table.Add(need_vars, esclib.allowed_settings_types[vtype]["secondary_vars"])

	local accessors = {}
	for id,var in ipairs(need_vars) do

		local var_name = tostring(var)
		local func_name = string.format("Set%s",Capitalize(var_name))
		accessors[func_name] = function(self, var)
			self[var_name] = var
			return self
		end

		-- AccessorFunc(accessors, tostring(var), Capitalize(tostring(var)))
	end
	table.Merge(accessors, VarsMeta)
	accessors["__index"] = accessors

	settings_temp["__all_vars"][var_uid] = true
	self["vars"][var_uid] = {}
	self["vars"][var_uid]["type"] = vtype
	setmetatable(self["vars"][var_uid],accessors)

	return self["vars"][var_uid]
end

function TabMeta:CustomCheck(fun)
	self:Set("customCheck", fun)
	return self
end


---------------------
/// SETTINGS META ///
---------------------
local settings_meta = {}
settings_meta["__index"] = settings_meta
function settings_meta:AddTab(uid)
	local uid = string.lower(uid)

	if self[uid] then
		print("[ESCLIB] [ERROR HELPER] This name is already exists, please take another one. Busy names:\n")
		for k,v in ipairs(table.GetKeys(self)) do
			print(k,v)
		end
		print("\nStack trace: ")
		error("Not valid tab name ("..tostring(uid)..")")
	end

	self[uid] = {["vars"] = {}}
	setmetatable(self[uid], TabMeta)

	return self[uid]
end

function settings_meta:Print()
	PrintTable(self)
end

function settings_meta:End()
	--check all
	for tab,tab_val in pairs(self) do
		local vars = tab_val["vars"]
		for varid,varc in pairs(vars) do
			for id,need in ipairs(esclib.allowed_settings_types[varc.type]["important_vars"]) do
				if varc[need] == nil then
					print("[ESCLIB] [ERROR HELPER] No important keys for "..varid.."! Needed keys:\n")
					for k,v in ipairs(esclib.allowed_settings_types[varc.type]["important_vars"]) do
						print(k,v)
					end
					print("\nStack trace: ")
					error(varid.." - not contains key ["..tostring(need).."]")
				end
			end
		end
	end

	local add_name = self.__addon
	esclib:GetAddons()[add_name]:RegisterSettings(self) -- Init settings and load from file

	if (CLIENT) then
		hook.Add("InitPostEntity",add_name.."_request_settings",function()
			esclib:GetAddons()[add_name]:RequestSettings()
			hook.Remove("InitPostEntity",add_name.."_request_settings")
		end)
	end
end


---------------
/// WRAPPER ///
---------------
function esclib:InitSettings(addon_uid)
	settings_temp = {}

	local addons = esclib:GetAddons()
	if not addons[addon_uid] then
		print("[ESCLIB] [ERROR HELPER] Addon uid not found. Available addons:\n")
		for k,v in ipairs(table.GetKeys(addons)) do
			print(k,v)
		end
		print("\nStack trace: ")
		error("Not valid addon uid ("..tostring(addon_uid)..")")
	end

	settings_meta["__addon"] = addon_uid
	settings_meta["__all_vars"] = {}

	setmetatable(settings_temp,settings_meta)
	-- settings_meta["__addon"] = addon_uid

	return settings_temp
end


-- local settings = esclib:InitSettings("ehud")

-- local tab = settings:AddTab("general")
-- tab:SetNameTranslateKey("tab_general")
-- tab:SetPosition(2)

-- local var = tab:AddVar("animtime", "float")
-- var:SetValue(0.15)

-- local var = tab:AddVar("vignette", "numslider")
-- -- print(var.SetMin)
-- var:SetValue(0.5)
-- var:SetMin(0)
-- var:SetMax(1)
-- var:SetDecimals(2)

-- settings:Print()
-- settings:End()
