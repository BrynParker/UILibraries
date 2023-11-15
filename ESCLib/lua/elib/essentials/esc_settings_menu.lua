esclib:SetFontName("esclib")
esclib:Font(24,500) --es_esclib_24_500


-------------
/// PANEL ///
-------------
local settab = settab or nil
function esclib:opensettings(naddon)
	if IsValid(settab) then
		settab:Remove()
		return
	end

	local skin = esclib.addon:GetCurrentSkin()
	local clr = skin.colors
	local scrw, scrh = esclib.scrw, esclib.scrh
	local addons = esclib:GetAddons() or {}
	local addoncount = 0

	local c_addonpnl = nil
	local c_themepanel = nil

	for k,v in pairs(addons) do
		addoncount = addoncount + 1
	end

	local needaddon
	local needrestart = false

	if naddon then
		if not isstring(naddon) then
			naddon = tostring(naddon)
		end
		naddon = string.lower(naddon)
		
		if esclib:GetAddons()[naddon] then
			needaddon = true
		end
	end

	settab = vgui.Create("EditablePanel")
	settab:SetAlpha(0)
	settab:AlphaTo(255,esclib.addon:GetVar("animtime"))
	settab:SetSize(scrw,scrh)
	settab:SetText("")
	settab:MakePopup()
	settab:SetKeyBoardInputEnabled(false)
	local draw_blur = esclib.addon:GetVar("drawblur")

	local version = string.format("%s v%s", esclib.addon:GetBranch() or "", esclib.addon:GetVersion() or "")
	local hash = esclib:GetServerHash()
	function settab:Paint(w,h)
		if draw_blur then
			esclib.util:DrawBlur(self,6)
		end

		draw.RoundedBox(0, 0, 0, w, h, clr.background.col)

		draw.SimpleText(esclib.addon:GetName(), "es_esclib_20_500", w-15, h-65, clr.frame.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(version, "es_esclib_20_500", w-15, h-40, clr.frame.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("SVUID "..hash, "es_esclib_20_500", w-15, h-15, clr.frame.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)


	end

	local setbutton = settab:Add("DButton")
	setbutton:SetSize(scrw,scrh)
	setbutton:SetText("")
	setbutton.Paint = nil

	if esclib.addon:GetVar("debug") then

		local offset = 5

		local text = "DEBUG MODE ACTIVE"
		local font = "es_esclib_24_500"
		local textw, texth = esclib.util:TextSize(text, font)
		local dbg_btn = setbutton:Add("esclib.button")
		dbg_btn:SetSize(textw+20, texth+5)
		dbg_btn:SetPos(offset, 5)
		dbg_btn:SetButtonText(text)
		dbg_btn:SetFont(font)
		dbg_btn:SetMouseInputEnabled(false)
		offset = offset + textw+25


		local text = "Fonts"
		font = "es_esclib_24_500"
		textw, texth = esclib.util:TextSize(text, font)

		dbg_btn = setbutton:Add("esclib.button")
		dbg_btn:SetSize(textw+20, texth+5)
		dbg_btn:SetPos(offset, 5)
		dbg_btn:SetButtonText(text)
		dbg_btn:SetFont(font)
		function dbg_btn:DoClick()
			local fonts = table.GetKeys(esclib.fonts.list)
			local count = #fonts
			if count < 1 then return end
			table.sort(fonts, function(a, b) return a:upper() < b:upper() end)

			local pnl = esclib:GeneratePopWindow(false)
			pnl:SetSize(esclib.scrw*0.5,esclib.scrh*0.8)
			pnl:Center()

			pnl:SetTitle(text.." ("..count..")")
			local content = pnl:GetContent()
			content:InvalidateParent()
			local scroll = content:Add("esclib.scrollpanel")
			scroll:SetSize(content:GetWide(),content:GetTall())


			local list = scroll:Add("DIconLayout")
			list:SetY(5)
			list:SetSize(content:GetWide(),content:GetTall()-10)
			list:SetSpaceY(5)
			list:SetBorder(20)

			for id,font in pairs(fonts) do
				local text = font
				local textw,texth = esclib.util:TextSize(text,font)

				local font_pnl = list:Add("DPanel")
				function font_pnl:Paint(w,h)
					draw.RoundedBox(0,0,0,w,h,clr.frame.accent)
					draw.SimpleText(id,"es_esclib_20_500", 5, h*0.5, clr.frame.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local textw2,texth2 = esclib.util:TextSize(id,"es_esclib_20_500")
				font_pnl:SetSize(list:GetWide()-list:GetBorder()*2, math.max(texth+6,texth2+6))

				local font_lbl = font_pnl:Add("DLabel")
				font_lbl:SetSize(font_pnl:GetWide()-(textw2+15)*2, font_pnl:GetTall())
				font_lbl:SetX(textw2+15)
				font_lbl:SetText(text)
				font_lbl:SetFont(font)
				font_lbl:SetColor(clr.frame.text)
			end

		end
		offset = offset + textw+25

	end

	local main = vgui.Create("esclib.frame", settab)
	if needaddon then main:Hide() end
	main:SetSize(scrw*0.6,scrh*0.8)
	main:Center()
	main:SetIcon(esclib.Materials["cog.png"])
	main:SetTitle(esclib.addon:Translate("tab_settings"))
	function main:OnClose(callback)
		if IsValid(settab.c_themepanel) then settab.c_themepanel:Remove() end

		if IsValid(settab.c_addonpnl) then settab.c_addonpnl:Remove() end

		settab:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
			if callback then callback() end
			if IsValid(settab) then
				settab:Remove()
				return
			end
			if IsValid(main) then
				main:Remove()
			end
		end)
		gui.EnableScreenClicker(false)
	end

	local function settings_on_close_any(pnl)
		if IsValid(settab.c_themepanel) then
			if pnl ~= settab.c_themepanel then
				if settab.c_themepanel.OnClose then settab.c_themepanel:OnClose(self) end
			end
			settab.c_themepanel:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
				if IsValid(settab.c_themepanel) then settab.c_themepanel:Remove() end
			end)

			if IsValid(c_addonpnl) then
				c_addonpnl:Show()
				c_addonpnl:SetAlpha(0)
				c_addonpnl:AlphaTo(255,esclib.addon:GetVar("animtime"))
			end
			return true
		end

		if IsValid(c_addonpnl) then
			if needaddon then
				main:Close()
				return
			end

			c_addonpnl:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
				c_addonpnl:Remove()
			end)
		end

		if not main:IsVisible() then
			main:Show()
			main:SetAlpha(0)
			main:AlphaTo(255,esclib.addon:GetVar("animtime"))
		else
			main:Close()
		end

		return true
	end

	function setbutton:DoClick()
		if settings_on_close_any() then return end

		main:Close()
	end

	local content = main:GetContent()
	-- main.PaintBG = function() end

	local scroll = content:Add("esclib.scrollpanel")
	scroll:SetSize(content:GetWide(),content:GetTall())

	local list = scroll:Add("DIconLayout")
	list:SetSize(content:GetWide(),content:GetTall())
	list:SetSpaceY(5)
	list:SetSpaceX(10)
	list:SetBorder(10)

	for uid,add in pairs(addons) do

		------------------
		/// ALL ADDONS ///
		------------------
		local addpan = list:Add("DButton")
		addpan:SetSize(150,190)
		addpan:SetText("")

		local drawicon = false
		if type((add.info.thumbnail or "")) == "IMaterial" then
			drawicon = true
		end

		local name_cut = esclib.util:TextCutAccurate(add.info.name, "es_esclib_20_500", addpan:GetWide()-20, "...")
		local edit_cut = esclib.util:TextCutAccurate(esclib.addon:Translate("button_Edit"), "es_esclib_20_500", addpan:GetWide()-20, "...")

		local version = string.format("%s v%s", add:GetBranch() or "", add:GetVersion() or "")
		local version_wide, version_height = esclib.util:TextSize(version, "es_esclib_16_500")

		local hover_color = Color(255,255,255,2)
		local gradient = Material("gui/gradient","smooth")
		function addpan:Paint(w,h)

			local hovered = self:IsHovered()
			local bgclr = hovered and clr.button.hover or clr.button.main

			draw.RoundedBox(0, 0, 0, w, h, bgclr)

			-- draw.RoundedBox(0,0,h-3,w,3,add.info.color)

			if drawicon then
				esclib.draw:Material(0,0,w,w,clr.default.white , add.info.thumbnail)
			else
				draw.RoundedBox(0,0,0, w, w, clr.frame.text)
			end

			--version
			esclib.draw:ShadowText(version, "es_esclib_16_500", w-version_wide-15, 10, clr.default.white)

			--hover effect
			if hovered then
				draw.RoundedBox(0,0,0, w, w, hover_color)

				-- draw.RoundedBox(0,10,w+10, w-20, h-w-20, clr.frame.bg)
				draw.SimpleText(edit_cut, "es_esclib_20_500", w*0.5, w+(h-w)*0.5, clr.frame.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(name_cut, "es_esclib_20_500", 10, w+(h-w)*0.5, clr.frame.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end

		end

		-------------------
		/// EDIT ADDONS ///
		-------------------
		local function open_addon_edit()
			main:SetAlpha(255)
			main:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
				if IsValid(main) then main:Hide() end
			end)

			local addon_settings_copy = table.Copy(add.data.settings) or {}
			local addon_vars_copy = table.Copy(add.data.vars)
			local addon_language = add:GetLanguage()
			local addon_active_skin = add.info.active_skin
			local addon_custom_skin = table.Copy(add:GetSkinByName("skin_custom"))
			local addon_lang = add:GetLanguage() --dont changes

			if esclib:HasAdminAccess(LocalPlayer()) then
				add:RequestServerSettings()
			end

			local changed_vars = {}

			if IsValid(c_addonpnl) then c_addonpnl:Remove() end

			c_addonpnl = vgui.Create("esclib.frame",settab)
			settab.c_addonpnl = c_addonpnl
			c_addonpnl:SetAlpha(0)
			c_addonpnl:AlphaTo(255,esclib.addon:GetVar("animtime"))
			c_addonpnl:SetSize(scrw*0.7,scrh*0.9)
			c_addonpnl:Center()
			c_addonpnl:SetIcon(esclib.Materials["cog.png"])
			function c_addonpnl:OnClose()
				settings_on_close_any(self)
			end

			c_addonpnl:SetTitle(add.info.name.." - "..esclib.addon:Translate("tab_settings", addon_lang))
			local c_content = c_addonpnl:GetContent()

			local realm = c_content:Add("esclib.combolist")
			realm:SetSize(c_content:GetWide(),c_content:GetTall())
			realm:SetAccentColor(Color(125,125,255))

			--------------------
			/// CLIENT REALM ///
			--------------------
			realm:AddTab(esclib.addon:Translate("realm_Client",add:GetLanguage()), function(content)
				if not IsValid(content) then return end
				local dobar_size = 60

				local combolist = content:Add("esclib.combolist")
				combolist:SetSize(content:GetWide(),content:GetTall())

				local dobar = content:Add("DPanel")
				dobar:SetSize(content:GetWide(),dobar_size)
				local to_y = content:GetTall()-dobar:GetTall()
				dobar:SetY(content:GetTall())
				dobar:MoveTo(dobar:GetX(), to_y, 0.2)

				local settings_changed = false 

				local function check_saved(varid,val)
					if changed_vars[varid] ~= nil then
						if add.data.vars[varid] == val then
							changed_vars[varid] = nil
						end
					else
						changed_vars[varid] = val
					end

					if not table.IsEmpty(changed_vars) then
						settings_changed = true
					else
						settings_changed = false
					end
				end

				local function save_settings()
					if add.info.active_skin ~= addon_active_skin then
						settab:Remove()

						add:SetSkin(addon_active_skin)
						add:SaveCurrentSkin()
					end

					add:SetLanguage(addon_language)
					add:SaveLanguage()

					add:ReplaceSettings(addon_settings_copy) --Save automatically

					hook.Run(add.info.uid.."_settings_changed",true, changed_vars)

					-- if needrestart then
					-- 	settab:Remove()
					-- end

					table.Empty(changed_vars)
					settings_changed = false
				end

				local tabs_list = {}
				local settings_keys = table.GetKeys(addon_settings_copy)

				for k,v in ipairs(settings_keys) do
					local c_order = addon_settings_copy[v]["sortOrder"]
					table.insert(tabs_list,{ stype="settings", key=v, sortOrder=c_order })
				end

				for key,tab in pairs(add:GetAllCustomTabs()) do
					if not istable(tab) then continue end
					local c_order = tab["sortOrder"]
					table.insert(tabs_list,{ stype="custom", key=key, sortOrder=c_order })
				end

				for key,tab in pairs(esclib:GetAllDefaultTabs()) do
					local c_order = tab["sortOrder"]
					table.insert(tabs_list,{ stype="default", key=key, sortOrder=c_order })
				end

				--Sort by sortOrder key
				--SortOrder: 100 - language tab, 101 - theme tab
				table.sort(tabs_list,function(a,b)
					return ( (a.sortOrder or 99) < (b.sortOrder or 99) )
				end)

				for _,data in ipairs(tabs_list) do

					if data["stype"] == "settings" then
						local tabname = data["key"]
						local tabc = addon_settings_copy[tabname]

						if not istable(tabc) then continue end

						if tabc.customCheck then
							if isfunction(tabc.customCheck) then 
								if not tabc.customCheck(tabc,add) then continue end
							end
						end

						local vars = tabc["vars"]
						local tabname_translated = add:Translate(tabc.name_tr) or tabc.name

						combolist:AddTab( tabname_translated, function(tab_content)
							
							local scroll = tab_content:Add("esclib.scrollpanel")
							scroll:SetSize(tab_content:GetWide(),tab_content:GetTall())

							local list = scroll:Add("DIconLayout")
							list:SetBorder(5)
							list:SetSize(tab_content:GetWide(),tab_content:GetTall()-6)
							list:SetSpaceX(5)
							list:SetSpaceY(5)


							local button_wide = list:GetWide()*0.33-list:GetSpaceX()-1
							local button_tall = 50

							local sortedVars = table.GetKeys(vars)
							table.sort(sortedVars,function(a,b)
								return ( (vars[a]["sortOrder"] or math.huge) < (vars[b]["sortOrder"] or math.huge) )
							end)

							for _,varid in ipairs(sortedVars) do

								local varc = vars[varid]

								if varc.visible == false then continue end

								if varc.customCheck then
									if isfunction(varc.customCheck) then 
										if not varc.customCheck(varc,add) then continue end
									end
								end

								if (varc.name == nil and varc.name_tr == nil) then varc.name = varid end

								local vtype  = varc.type
								if esclib.allowed_settings_types[vtype] then
									local function callback(varid, var)
										if varc["restart_addon"] then needrestart = true end
										check_saved(varid,var)
									end

									local settings_type = esclib.allowed_settings_types[vtype]
									if isfunction(settings_type["draw_func"]) then
										settings_type["draw_func"](
											list,
											add,
											varid,
											varc,
											callback, 
											{["button_wide"] = button_wide,["button_tall"] = button_tall,["vars_copy"] = addon_vars_copy,["bg"] = settab}
										)
									end
								end

							end

							return scroll

						end)
					elseif data["stype"] == "custom" then
						local function callback(changed)
							settings_changed = changed
						end

						local name = data["key"]
						local cstm = add:GetAllCustomTabs()[name]

						cstm.func(add, settab, combolist, callback)

					elseif data["stype"] == "default" then
						local function callback(stype, ...)
							local vars = {...}
							if stype == "language" then
								addon_language = vars[1]
								if add.info.language ~= addon_language then
									settings_changed = true
								end
							elseif stype == "skin" then
								addon_active_skin = vars[1]
								if add.info.active_skin ~= addon_active_skin then
									settings_changed = true
								end
							elseif stype == "custom_skin" then
								settab.c_themepanel = vars[1]
								settings_on_close_any(settab.c_themepanel)
							end

							if settings_changed then
								needrestart = true
							end
						end

						local name = data["key"]
						local cstm = esclib:GetAllDefaultTabs()[name]

						cstm.func(add, settab, combolist, callback)
					end
				end


				local phrase_unsaved = esclib.addon:Translate("phrase_Unsaved")
				function dobar:Paint(w,h)
					draw.RoundedBoxEx(skin.roundsize, 0,0,w,h, clr.frame.accent,false,false,true,true)

					if settings_changed then
						draw.SimpleText(phrase_unsaved.."!", "es_esclib_22_500", w-15, h*0.5, clr.default.red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					end
				end

				local clearcfg_button = dobar:Add("esclib.button")
				clearcfg_button:SetSize(dobar:GetTall(),dobar:GetTall())
				clearcfg_button:SetX(dobar:GetWide()*0.5-clearcfg_button:GetWide()-5)
				clearcfg_button:SetY(dobar:GetTall()*0.5-clearcfg_button:GetTall()*0.5)

				clearcfg_button:SetButtonText(esclib.addon:Translate("phrase_ReturnDefault"))
				clearcfg_button:SetBorderRadius(16)

				function clearcfg_button:Paint(w,h)
					local hovered = self:IsHovered()
					esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.discard_hover or clr.button.discard, esclib.Materials["back.png"])
				end
				clearcfg_button:eAddHint(clearcfg_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

				function clearcfg_button:DoClick()
					esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),esclib.addon:Translate("phrase_SureToReturn"),function(res)
						if res then
							add:ReturnSettingsToDefault()
							addpan:DoClick()
						end
					end)
				end

				if esclib:HasAdminAccess(LocalPlayer()) then
					local send2server = dobar:Add("esclib.button")
					send2server:SetSize(dobar:GetTall(),dobar:GetTall())
					send2server:SetX(5)
					
					send2server:SetButtonText(esclib.addon:Translate("phrase_SetGlobalDefault"))
					send2server:SetBorderRadius(16)

					function send2server:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.text_hover or clr.button.text, esclib.Materials["cloud.png"])
					end
					send2server:eAddHint(send2server:GetButtonText(),"es_esclib_20_500",TEXT_ALIGN_CENTER,settab)

					function send2server:DoClick()
						esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),"",function(res)
							if res then
								add:CurrentSettingsToGlobal()
								addpan:DoClick()
							end
						end)
					end


					local req2cleancfg = dobar:Add("esclib.button")
					req2cleancfg:SetSize(dobar:GetTall(),dobar:GetTall())
					req2cleancfg:SetX(send2server:GetX()+send2server:GetWide()+5)
					
					req2cleancfg:SetButtonText(esclib.addon:Translate("phrase_BackGlobalDefault"))
					req2cleancfg:SetBorderRadius(16)

					function req2cleancfg:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.32,hovered and clr.button.text_hover or clr.button.text, esclib.Materials["back.png"])
					end
					req2cleancfg:eAddHint(req2cleancfg:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

					function req2cleancfg:DoClick()
						esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),esclib.addon:Translate("phrase_SureToReturn"),function(res)
							if res then
								add:ClearGlobalConfig()
								addpan:DoClick()
							end
						end)
					end

					local infobtn = dobar:Add("esclib.button")
					infobtn:SetSize(dobar:GetTall(),dobar:GetTall())
					infobtn:SetX(req2cleancfg:GetX()+req2cleancfg:GetWide()+5)
					
					infobtn:SetButtonText(esclib.addon:Translate("phrase_AdminInfoButtons"))
					infobtn:SetBorderRadius(16)

					function infobtn:Paint(w,h)
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.25,clr.default.orange, esclib.Materials["info.png"])
					end
					infobtn:eAddHint(infobtn:GetButtonText(),"es_esclib_20_500",TEXT_ALIGN_CENTER,settab)
				end

				local apply_button = dobar:Add("esclib.button")
				apply_button:SetSize(dobar:GetTall(),dobar:GetTall())
				apply_button:SetX(dobar:GetWide()*0.5+5)
				apply_button:SetY(dobar:GetTall()*0.5-apply_button:GetTall()*0.5)

				apply_button:SetButtonText(esclib.addon:Translate("phrase_Save"))
				apply_button:SetBorderRadius(16)

				function apply_button:Paint(w,h)
					local hovered = self:IsHovered()
					esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.apply_hover or clr.button.apply, esclib.Materials["save.png"])
				end
				apply_button:eAddHint(apply_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

				function apply_button:DoClick()
					save_settings()
					addpan:DoClick()
				end

				return combolist

			end)-- end of client realm
			
			
			--------------
			/// SERVER ///
			--------------
			realm:AddTab(esclib.addon:Translate("realm_Server",add:GetLanguage()), function(content)
				if not IsValid(content) then return end

				if table.IsEmpty(add.data["server_settings"]) or not esclib:HasAdminAccess(LocalPlayer()) then
					local text = "Unknown error"
					if not esclib:HasAdminAccess(LocalPlayer()) then
						text = esclib.addon:Translate("phrase_NoAccess", add:GetLanguage())
					else
						text = esclib.addon:Translate("phrase_EmptySettings", add:GetLanguage())
					end

					function content:Paint(w,h)
						draw.SimpleText(text, "es_esclib_24_500", w*0.5,h*0.5, clr.frame.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					local changed_vars = {}
					local settings_changed = false 
					local dobar_size = 60


					--var manipulation
					local addon_settings_copy = table.Copy(add.data["server_settings"])
					local addon_vars_copy = {}

					for tabname,tab_content in pairs(addon_settings_copy) do
						local vars = tab_content["vars"]
						if not istable(vars) then continue end
						for varid,var in pairs(vars) do
							addon_vars_copy[varid] = var.value
						end
					end

					local tabs_list = {}

					for _, key in ipairs(table.GetKeys(addon_settings_copy)) do
						local c_order = addon_settings_copy[key]["sortOrder"]
						table.insert(tabs_list, {stype = "settings", key=key, sortOrder=c_order})
					end

					table.sort(tabs_list,function(a,b)
						return ( (a.sortOrder or 99) < (b.sortOrder or 99) )
					end)


					--useful functions
					local function check_saved(varid,val)
						if changed_vars[varid] ~= nil then
							if addon_vars_copy[varid] == val then
								changed_vars[varid] = nil
							end
						else
							changed_vars[varid] = val
						end

						if not table.IsEmpty(changed_vars) then
							settings_changed = true
						else
							settings_changed = false
						end
					end

					--Creating vgui
					local combolist = content:Add("esclib.combolist")
					combolist:SetSize(content:GetWide(),content:GetTall())

					local dobar = content:Add("DPanel")
					dobar:SetSize(content:GetWide(),dobar_size)
					local to_y = content:GetTall()-dobar:GetTall()
					dobar:SetY(content:GetTall())
					dobar:MoveTo(dobar:GetX(), to_y, 0.2)


					--filling
					for _, tab_data in ipairs(tabs_list) do
						local stype = tab_data.stype
						local key = tab_data.key
						
						if stype == "settings" then
							local tabname = tab_data["key"]
							local tabc = addon_settings_copy[tabname]

							if not istable(tabc) then continue end

							local vars = tabc["vars"]
							local tabname_translated = add:Translate(tabc.name_tr) or tabc.name

							combolist:AddTab( tabname_translated, function(tab_content)
							
								local scroll = tab_content:Add("esclib.scrollpanel")
								scroll:SetSize(tab_content:GetWide(),tab_content:GetTall())

								local list = scroll:Add("DIconLayout")
								list:SetBorder(3)
								list:SetSize(tab_content:GetWide(),tab_content:GetTall()-6)
								list:SetSpaceX(5)
								list:SetSpaceY(5)


								local button_wide = list:GetWide()*0.33-list:GetSpaceX()-1
								local button_tall = 50

								local sortedVars = table.GetKeys(vars)
								table.sort(sortedVars,function(a,b)
									return ( (vars[a]["sortOrder"] or math.huge) < (vars[b]["sortOrder"] or math.huge) )
								end)

								for _,varid in ipairs(sortedVars) do

									local varc = vars[varid]

									if varc.visible == false then continue end

									if varc.customCheck then
										if isfunction(varc.customCheck) then 
											if not varc.customCheck(varc,add) then continue end
										end
									end

									if (varc.name == nil and varc.name_tr == nil) then varc.name = varid end

									local vtype  = varc.type
									if esclib.allowed_settings_types[vtype] then
										local function callback(varid, var)
											check_saved(varid,var)
										end

										local settings_type = esclib.allowed_settings_types[vtype]
										if isfunction(settings_type["draw_func"]) then
											settings_type["draw_func"](
												list,
												add,
												varid,
												varc,
												callback, 
												{["button_wide"] = button_wide,["button_tall"] = button_tall,["vars_copy"] = addon_vars_copy,["bg"] = settab}
											)
										end
									end

								end

								return scroll

							end)

							local phrase_unsaved = esclib.addon:Translate("phrase_Unsaved")
							function dobar:Paint(w,h)
								draw.RoundedBoxEx(skin.roundsize, 0,0,w,h, clr.frame.accent,false,false,true,true)

								if settings_changed then
									draw.SimpleText(phrase_unsaved.."!", "es_esclib_22_500", w-15, h*0.5, clr.default.red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
								end
							end

							--Clear
							local clearcfg_button = dobar:Add("esclib.button")
							clearcfg_button:SetSize(dobar:GetTall(),dobar:GetTall())
							clearcfg_button:SetX(dobar:GetWide()*0.5-clearcfg_button:GetWide()-5)
							clearcfg_button:SetY(dobar:GetTall()*0.5-clearcfg_button:GetTall()*0.5)

							clearcfg_button:SetButtonText(esclib.addon:Translate("phrase_ReturnDefault"))
							clearcfg_button:SetBorderRadius(16)

							function clearcfg_button:Paint(w,h)
								local hovered = self:IsHovered()
								esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.discard_hover or clr.button.discard, esclib.Materials["back.png"])
							end
							clearcfg_button:eAddHint(clearcfg_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

							function clearcfg_button:DoClick()
								esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),esclib.addon:Translate("phrase_SureToReturn"),function(res)
									if res then
										net.Start("esclib.ClearServerConfig")
											net.WriteString(add.info.uid)
										net.SendToServer()
										addpan:DoClick()
									end
								end)
							end

							--Save
							local apply_button = dobar:Add("esclib.button")
							apply_button:SetSize(dobar:GetTall(),dobar:GetTall())
							apply_button:SetX(dobar:GetWide()*0.5+5)
							apply_button:SetY(dobar:GetTall()*0.5-apply_button:GetTall()*0.5)

							apply_button:SetButtonText(esclib.addon:Translate("phrase_Save"))
							apply_button:SetBorderRadius(16)

							function apply_button:Paint(w,h)
								local hovered = self:IsHovered()
								esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.apply_hover or clr.button.apply, esclib.Materials["save.png"])
							end
							apply_button:eAddHint(apply_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

							function apply_button:DoClick()
								if table.IsEmpty(changed_vars) then return end
									
								net.Start("esclib.SendServerConfig")
									net.WriteString(add.info.uid)
									esclib:NetWriteCompressedTable(changed_vars)
								net.SendToServer()

								addpan:DoClick()
							end

						end
					end

				end
			end)-- end of Server realm


		end

		if needaddon then
			if uid == naddon then
				open_addon_edit()
			end
		end

		function addpan:DoClick()
			open_addon_edit()
		end
	end
end

concommand.Add("esettings",function(ply,cmd,args)
	if not table.IsEmpty(args) then

	end

	esclib:opensettings(args[1])
end)

hook.Add("OnPlayerChat","esclib.hook.open_settings",function(ply,text,isteam,isplydead)
	if ply ~= LocalPlayer() then return end
	if text == "!esettings" then
		RunConsoleCommand("esettings")
		return true
	end
end)