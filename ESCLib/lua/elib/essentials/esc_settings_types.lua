esclib.allowed_settings_types = esclib.allowed_settings_types or {}

function esclib:AddNewSettingsType(name, important_vars, secondary_vars, draw_func)
	self.allowed_settings_types[name] = {}
	self.allowed_settings_types[name]["important_vars"] = important_vars or {}
	self.allowed_settings_types[name]["secondary_vars"] = secondary_vars or {}
	if (CLIENT) then self.allowed_settings_types[name]["draw_func"] = draw_func end
end

------------
/// BOOL ///
------------
local name = "bool"
local required_params = {"value"}
local secondary_params = {}
local draw_func = function( panel, addon, varid, varc, callback, other ) --not used on serverside

	--other: button_wide / button_tall / current_vars_copy
	local button_wide= other["button_wide"]
	local button_tall = other["button_tall"]
	local vars_copy = other["vars_copy"]
	local settab = other["bg"]

	local clr = esclib.addon:GetColors()

	local name_tr  = varc.name or addon:Translate(varc.name_tr)
	local desc = varc.desc or addon:Translate(varc.desc_tr)
	if (varc.change_type == "usergroup") or (varc.change_type == "steamid") then
		if varc.who_can_change and istable(varc.who_can_change) then
			if not desc then desc = "" end
			desc = desc.." "..esclib.addon:Translate("phrase_WhoCanChange")..": [ "
			for k,v in pairs(varc.who_can_change) do
				desc = desc..tostring(k).." "
			end
			desc = desc.." ]"
		end
	end

	if (varc.change_type == "boolean") then
		if not varc.who_can_change then
			if not desc then desc = "" end
			desc = desc.." "..esclib.addon:Translate("phrase_WhoCanChange")..": [ "..esclib.addon:Translate("phrase_NoOne").." ]"
		end
	end

	local name = esclib.util:TextCutAccurate(name_tr, "es_esclib_24_500", button_wide-15-90, "...")

	local button = panel:Add("DButton")
	button:SetSize(button_wide, button_tall)
	button:SetText("")
	if desc then
		button:eAddHint(desc,"es_esclib_20_500",TEXT_ALIGN_TOP,settab)
	end

	function button:DoClick()
		varc.value = not varc.value
		callback(varid,varc.value)
	end
	function button:Paint(w,h)
		local hovered = self:IsHovered()

		draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)

		draw.SimpleText(name,"es_esclib_24_500",15,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		local checkbox_size = h*0.25
		esclib.draw:MaterialCentered(w-checkbox_size-15, h*0.5, checkbox_size,  hovered and clr.button.main or clr.button.hover , esclib.Materials["box.png"])
		if varc.value then
			esclib.draw:MaterialCentered(w-checkbox_size-15, h*0.5, checkbox_size*0.6, clr.frame.text, esclib.Materials["true.png"])
		end

		--if changed
		if varc.value ~= vars_copy[varid] then
			draw.RoundedBox(0,0,h-3,w,3,clr.button.discard)
		end
	end
end

esclib:AddNewSettingsType(name, required_params, secondary_params, draw_func)

-------------
/// FLOAT ///
-------------
local name = "float"
local required_params = {"value"}
local secondary_params = {"min", "max"}
local draw_func = function( panel, addon, varid, varc, callback, other )

	local button_wide= other["button_wide"]
	local button_tall = other["button_tall"]
	local addon_vars_copy = other["vars_copy"]
	local settab = other["bg"]
	local clr = esclib.addon:GetColors()
	local name_tr  = varc.name or addon:Translate(varc.name_tr)
	local desc = varc.desc or addon:Translate(varc.desc_tr)

	local name = esclib.util:TextCutAccurate(name_tr, "es_esclib_24_500", button_wide-15-90, "...")

	local button = panel:Add("DButton")
	button:SetSize(button_wide, button_tall)
	button:SetText("")
	if desc then
		local added = ""
		if varc.max or varc.min then
			added = "("..(varc.min or "∞").." - "..(varc.max or "∞")..")\n"
		end
		button:eAddHint(added.." "..desc,"es_esclib_20_500",TEXT_ALIGN_CENTER,settab)
	end

	function button:DoClick()
		esclib:TextInputWindow(esclib.addon:Translate("window_ValueEdit"), (addon:Translate(varc.name_tr) or varc.name).." ("..varc.value..")",true,function(res)
			if not res then return end
			if res == 0 then return end
			if varc.max and varc.min then
				res = math.Clamp(res, varc.min, varc.max)
			elseif varc.max then
				res = math.Clamp(res, -math.huge, varc.max)
			elseif varc.min then
				res = math.Clamp(res, varc.min, math.huge)
			end
				
			varc.value = res
			callback(varid,varc.value)
		end)
	end
	function button:Paint(w,h)
		local hovered = self:IsHovered()
		draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)

		draw.SimpleText(name,"es_esclib_24_500",15,h*0.5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText(varc.value,"es_esclib_24_500",w-15,h*0.5,clr.button.apply,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER,1)

		--if changed
		if varc.value ~= addon_vars_copy[varid] then
			draw.RoundedBox(0,0,h-5,w,5,clr.button.discard)
		end
	end
end

esclib:AddNewSettingsType(name, required_params, secondary_params, draw_func)


-----------------
/// NUMSLIDER ///
-----------------
local name = "numslider"
local required_params = { "value", "min", "max" }
local secondary_parameters = { "decimals", "step" }
local draw_func = function( panel, addon, varid, varc, callback, other )

	local button_wide= other["button_wide"]
	local button_tall = other["button_tall"]
	local addon_vars_copy = other["vars_copy"]
	local settab = other["bg"]
	local clr = esclib.addon:GetColors()
	local name_tr  = varc.name or addon:Translate(varc.name_tr)
	local desc = varc.desc or addon:Translate(varc.desc_tr)

	local name = esclib.util:TextCutAccurate(name_tr, "es_esclib_24_500", button_wide-5, "...")

	local button = panel:Add("DPanel")
	button:SetSize(button_wide, button_tall)
	if desc then
		button:eAddHint(desc,"es_esclib_20_500",TEXT_ALIGN_TOP,settab)
	end

	local slider = button:Add("esclib.numslider")
	slider:SetSize(button:GetWide()-10,button:GetTall()*0.3 )
	slider:CenterHorizontal()
	slider:SetY(button:GetTall()-slider:GetTall()-4)
	slider:SetBG(settab)

	slider:SetMin(varc.min or 0)
	slider:SetMax(varc.max or 1)
	slider:SetValue(varc.value)
	slider:SetDecimals(varc.decimals or 0)
	slider:SetStep(varc.step or 1)

	function button:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,clr.button.main)

		draw.SimpleText(name,"es_esclib_20_500",5,(h-slider:GetY())*0.5+5,clr.button.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		--if changed
		if varc.value ~= addon_vars_copy[varid] then
			draw.RoundedBox(0,0,h-2,w,2,clr.button.discard)
		end
	end


	slider.OnValueChanged = function(self,x)
		varc.value = x
		callback(varid,varc.value)
	end
end

esclib:AddNewSettingsType(name, required_params, secondary_parameters, draw_func)