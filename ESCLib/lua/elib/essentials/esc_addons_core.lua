esclib.addons = esclib.addons or {}

------------------------
/// SHARED FUNCTIONS ///
------------------------
--Just for ability to change usergroup function
function esclib:GetUserGroup(ply)
	return ply:GetUserGroup()
end

function esclib:GetAddons()
	return self.addons
end

function esclib:GetAddon(uid)
	return self.addons[uid]
end

function esclib:HasAddon(uid)
	return self.addons[uid] ~= nil
end

function esclib:NetWriteCompressedTable(to_send, bits)
	local bits = bits or 16

	local c_json = util.Compress( util.TableToJSON(to_send) )
	local jsbytes = #c_json

	net.WriteUInt( jsbytes, bits )
	net.WriteData( c_json, jsbytes )
end

function esclib:NetReadCompressedTable(bits,pretty)
	local bits = bits or 16

	local bytes = net.ReadUInt(bits)
	local c_json = net.ReadData(bytes)
	c_json = util.Decompress(c_json) or "{}"

	c_json = util.JSONToTable(c_json, pretty)

	return c_json
end

function esclib:GetServerHash()
	if SERVER then return "" end

	return GetGlobalString("esclib.serveruid", "")
end


-----------------
/// SKIN BASE ///
-----------------
local skin_base = {}
skin_base["default"] = {}
skin_base["default"].roundsize = 8
skin_base["default"].colors = {}
skin_base["default"].colors.default = {
	red = Color(252, 29, 59),
	green = Color(30, 215, 96),
	blue = Color(30,33,250),
	white = Color(255,255,255),
	black = Color(13,13,13),
	orange = Color(255, 117, 23),
	shadow = Color(0,0,0,255),
}

------------------
/// ADDON META ///
------------------
local AddonMeta = {
	GetName = function(self) return self.info.name end,
	GetDescription = function(self) return self.info.description end,
	GetColor = function(self) return self.info.color end,
	GetVar = function(self,varid) return self.data.vars[varid] end,
	GetBranch = function(self) return self.info.branch end,
	GetVersion = function(self) return self.info.version end,
	GetWrappedVar = function(self, tab,var) --just safe function
		if not self.data.settings[tab] then return end
		return self.data.settings[tab][var]
	end,

	SetName = function(self, newname)
		self.info.name = newname
	end,
	SetBranch = function(self, branch)
		self.info.branch = branch
	end,
	SetVersion = function(self, newversion)
		self.info.version = newversion
	end,
	SetDescription = function(self, newdesc)
		self.info.description = newdesc
	end,
	SetColor = function(self, newclr)
		if not IsColor(newclr) then return end
		self.info.color = newclr
	end,
}

-------------------
/// CLIENT META ///
-------------------
if (CLIENT) then
	AddonMeta.SetThumbnail = function(self, newmat)
		if type(newclr or "") == "IMaterial" then return end
		self.info.thumbnail = newmat
	end
	AddonMeta.GetThumbnail = function(self) return self.info.thumbnail end

	AddonMeta.RegisterSkin = function(self, skin_name, skin_data)
		if not isstring(skin_name) then error("Invalid Skin Name (Name must be a string) - "..tostring(skin_name)) end
		if not istable(skin_data) then error("Invalid Skin Data (Must be a table) - "..tostring(skin_name)) end
		local skin_name = string.lower(skin_name)

		local new_skin_data = table.Copy(skin_base["default"])
		table.Merge(new_skin_data, skin_data)

		--if exist
		if self.data.skins[skin_name] then
			self.data.skins[skin_name] = new_skin_data
			hook.Run(self.info.uid.."_skin_changed",skin_name)
			return
		end

		self.data.skins[skin_name] = new_skin_data
	end
	AddonMeta.SetSkin = function(self, skin_name)
		if not skin_name then return false end
		if not isstring(skin_name) then tostring(skin_name) end
		local skin_name = string.lower(skin_name)

		if self.data.skins[skin_name] then
			self.info.active_skin = skin_name

			hook.Run(self.info.uid.."_skin_changed",skin_name)

			return true
		else
			return false
		end
	end
	AddonMeta.SetDefaultSkin = function(self,skin_name)
		if not skin_name then return false end
		if not isstring(skin_name) then tostring(skin_name) end
		if self.data.skins[skin_name] then
			self.info.default_skin = skin_name
			if not self.info.active_skin then 
				self.info.active_skin = self.info.default_skin 
				self:LoadCustomSkin()
				self:LoadCurrentSkin()
			end
		end
	end
	AddonMeta.GetSkinByName = function(self,skin_name)
		if not skin_name then return false end
		if not isstring(skin_name) then tostring(skin_name) end 
		return self.data.skins[skin_name]
	end
	AddonMeta.GetCurrentSkin = function(self)
		return self.data.skins[self.info.active_skin]
	end
	AddonMeta.GetColors = function(self)
		return self:GetCurrentSkin()["colors"]
	end

	AddonMeta.SaveCurrentSkin = function(self)
		local dir_path = self.prefix..self.info.uid..self["sv_hash"]
		local file_name = dir_path.."/"..self.other_settings_filename
		esclib.file:SaveVar(file_name,{["skin"] = self.info.active_skin})
		end

	AddonMeta.LoadCurrentSkin = function(self)
		local dir_path = self.prefix..self.info.uid..self["sv_hash"]
		local file_name = dir_path.."/"..self.other_settings_filename
		local skin = esclib.file:ReadVar(file_name,"skin")
		if skin then
			self:SetSkin(skin)
		end
	end

	function AddonMeta:SaveCustomSkin()
		local dir_path = self.prefix..self.info.uid..self["sv_hash"]
		local file_name = dir_path.."/"..self.custom_skin_filename
		local custom_skin = self:GetSkinByName("skin_custom")

		if custom_skin then
			esclib.file:SaveVar(file_name,{["skin"] = self:GetSkinByName("skin_custom")})
		else
			custom_skin = table.Copy(self.data.skins[self.info.default_skin])

			esclib.file:SaveVar(file_name,{["skin"] = custom_skin})
			self.data.skins["skin_custom"] = custom_skin
		end
	end

	function AddonMeta:ReturnCustomSkinToDefault()
		local dir_path = self.prefix..self.info.uid..self["sv_hash"]
		local file_name = dir_path.."/"..self.custom_skin_filename

		file.Delete(file_name)
		local custom_skin = table.Copy(self.data.skins[self.info.default_skin])

		-- esclib.file:SaveVar(file_name,{["skin"] = custom_skin})
		self.data.skins["skin_custom"] = custom_skin
		self:SetSkin("skin_custom")
	end

	function AddonMeta:LoadCustomSkin()
		local dir_path = self.prefix..self.info.uid..self["sv_hash"]
		local file_name = dir_path.."/"..self.custom_skin_filename
		local custom_skin = esclib.file:ReadVar(file_name,"skin")
		if custom_skin then
			self.data.skins["skin_custom"] = self.data.skins["skin_custom"] or {}
			table.Merge(self.data.skins["skin_custom"],custom_skin)
		else
			custom_skin = table.Copy(self.data.skins[self.info.default_skin])
			self.data.skins["skin_custom"] = custom_skin
		end
	end

	local function recurse_print_skin(add,tbl)
		if not tbl then 
			tbl = add
			add = ""
		end
		local add = add or ""
		for k,v in pairs(tbl) do
			if istable(v) then
				if ((v["r"]) and (v["g"]) and (v["b"]) and (v["a"])) then --iscolor dont work with tables
					MsgC((string.len(add) < 1) and "skin." or "" )
					MsgC(add..''..k..' = ')
					MsgC(Color(v.r,v.g,v.b,v.a), string.format('Color(%d, %d, %d', v.r,v.g,v.b)..(v.a ~= 255 and (","..v.a) or '')..")" )
					MsgC((string.len(add) < 1) and "" or ",")
				else
					MsgC(add..'["'..k..'"] = {\n')
					recurse_print_skin("\t"..add,v)
					MsgC(add.."}"..((string.len(add) < 1) and "" or "," ))
				end
			else
				MsgC("skin.")
				if type(v) == "string" then
					MsgC(add..''..k..' = "'..v..'"')
				else
					MsgC(add..''..k..' = '..tostring(v).."")
				end
				MsgC((string.len(add) < 1) and "" or "," )
			end
			MsgC("\n")
		end
	end

	function AddonMeta:PrintSkin(skin_name)
		local skin_name = skin_name or ""

		local skin = self.data.skins[skin_name]
		if not skin then return end
		MsgC("local skin = {}\n")
		MsgC("skin")
		recurse_print_skin(skin)

		MsgC('\nesclib.addon:RegisterSkin("'..string.lower(skin.name)..'_new", skin) --Or any other addon\n')
	end

	function AddonMeta:GetAllCustomTabs()
		return self.data["settings_tabs"]
	end

	--Add tab to addon settings
	--func parameters: addon, combo_panel, callback
	function AddonMeta:AddSettingsTab(uid,sort_order,func)
		local func = func or sort_order

		self.data["settings_tabs"][uid] = {
			name = uid,
			func = func,
			sortOrder = sort_order,
		}
	end

	function AddonMeta:RemoveSettingsTab(uid)
		self.data["settings_tabs"][uid] = nil
	end

	function AddonMeta:RequestSettings()
		print("["..self.info.uid.."] - ".."Requesting settings from server")
		net.Start("esclib.RequestConfig")
			net.WriteString(self.info.uid)
		net.SendToServer()
	end

	--RECIEVE CONFIG FROM SERVER
	net.Receive("esclib.SendConfig", function(len)

		local rewrite = false

		local addon_name = net.ReadString()
		local all_addons = esclib:GetAddons()
		if not all_addons[addon_name] then return end
		addon = all_addons[addon_name]

		local bytes = net.ReadUInt(16)
		local c_json = net.ReadData(bytes)

		local c_json = util.Decompress(c_json)
		if isstring(c_json) then 
			print(string.format("[ESCLIB] [%s] Recieved config from server",addon_name or ""))
			c_json = util.JSONToTable(c_json)

			local vars = c_json["vars"]
			local lang = c_json["lang"]
			local skin = c_json["skin"]
			local custom_skin = c_json["cst_skin"]

			--settings
			if vars then
				table.Merge(addon.data.vars,vars)
				addon:SyncVars(-1) --vars -> settings
				table.Merge(addon.data["default_settings"], addon.data["settings"])

				if not rewrite then
					addon:LoadSettings() --load from file (file has more priority)
				end
			end

			--language
			if lang then 
				addon:SetLanguage(lang) 
				addon.info.default_language = addon.info.language
				if not rewrite then
					addon:LoadLanguage()
				end
			end

			--skin
			if skin then 
				if addon:SetSkin(skin) then
					addon.info.default_skin = skin
				end
				if not rewrite then
					addon:LoadCurrentSkin()
				end
			end

			--custom skin
			if custom_skin then
				addon.data.skins["skin_custom"] = addon.data.skins["skin_custom"] or {}
				table.Merge(addon.data.skins["skin_custom"], custom_skin)
				if not rewrite then
					addon:LoadCustomSkin()
				end
			end

			if rewrite then
				self:SaveSettings()
			end

			hook.Run(addon.info.uid.."_settings_changed",true, addon.data.vars)
		end

	end)

	function AddonMeta:CurrentSettingsToGlobal()
		local to_write = {}

		to_write["vars"] = self.data.vars
		to_write["lang"] = self:GetLanguage()
		to_write["skin"] = self.info.active_skin
		to_write["cst_skin"] = self.data.skins["skin_custom"]

		local c_json = util.TableToJSON(to_write)
		c_json = util.Compress( c_json )
		local bytes = #c_json

		net.Start("esclib.SendConfig")
			net.WriteString( self.info.uid )
			net.WriteUInt( bytes, 16 )
			net.WriteData( c_json, bytes )
		net.SendToServer()
	end

	function AddonMeta:ClearGlobalConfig()
		net.Start("esclib.ClearConfig")
			net.WriteString(self.info.uid)
		net.SendToServer()
	end

	function AddonMeta:RequestServerSettings()
		table.Empty(self.data["server_settings"])
		net.Start("esclib.RequestServerConfig")
			net.WriteString(self.info.uid)
		net.SendToServer()
	end

	net.Receive("esclib.SendServerConfig", function(len)
		local addon_name = net.ReadString()
		local addon = esclib:GetAddon(addon_name or "")
		if addon == nil then return end

		local bytes = net.ReadUInt(16)
		local c_json = net.ReadData(bytes)
		c_json = util.Decompress(c_json)

		if not isstring(c_json) then return end

		c_json = util.JSONToTable(c_json)
		if istable(c_json) and not table.IsEmpty(c_json) then
			addon.data["server_settings"] = c_json
		end
	end)

end

---------------------
/// SETTINGS META ///
---------------------
AddonMeta["settings_filename"] = "settings.json"
AddonMeta["custom_skin_filename"] = "custom_skin.json"
AddonMeta["other_settings_filename"] = "other_settings.json"
AddonMeta["prefix"] = CLIENT and "cl_" or "sv_"
AddonMeta["sv_hash"] = esclib:GetServerHash()

-- Direction:
-- >= 0  => settings -> vars
-- < 0 => var -> settings
function AddonMeta:SyncVars(direction)
	local direction = direction or 0

	for tabname,tab_content in pairs(self.data.settings) do
		local vars = tab_content["vars"]
		for varid,var in pairs(vars) do
			if direction >= 0 then
				--vars
				self.data.vars[varid] = var.value
			else
				--settings
				tab_content["vars"][varid]["value"] = self.data.vars[varid]
			end
		end
	end
end

--Save settings to disk
function AddonMeta:SaveSettings()
	local dir_path = self.prefix..self.info.uid..self["sv_hash"]
	local file_name = dir_path.."/"..self.settings_filename
	local json_str = util.TableToJSON(self.data.vars or {})
	if not file.Exists(dir_path, "DATA") then
		file.CreateDir(dir_path)
	end
	if json_str then
		file.Write(file_name, json_str)
	end
end

--Load settings (without languages / skin data)
function AddonMeta:LoadSettings()
	local dir_path = self.prefix..self.info.uid..self["sv_hash"]
	local file_name = dir_path.."/"..self.settings_filename

	local content = file.Read(file_name, "DATA")
	if content then
		local vars = util.JSONToTable(content)

		if istable(vars) and not table.IsEmpty(vars) then

			--changable check
			for name,val in pairs(vars) do
				for tab_name,content in pairs(self.data.settings) do
					local var = self:GetWrappedVar(tab_name,name)
					if not var then continue end

					local result = true
					if var.customCheck then 
						result = var.customCheck(var,self)
					end

					if not result then
						vars[name] = nil
					end
				end
			end

			table.Merge(self.data.vars, vars) --merge vars from file and current with overwrite
			self:SyncVars(-1) --sync vars from vars to wrapped settings(used for settings menu and custom checks)
			hook.Run(self.info.uid.."_settings_changed",true, {})
		end

	end
end

function AddonMeta:LoadAll()
	self:LoadSettings()
	self:LoadLanguage()
	self:LoadCustomSkin()
	self:LoadCurrentSkin()
end

--Init settings and load from file
function AddonMeta:RegisterSettings(settings)
	if self.data["default_settings"] then 
		table.Merge(self.data.default_settings, settings)
		return 
	end

	--On first function launch
	self.data["default_settings"] = table.Copy(settings)
	self.data["settings"] = table.Copy(self.data["default_settings"])

	self:SyncVars(1)

	--attemp to load settings from file
	self:LoadSettings()

end

--Replace current settings and write to file
function AddonMeta:ReplaceSettings(settings,dont_save)
	table.Merge(self.data["settings"], settings)
	self:SyncVars(1)
	if not dont_save then
		self:SaveSettings()
	end
end

--Return settings to default and delete settings from file
function AddonMeta:ReturnSettingsToDefault()

	--Settings
	local dir_path = self.prefix..self.info.uid..self["sv_hash"]
	local file_name = dir_path.."/"..self.settings_filename
	if file.Exists(file_name, "DATA") then --clear from file
		file.Delete(file_name)
	end
	self.data["settings"] = table.Copy(self.data["default_settings"])
	self:SyncVars(1)

	if (CLIENT) then
		--Language
		file_name = dir_path.."/"..self.other_settings_filename
		esclib.file:SaveVar(file_name,{["language"] = nil})
		self:LoadLanguage()

		--Custom_Skin
		self:SetSkin(self.info.default_skin)
		esclib.file:SaveVar(file_name,{["skin"] = nil})

	end

	hook.Run(self.info.uid.."_settings_changed",true, {})

end


----------------------
/// LANGUAGES META ///
----------------------
function AddonMeta:RegisterLanguages(langs)
	if not langs then return end
	if not istable(langs) then return end
	table.Merge(self.data.languages, langs)
end

function AddonMeta:GetLanguage()
	return self.info.language
end

function AddonMeta:GetDefaultLanguage()
	return self.info.default_language
end

function AddonMeta:GetLanguages()
	return self.data.languages
end

function AddonMeta:HasLanguage(lang)
	return self.data.languages[lang] ~= nil
end

function AddonMeta:SaveLanguage()
	local dir_path = self.prefix..self.info.uid..self["sv_hash"]
	local file_name = dir_path.."/"..self.other_settings_filename
	esclib.file:SaveVar(file_name,{["language"] = self.info.language})
end

function AddonMeta:LoadLanguage()
	local dir_path = self.prefix..self.info.uid..self["sv_hash"]
	local file_name = dir_path.."/"..self.other_settings_filename
	local language = esclib.file:ReadVar(file_name, "language")

	if language and string.len(tostring(language)) > 0 then 
		self:SetLanguage(language)
	else
		local game_language = GetConVar("gmod_language"):GetString()
		if self:HasLanguage(game_language) then
			self:SetLanguage(game_language)
		else
			self:SetLanguage(self:GetDefaultLanguage())
		end
	end
end

function AddonMeta:SetLanguage(lang)
	if not lang then return end
	if not isstring(lang) then return end
	lang = string.lower(lang)
	if self:HasLanguage(lang) then
		self.info.language = lang
	else
		return false
	end
	return true
end

function AddonMeta:SetDefaultLanguage(lang, dont_load)
	if self:HasLanguage(lang) then
		self.info.default_language = lang
	end

	if not dont_load then
		self:LoadLanguage()
	end
end


function AddonMeta:Translate(var,lang)
	if not var then return end
	local cLang = lang or (self:GetLanguage() or self:GetDefaultLanguage())
	local languages = self:GetLanguages()

	if languages[cLang] then
		return languages[cLang][var] or ("#"..var)
	else
		return self:Translate(var,self:GetDefaultLanguage()) or ("#"..var)
	end
end

function AddonMeta:CanTranslate(var,lang)
	if not var then return false end
	local lang = lang or (self.info.language or (self.info.default_language or "en"))
	local lv = self:GetLanguages()[lang]

	if lv then
		return lv[var] ~= nil
	else
		return false
	end
end

AddonMeta.__index = AddonMeta

function esclib:Addon(str_addon)
	if not isstring(str_addon) then return end
	local str_addon = string.lower( str_addon )
	-- if exists
	if self.addons[str_addon] then
		if not table.IsEmpty(self.addons[str_addon]) then
			-- self.addons[str_addon] = nil
			return self.addons[str_addon]
		end
	end

	--if not exists
	local addon = {}
	addon.info = {
		["uid"] = str_addon,
		["name"] = str_addon,
		["version"] = "1.0",
		["color"] = Color(255,255,255),
		["description"] = "No description.",
	}
	addon.data = {
		settings = {},
		settings_tabs = {},
		vars = {}, --Similar to settings, but with more convenient access to variables
		languages = {},
	}
	if CLIENT then
		addon.data.skins = {}
		addon.data.server_settings = {}
	end

	setmetatable(addon, AddonMeta)

	self.addons[str_addon] = addon

	if (SERVER) then MsgC(Color(88, 209, 187), "\n["..(addon.info.name or "Error").."]\n") end
	return addon
end