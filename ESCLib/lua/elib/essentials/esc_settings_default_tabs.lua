esclib.default_settings_tabs = esclib.default_settings_tabs or {}

-----------------
/// FUNCTIONS ///
-----------------
--Add tab to all addons settings
--func parameters: addon, background_panel, combo_panel, callback
function esclib:AddDefaultTab(uid,sort_order,func)
	local func = func or sort_order

	self.default_settings_tabs[uid] = {
		name = uid,
		func = func,
		sortOrder = sort_order,
	}
end

function esclib:RemoveDefaultTab(uid)
	self.default_settings_tabs[uid] = nil
end

function esclib:GetAllDefaultTabs()
	return self.default_settings_tabs
end



--------------------
/// LANGUAGE TAB ///
--------------------
esclib:AddDefaultTab("lang_tab",100, function(add, settab, combolist, callback)

	local clr = esclib.addon:GetColors()
	local addon_language = add:GetLanguage()

	local tabname_translated = esclib.addon:Translate("tab_language",add:GetLanguage())
	if not table.IsEmpty(add:GetLanguages()) then
		combolist:AddTab(tabname_translated,function(tab_content)

			local scroll = tab_content:Add("esclib.scrollpanel")
			scroll:SetSize(tab_content:GetWide(),tab_content:GetTall())

			local list = scroll:Add("DIconLayout")
			list:SetSize(tab_content:GetWide(),tab_content:GetTall())
			list:SetBorder(3)
			list:SetSpaceY(3)
			list:SetSpaceX(5)

			local langs = add:GetLanguages()

			local button_wide = list:GetWide()*0.33-list:GetSpaceX()-1
			local button_tall = 50
			local half_tall = button_tall * 0.5

			local icon_w = 24
			local icon_h = 16

			local offset = 0
			for _,lang in ipairs(table.GetKeys(add:GetLanguages())) do
				local lbutton = list:Add("DButton")
				lbutton:SetSize(button_wide,button_tall)
				lbutton:SetText("")
				local lang_name = langs[lang]["__name__"] or esclib.text:Capitalize(lang)
				local lang_code = langs[lang]["__code__"] or ""
				local lang_icon = Material("materials/flags16/"..lang_code..".png")
				local has_mat = not lang_icon:IsError()

				if has_mat then
					offset = icon_w+10
				end
				function lbutton:Paint(w,h)
					local hovered = self:IsHovered()
					draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
					draw.SimpleText( lang_name,"es_esclib_24_500",15+offset,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
					draw.SimpleText( lang_code,"es_esclib_24_500",w-15,h*0.5,clr.button.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

					if has_mat then
						esclib.draw:Material(15,half_tall-icon_h*0.5,icon_w,icon_h,clr.default.white, lang_icon)
					end

					if add.info.language == lang then
						draw.RoundedBox(0,0,h-3,w,3,clr.frame.text)
						return
					end

					if addon_language == lang then
						draw.RoundedBox(0,0,h-3,w,3,clr.default.red)
					end
				end

				function lbutton:DoClick()
					addon_language = lang
					-- if add.info.language ~= addon_language then
					-- 	settings_changed = true
					-- end
					callback("language",addon_language)
				end

			end

			return scroll

		end)
	end

end)


-----------------
/// SKINS TAB ///
-----------------
esclib:AddDefaultTab("skin_tab",101, function(add, settab, combolist, callback)

	local addon_active_skin = add.info.active_skin
	local addon_custom_skin = table.Copy(add:GetSkinByName("skin_custom"))
	local clr = esclib.addon:GetColors()
	local tabname_translated = esclib.addon:Translate("tab_theme",add:GetLanguage())

	local function save_skin()
		add.data.skins["skin_custom"] = table.Copy(addon_custom_skin)
		add:SaveCustomSkin()
		if add.info.active_skin == "skin_custom" then
			hook.Run(add.info.uid.."_skin_changed","skin_custom")
			-- main:Close()
		end
		if IsValid(settab.c_themepanel) then
			settab.c_themepanel:Close()
		end
		-- hook.Run(add.info.uid.."_settings_changed",true,{})
	end

	combolist:AddTab(tabname_translated,function(tab_content)

		local scroll = tab_content:Add("esclib.scrollpanel")
		scroll:SetSize(tab_content:GetWide(),tab_content:GetTall())

		local list = scroll:Add("DIconLayout")
		list:SetSize(tab_content:GetWide(),tab_content:GetTall())
		list:SetBorder(3)
		list:SetSpaceY(3)
		list:SetSpaceX(5)

		for name,skin in pairs(add.data.skins) do
			if name == "skin_custom" then continue end

			local lbutton = list:Add("DButton")
			lbutton:SetSize(list:GetWide()*0.25-list:GetBorder()*2,50)
			lbutton:SetText("")

			local skin_color = skin.color or Color(100,100,100)
			function lbutton:Paint(w,h)
				local hovered = self:IsHovered()
				draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
				draw.SimpleText(skin.name or name,"es_esclib_24_500",50,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

				draw.RoundedBox(8,10,h*0.5-15,30,30,clr.default.black)
				draw.RoundedBox(8,8,h*0.5-17,30,30,skin_color)

				if add.info.active_skin == name then
					draw.RoundedBox(0,0,h-3,w,3,clr.frame.text)
					return
				end

				if addon_active_skin == name then
					draw.RoundedBox(0,0,h-3,w,3,clr.default.red)
				end
			end

			function lbutton:DoClick()
				if addon_active_skin == name then return end
				addon_active_skin = name

				callback("skin",addon_active_skin)

				-- settings_changed = true
			end

			function lbutton:DoRightClick()
				local context = settab:Add("esclib.contextmenu")
				context:SetPosClamped(gui.MouseX()+5,gui.MouseY()+5)

				context:AddHeader(skin.name)

				if add.info.active_skin ~= name then
					context:AddButton(esclib.addon:Translate("phrase_Activate"),function()
						addon_active_skin = name
						callback("skin",addon_active_skin)
						-- save_settings()
					end, esclib.Materials["power.png"])
				end

				context:AddButton(esclib.addon:Translate("button_PrintToConsole"),function()
					add:PrintSkin(name)
				end)
			end
		end

		-----------------------
		/// CUSTOM SKIN TAB ///
		-----------------------
		local lbutton = list:Add("DButton")
		lbutton:SetSize(list:GetWide()*0.25-list:GetBorder()*2,50)
		lbutton:SetText("")
		lbutton:eAddHint(esclib.addon:Translate("hint_CustomSkin"),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

		local custom_name = esclib.addon:Translate("phrase_CustomSkin")
		function lbutton:Paint(w,h)
			local hovered = self:IsHovered()

			draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
			draw.SimpleText(custom_name,"es_esclib_24_500",h*0.35+35,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

			esclib.draw:MaterialCentered(h*0.35+10,h*0.5,h*0.35,clr.button.text,esclib.Materials["cog.png"])

			if add.info.active_skin == "skin_custom" then
				draw.RoundedBox(0,0,h-3,w,3,clr.frame.text)
				return
			end

			if addon_active_skin == "skin_custom" then
				draw.RoundedBox(0,0,h-3,w,3,clr.default.red)
			end
		end

		function lbutton:DoRightClick()
			local mx,my = gui.MouseX(), gui.MouseY()

			local context = settab:Add("esclib.contextmenu")
			context:SetPosClamped(mx+5,my+5)

			context:AddHeader(custom_name)

			if (add.info.active_skin ~= "skin_custom") then
				context:AddButton(esclib.addon:Translate("phrase_Activate"),function()
					addon_active_skin = "skin_custom"
					callback("skin",addon_active_skin)
				end, esclib.Materials["power.png"])
			end

			context:AddButton(esclib.addon:Translate("button_Edit"),function()
				local function GenerateThemeEditPanel(bg,saved)
					if not addon_custom_skin then
						return 
					end

					local skin = esclib.addon:GetCurrentSkin()
					local clr = skin.colors
					local unsaved = saved

					local pnl = bg:Add("esclib.frame")
					pnl:SetSize(bg:GetWide()*0.7,bg:GetTall()*0.9)
					pnl:Center()
					pnl:SetTitle(custom_name)
					pnl:SetIcon(esclib.Materials["cog.png"])
					settab:SetKeyBoardInputEnabled(true)

					function pnl:OnClose()
						callback("custom_skin",self)
					end
					local content = pnl:GetContent()


					local dobar_size = 60
					local dobar = content:Add("DPanel")
					dobar:SetSize(content:GetWide(),dobar_size)
					dobar:SetY(content:GetTall()-dobar:GetTall())

					local phrase_unsaved = esclib.addon:Translate("phrase_Unsaved")
					function dobar:Paint(w,h)
						draw.RoundedBoxEx(skin.roundsize, 0,0,w,h, clr.frame.accent,false,false,true,true)
					end

					local titlepnl = pnl:GetTitlePanel()
					function titlepnl:PaintOver(w,h)
						if unsaved then
							draw.SimpleText(phrase_unsaved.."!", "es_esclib_22_500", w-35, h*0.5, clr.default.red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
						end
					end

					local scroll = content:Add("esclib.scrollpanel")
					scroll:SetSize(content:GetWide(),content:GetTall()-dobar_size)

					local list = scroll:Add("DIconLayout")
					list:SetSize(scroll:GetWide(),scroll:GetTall())
					list:SetBorder(10)
					list:SetSpaceY(5)
					list:SetSpaceX(10)

					local button_sizex = list:GetWide()*0.33-list:GetBorder()*2
					local button_sizey = list:GetTall()*0.07

					for color_tab_name, tab_colors in pairs(addon_custom_skin.colors) do
						if color_tab_name == "default" then continue end

						local color_tab = list:Add("DPanel")
						color_tab:SetSize(list:GetWide()-list:GetBorder()*2,list:GetTall()*0.07)
						local texts = esclib.util.GetTextSize(esclib.text:Capitalize(color_tab_name),"es_esclib_30_500")
						function color_tab:Paint(w,h)
							draw.SimpleText(esclib.text:Capitalize(color_tab_name),"es_esclib_30_500",15,h*0.5,clr.frame.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

							draw.RoundedBox(0, texts.w + 30, h*0.5-2,w-texts.w-45,4,clr.button.hover)
						end

						for color_name, color in pairs(tab_colors) do
							local color_panel = list:Add("esclib.button")
							color_panel:SetSize(button_sizex,button_sizey)
							color_panel:SetBorderRadius(16)
							color_panel:SetButtonText(color_name)

							local clblack = Color(13,13,13)
							local nalpha = color.a < 255
							function color_panel:Paint(w,h)
								local hovered = self:IsHovered()
								draw.RoundedBox(self:GetBorderRadius(),0,0,w,h,hovered and clr.button.hover or clr.button.main)
								draw.SimpleText(color_name, "es_esclib_24_500", 15, h*0.5, hovered and clr.button.text_hover or clr.button.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

								esclib.draw:ShadowText(""..color.r.." "..color.g.." "..color.b..(nalpha and (" "..color.a) or "").."", "es_esclib_16_500", w-60, h*0.5, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER,1)

								if not nalpha then draw.RoundedBox(16,w-43,h*0.5-18,40,40, clblack) end
								draw.RoundedBox(16,w-45,h*0.5-20,40,40, color)
							end

							function color_panel:DoClick()
								local cbg = esclib:GenerateBGClicker(true)
								-- cbg.Paint = nil

								local x,y = self:LocalToScreen(0,0)

								local change_panel = cbg:Add("DPanel")
								change_panel:SetSize(self:GetWide(),175+20)
								change_panel:SetPos(math.Clamp(x, 0, esclib.scrw - change_panel:GetWide()),  math.Clamp(y+self:GetTall()+5, 0, esclib.scrh - change_panel:GetTall()))

								local close_btn = change_panel:Add("esclib.button")
								close_btn:SetSize(20,20)
								close_btn:SetFont("Marlett")
								close_btn:SetButtonText("r")
								close_btn:SetPos(change_panel:GetWide()-close_btn:GetWide()-2,2)
								function close_btn:Paint(w,h)
									local hovered = self:IsHovered()
									draw.SimpleText(self:GetButtonText(),self:GetFont(), w*0.5, h*0.5, hovered and clr.button.discard or clr.frame.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
								end
								function close_btn:DoClick()
									cbg:Close()
								end

								local colorpicker = change_panel:Add("esclib.colorpicker")
								colorpicker:SetPos(10,10)
								colorpicker:SetColor(table.Copy(color))

								local accept_btn = change_panel:Add("esclib.button")
								accept_btn:SetSize(100,25)
								accept_btn:SetFont("es_esclib_16_500")
								accept_btn:SetButtonText(esclib.addon:Translate("phrase_Save"), addon_lang)
								accept_btn:SetPos(change_panel:GetWide()-accept_btn:GetWide()-15,change_panel:GetTall()-accept_btn:GetTall()-26)
								accept_btn:SetZPos(1)
								function accept_btn:Paint(w,h)
									local hovered = self:IsHovered()

									draw.RoundedBox(8,0,0,w,h,hovered and clr.button.apply_hover or clr.button.apply)

									esclib.draw:ShadowText(self:GetButtonText(),self:GetFont(), w*0.5, h*0.5, clr.default.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
								end
								function accept_btn:DoClick()
									unsaved = true
									local newclr = table.Copy(colorpicker:GetColor())
									color = newclr
									addon_custom_skin.colors[color_tab_name][color_name] = newclr

									cbg:Close()
								end

								local matGrid = Material( "gui/alpha_grid.png", "nocull" )
								local clwhite = Color(255,255,255)
								function change_panel:Paint(w,h)
									esclib.draw:Material(0,0,w*0.5,h,clwhite,matGrid)
									esclib.draw:Material(w*0.5,0,w*0.5,h,clwhite,matGrid)
									local clr = colorpicker:GetColor()

									draw.RoundedBox(0,0,0,w,h*0.5,clr)
									local clr_copy = table.Copy(clr)
									clr_copy.a = 255
									draw.RoundedBox(0,0,h*0.5,w,h*0.5+2,clr_copy)
								end

								
							end
						end
					end


					local back_button = dobar:Add("esclib.button")
					back_button:SetSize(dobar:GetTall(),dobar:GetTall())
					back_button:SetX(dobar:GetWide()*0.5-back_button:GetWide()-5)
					back_button:SetButtonText(esclib.addon:Translate("phrase_ReturnDefault"))
					back_button:SetBorderRadius(16)
					back_button:eAddHint(back_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

					function back_button:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.discard_hover or clr.button.discard, esclib.Materials["back.png"])
					end

					function back_button:DoClick()
						esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),esclib.addon:Translate("phrase_SureToReturn"),function(res)
							if res then
								add:ReturnCustomSkinToDefault()
								if add.info.active_skin == "skin_custom" then
									settab:Remove()
								else
									settab.c_themepanel:Close()
								end
							end
						end)
					end

					local apply_button = dobar:Add("esclib.button")
					apply_button:SetSize(dobar:GetTall(),dobar:GetTall())
					apply_button:SetX(dobar:GetWide()*0.5+5)
					apply_button:SetButtonText(esclib.addon:Translate("phrase_Save"))
					apply_button:SetBorderRadius(16)
					apply_button:eAddHint(apply_button:GetButtonText(),"es_esclib_24_500",TEXT_ALIGN_CENTER,settab)

					function apply_button:Paint(w,h)
						local hovered = self:IsHovered()
						esclib.draw:MaterialCentered(w*0.5,h*0.5,h*0.3,hovered and clr.button.apply_hover or clr.button.apply, esclib.Materials["save.png"])
					end

					function apply_button:DoClick()
						unsaved = false
						save_skin()
					end

					local copy_button = dobar:Add("esclib.button")
					copy_button:SetSize(dobar:GetWide()*0.27,dobar:GetTall()*0.7)
					copy_button:SetPos(dobar:GetWide() - copy_button:GetWide() - 15, dobar:GetTall()*0.5 - copy_button:GetTall()*0.5)
					copy_button:SetBorderRadius(16)
					copy_button:SetFont("es_esclib_20_500")
					copy_button:SetButtonText(esclib.addon:Translate("button_LoadOtherSkin"))

					function copy_button:DoClick()
						local cbg = esclib:GenerateBGClicker()

						local pnl = cbg:Add("esclib.frame")
						pnl:SetSize(esclib.scrw*0.5,esclib.scrh*0.5)
						pnl:Center()
						pnl:SetTitle(esclib.addon:Translate("button_LoadOtherSkin"))
						local content = pnl:GetContent()

						local scroll = content:Add("esclib.scrollpanel")
						scroll:SetSize(content:GetWide(),content:GetTall())

						local list = scroll:Add("DIconLayout")
						list:SetSize(scroll:GetWide(),scroll:GetTall())
						list:SetBorder(10)
						list:SetSpaceY(5)
						list:SetSpaceX(10)

						for name,skin in pairs(add.data.skins) do
							if (name == "skin_custom") then continue end

							local btn = list:Add("esclib.button")
							btn:SetSize(list:GetWide()*0.5-list:GetBorder()*2,50)
							function btn:Paint(w,h)
								local hovered = self:IsHovered()
								draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
								draw.SimpleText(skin.name or name,"es_esclib_20_500",50,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

								draw.RoundedBox(8,10,h*0.5-15,30,30,skin.color or clr.default.white)
							end
							function btn:DoClick()
								addon_custom_skin = table.Copy(skin)

								unsaved = true
								cbg:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
									cbg:Remove()
									if IsValid(settab.c_themepanel) then settab.c_themepanel:Remove() end
									settab.c_themepanel = GenerateThemeEditPanel(settab,true)
									function settab.c_themepanel:OnClose(pnl,unsaved)
										settab:SetKeyBoardInputEnabled(false)
										callback("custom_skin",settab.c_themepanel)
										-- settings_on_close_any(self)
									end
								end)
							end
						end
					end

					local print_button = dobar:Add("esclib.button")
					print_button:SetSize(dobar:GetWide()*0.27,dobar:GetTall()*0.7)
					print_button:SetPos(15, dobar:GetTall()*0.5 - print_button:GetTall()*0.5)
					print_button:SetBorderRadius(16)
					print_button:SetFont("es_esclib_20_500")
					print_button:SetButtonText(esclib.addon:Translate("button_PrintToConsole"))

					function print_button:DoClick()
						add:PrintSkin("skin_custom")
					end

					return pnl
				end

				addon_custom_skin = table.Copy(add:GetSkinByName("skin_custom"))
				settab.c_themepanel = GenerateThemeEditPanel(settab)
				local c_themepanel = settab.c_themepanel

				-- callback("custom_skin",settab.c_themepanel)

				function c_themepanel:OnClose(pnl)
					settab:SetKeyBoardInputEnabled(false)
					callback("custom_skin",settab.c_themepanel)
					-- settings_on_close_any(self)
				end

				if IsValid(settab.c_themepanel) and IsValid(settab.c_addonpnl) then
					settab.c_addonpnl:SetAlpha(255)
					settab.c_addonpnl:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
						if IsValid(settab.c_addonpnl) then settab.c_addonpnl:Hide() end
					end)
				end
			end, esclib.Materials["wrench.png"])

			context:AddButton(esclib.addon:Translate("phrase_ReturnDefault"),function()
				esclib:ConfirmWindow(esclib.addon:Translate("phrase_AreYouSure"),esclib.addon:Translate("phrase_SureToReturn"),function(res)
					if res then
						add:ReturnCustomSkinToDefault()
						if add.info.active_skin == "skin_custom" then
							settab:Remove()
						end
					end
				end)
			end)

			context:AddButton(esclib.addon:Translate("button_PrintToConsole"),function()
				add:PrintSkin("skin_custom")
			end)

		end

		function lbutton:DoClick()
			if addon_active_skin == "skin_custom" then 
				self:DoRightClick()
				return 
			end
			addon_active_skin = "skin_custom"

			callback("skin",addon_active_skin)
		end

		return scroll

	end)
end)