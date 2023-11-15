local PANEL_META = FindMetaTable("Panel")

local clamp = math.Clamp

function PANEL_META:eSetHoverPanel(generate_panel,preserve)
	if not isfunction(generate_panel) then return end

	local pnl = self

	local oldfunc
	if not self.eHasHoverPanel then 
		oldfunc = self.OnCursorEntered
	end
    function self:OnCursorEntered()
    	if isfunction(oldfunc) then oldfunc(self) end
    	local generated_pnl = generate_panel(self)
    	if not generated_pnl then return end
    	if not IsValid(generated_pnl) then return end
    	generated_pnl:SetMouseInputEnabled(false)
    	generated_pnl:SetAlpha(0)
    	generated_pnl:AlphaTo(255,0.1)

    	local oldthink = generated_pnl.Think
    	self.eHoverPanel = generated_pnl
    	self.eHasHoverPanel = true
    	function generated_pnl:Think()
    		if isfunction(oldthink) then oldthink(self) end
    		if not IsValid(pnl) then
    			if IsValid(generated_pnl) then generated_pnl:Remove() end
    			return 
    		end
    		if not pnl:IsHovered() then
	    		if preserve then
	    			self:Hide()
	    		else
	    			self:Remove()
	    		end
    		end
    	end
    end

    if not self.eHasHoverPanel then 
    	oldfunc = self.OnCursorExited
    end
    function self:OnCursorExited()
    	if isfunction(oldfunc) then oldfunc(self) end
    	if not self.eHoverPanel then return end
    	if IsValid(self.eHoverPanel) then
    		if preserve then
    			self.eHoverPanel:Hide()
    		else
    			self.eHoverPanel:Remove()
    		end
    	end
    end
end
-- --example
-- local pnl = vgui.Create("DPanel")
-- pnl:eSetHoverPanel(function(prnt)
-- 	local pnl = vgui.Create("DPanel")
-- 	pnl:SetSize(200,200)
-- 	return pnl
-- end)

--align uses TEXT_ALIGN ENUM but TEXT_ALIGN_CENTER uses mouse pos
function PANEL_META:eAddHint(text,font,align,parent_panel)
	local skin = esclib.addon:GetCurrentSkin()
	local clr = skin.colors

	local font = font or "es_esclib_20_500"
	local align = align or TEXT_ALIGN_CENTER

	local maxwidth = esclib.scrw*0.3
	local multiline = esclib.text:Multiline(text,font,maxwidth)
	local width = multiline.width+70
	local height = multiline.height+10

	self:eSetHoverPanel(function(hovered_panel)
		local pnl = vgui.Create("DPanel",parent_panel)
		pnl:SetSize(width,height)
		local scrw = esclib.scrw
		local scrh = esclib.scrh

		local posx = 0
		local posy = 0
		function pnl:Think()
			if not IsValid(hovered_panel) then
				self:Remove()
				return
			end
			if parent_panel and IsValid(parent_panel) then
				posx, posy = hovered_panel:LocalToScreen(0,0)
			end

			local x,y  = 0,0
			if (align == TEXT_ALIGN_RIGHT) then
				x = posx+hovered_panel:GetWide()+5
				y = posy+hovered_panel:GetTall()*0.5 - self:GetTall()*0.5
			elseif (align == TEXT_ALIGN_LEFT) then
				x = posx-self:GetWide()-5
				y = posy+hovered_panel:GetTall()*0.5 - self:GetTall()*0.5
			elseif (align == TEXT_ALIGN_TOP) then
				x = posx+hovered_panel:GetWide()*0.5-self:GetWide()*0.5
				y =posy - self:GetTall()-5
			elseif (align == TEXT_ALIGN_BOTTOM) then
				x = posx+hovered_panel:GetWide()*0.5-self:GetWide()*0.5 
				y = posy + hovered_panel:GetTall()+5
			else
				local mx,my = gui.MouseX(), gui.MouseY()
				if parent_panel and IsValid(parent_panel) then
					mx,my = parent_panel:ScreenToLocal(mx,my)
					-- scrw = parent_panel:GetWide()
					-- scrh = parent_panel:GetTall()
				end

				x = mx+5
				y = my+5
			end

			x = clamp(x, 0, scrw-self:GetWide())
			y = clamp(y, 0, scrh-self:GetTall())
			self:SetPos(x,y)
		end

		function pnl:Paint(w,h)
			draw.RoundedBox(8, 0,0, w,h, clr.hint.bg)
			esclib.draw:MaterialCentered(30, h*0.5, clamp(h*0.25, 0, 15), clr.hint.text, esclib.Materials["info.png"])
			esclib.text:DrawMultiline(multiline,60,5,clr.hint.text,TEXT_ALIGN_LEFT)
		end

		return pnl
	end,true)
end

----------------------
/// TEXT FUNCTIONS ///
----------------------
esclib.text = {}
function esclib.text:Multiline(text, font, mWidth, interval)
	local mWidth = mWidth or esclib.scrw
	local interval = interval or 2

	local result = {}
	result.lines = {}

	surface.SetFont(font)
	text = text:gsub("\n"," \\n ")
	local fontw = surface.GetTextSize(text)
	local fonth = draw.GetFontHeight(font)
	
	local buffer = { }

	local maxsize = 0
	for word in string.gmatch(text, "%S+") do
		local temp_text = (string.gsub((table.concat(buffer, " ").." "..word),"\\n","")):Trim()

		local w,h = surface.GetTextSize(temp_text)
		local newline = string.find(word,"\\n")
		if maxsize < w then maxsize = w end
		if (w > mWidth) or (newline) then
			table.insert(result.lines, table.concat(buffer, " "))

			buffer = { }
		end
		if not newline then
			table.insert(buffer, word)
		end
	end

	
	if #buffer > 0 then
		table.insert(result.lines, table.concat(buffer, " "))
	end

	local width = math.min(maxsize,mWidth)
	local height = (#result.lines*fonth)+(interval*#result.lines)


	result.font = font
	result.spacing = fonth+interval
	result.width = width
	result.height = height
	
	return result
end

function esclib.text:MultilineToString(multiline_data)
	return table.concat( multiline_data.lines, "\n" )
end

function esclib.text:DrawMultiline(multiline_data, x, y, color, alignX, alignY)
	for i,line in ipairs(multiline_data.lines) do
		draw.SimpleText(line, multiline_data.font, x, y + (i - 1) * multiline_data.spacing, color, alignX, alignY)
	end
end

function esclib.text:DrawMultilineShadow(multiline_data, x, y, color, alignX, alignY, offsetx)
	local offsetx = offsetx or 1
	for i,line in ipairs(multiline_data.lines) do
		draw.SimpleText(line, multiline_data.font, x+offsetx, y + (i - 1) * multiline_data.spacing+offsetx, color_black, alignX, alignY)
		draw.SimpleText(line, multiline_data.font, x, y + (i - 1) * multiline_data.spacing, color, alignX, alignY)
	end
end

function esclib.text:Capitalize(str)
    return (str:gsub("^%l", string.upper))
end



---------------------
/// QUICK WINDOWS ///
---------------------
function esclib:GenerateBGClicker(key_input)
	local clr = esclib.addon:GetColors()

	local scrw,scrh = esclib.scrw,esclib.scrh
	local bg = vgui.Create("EditablePanel")
	bg:SetSize(scrw,scrh)
	bg:MakePopup()
	bg:SetKeyboardInputEnabled(key_input or false)
	bg:SetAlpha(0)
	bg:AlphaTo(255,0.1)
	bg:SetZPos(102)
	function bg:Paint(w,h)
		draw.RoundedBox(0, 0,0,w,h, clr.background.col)
	end

	function bg:Close()
		if self.OnClose then self:OnClose() end
		self:AlphaTo(0,esclib.addon:GetVar("animtime"),0,function()
			self:Remove()
		end)
	end

	function bg:OnMousePressed(key)
		self:Close()
	end

	function bg:OnKeyCodePressed(key)
		if (key == KEY_F4) or (key == KEY_ESCAPE) then
			self:Close()
		end
	end

	return bg
end



function esclib:GeneratePopWindow(key_input)
	self.ready2close = false

	local clr = esclib.addon:GetColors()

	local scrw,scrh = esclib.scrw,esclib.scrh
	local bg = self:GenerateBGClicker(key_input)

	local pnl = vgui.Create("esclib.frame",bg)
	pnl.bg = bg
	pnl:SetSize(scrw*0.3, scrh*0.2)
	pnl:Center()
	function pnl:OnRemove()
		bg:Remove()
	end

	function pnl:Close()
		bg:Close()
	end

	return pnl
end



function esclib:TextInputWindow(title, text, numeric, callback)
	local pnl = self:GeneratePopWindow()
	pnl:SetTitle(title)
	pnl:SetSize(500,200)
	pnl:Center()
	pnl:SetRoundSize(0)
	local content = pnl:GetContent()

	local clr = esclib.addon:GetColors()

	local lbl = content:Add("DPanel")
	lbl:SetSize(content:GetWide(),content:GetTall()*0.3)
	function lbl:Paint(w,h)
		draw.SimpleText(text,"es_esclib_24_500",w*0.5,h*0.5,clr.frame.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local textinput = content:Add("DTextEntry")
	local offset = 10
	textinput:SetSize(content:GetWide()-offset*2,40)
	textinput:CenterHorizontal()
	textinput:CenterVertical(0.45)
	textinput:SetFont("es_esclib_20_500")
	textinput:SetTextColor(clr.frame.text)

	if numeric then 
		textinput:SetPlaceholderText( "500" )
		textinput:SetNumeric(true)
		function textinput:AllowInput(str)
			local disallow = true
			local text = self:GetText()

			if (string.find(str,"%d")) or (str==".") then
				if string.find(text,"%.") then return str=="." end

				disallow = false
			end

			return disallow
		end
	end

	function textinput:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,clr.frame.accent)

		local textcol = self:GetTextColor()
		self:DrawTextEntryText( textcol, clr.frame.text_hover, textcol )
	end

	function textinput:OnGetFocus()
		pnl.bg:SetKeyboardInputEnabled(true)
	end

	function textinput:OnLoseFocus()
		pnl.bg:SetKeyboardInputEnabled(false)
	end


	function textinput:OnEnter(text)
		if numeric then
			callback(self:GetFloat() or 0)
		else
			callback(text)
		end
		pnl:Close()
	end

	local buttonlist = content:Add("DPanel")
	buttonlist:SetSize(content:GetWide(), content:GetTall()*0.2)
	buttonlist:SetY(content:GetTall()-buttonlist:GetTall()-offset)
	buttonlist.Paint = nil

	local border = 25
	local revert = buttonlist:Add("DButton")
	revert:SetText("")
	revert:SetSize( buttonlist:GetWide()*0.5-border*2,buttonlist:GetTall() )
	revert:SetX(border)
	local hovcol = clr.button.discard
	function revert:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.discard_hover)
		draw.SimpleText(esclib.addon:Translate("button_Discard"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function revert:DoClick()
		pnl:Close()
	end

	local confirm = buttonlist:Add("DButton")
	confirm:SetSize(revert:GetWide(),revert:GetTall())
	confirm:SetX(revert:GetX() + revert:GetWide() + border*2)
	confirm:SetText("")
	local hovcol = clr.button.apply_hover
	function confirm:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.apply)
		draw.SimpleText(esclib.addon:Translate("button_Confirm"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function confirm:DoClick()
		textinput:OnEnter(textinput:GetText())
	end

	return textinput
end



function esclib:ConfirmWindow(title, text, callback)
	local pnl = self:GeneratePopWindow(true)
	pnl:SetTitle(title)
	pnl:SetSize(400,125)
	pnl:Center()
	pnl:SetRoundSize(0)
	local content = pnl:GetContent()

	function pnl:OnRemove()
		callback(false)
	end

	local clr = esclib.addon:GetColors()

	local lbl = content:Add("DPanel")
	lbl:SetSize(content:GetWide(),content:GetTall()*0.5)
	function lbl:Paint(w,h)
		draw.SimpleText(text,"es_esclib_24_500",w*0.5,h*0.5,clr.frame.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local buttonlist = content:Add("DPanel")
	buttonlist:SetSize(content:GetWide(), content:GetTall()*0.4)
	buttonlist:SetY(content:GetTall()-buttonlist:GetTall()-10)
	buttonlist.Paint = nil

	local border = 25

	local revert = buttonlist:Add("DButton")
	revert:SetText("")
	revert:SetSize( buttonlist:GetWide()*0.5-border*2,buttonlist:GetTall() )
	revert:SetX(border)
	local hovcol = clr.button.discard
	function revert:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.discard_hover)
		draw.SimpleText(esclib.addon:Translate("button_Discard"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function revert:DoClick()
		callback(false)
		pnl:Close()
	end

	local confirm = buttonlist:Add("DButton")
	confirm:SetSize(revert:GetWide(),revert:GetTall())
	confirm:SetX(revert:GetX() + revert:GetWide() + border*2)
	confirm:SetText("")
	local hovcol = clr.button.apply_hover
	function confirm:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.apply)
		draw.SimpleText(esclib.addon:Translate("button_Confirm"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function confirm:DoClick()
		callback(true)
		pnl:Close()
	end
end



function esclib:ChoiceMenu(title,items,multi,item_paint,callback,custom_filter,need_search)
	local items_list
	if not istable(items) then 
		if isfunction(items) then
			items_list = items()
		end
	else
		items_list = items
	end

	if items_list then
		if not istable(items_list) then return end
	else
		return
	end

	local items_list = table.Copy(items)
	if table.IsEmpty(items_list) then callback() return end
	
	local clr = esclib.addon:GetColors()
	local ply = LocalPlayer()
	local need_search = (need_search ~= nil) and true or false

	local pnl = self:GeneratePopWindow()
	pnl:SetTitle(title)
	pnl:SetSize(esclib.scrw*0.4,esclib.scrh*0.9)
	pnl:Center()
	pnl:SetRoundSize(16)
	local content = pnl:GetContent()

	local top_bar = content:Add("DPanel")
	if need_search then
		top_bar:SetSize(content:GetWide(),content:GetTall()*0.05)
		top_bar:SetY(10)
	else
		top_bar:SetHeight(0)
		top_bar:Hide()
	end

	local textinput = top_bar:Add("DTextEntry")
	local offset = esclib.util.GetTextSize(esclib.addon:Translate("phrase_Search"),"es_esclib_20_500").w + 25
	textinput:SetSize(top_bar:GetWide()-offset-10,top_bar:GetTall())
	textinput:SetX(offset)
	textinput:CenterVertical(0.45)
	textinput:SetFont("es_esclib_20_500")
	textinput:SetTextColor(clr.frame.text)

	function textinput:OnGetFocus()
		pnl.bg:SetKeyboardInputEnabled(true)
	end

	function textinput:OnLoseFocus()
		pnl.bg:SetKeyboardInputEnabled(false)
	end


	function top_bar:Paint(w,h)
		draw.SimpleText(esclib.addon:Translate("phrase_Search")..":","es_esclib_20_500", 10, h*0.5-2,clr.frame.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end

	function textinput:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,clr.frame.accent)

		local textcol = self:GetTextColor()
		self:DrawTextEntryText( textcol, clr.frame.text_hover, textcol )
	end

	local bot_bar = content:Add("DPanel")
	bot_bar:SetSize(content:GetWide(),content:GetTall()*0.07)
	bot_bar:SetY(content:GetTall()-bot_bar:GetTall())
	function bot_bar:Paint(w,h)
		draw.RoundedBoxEx(16,0,0,w,h,clr.frame.accent,false,false,true,true)
	end

	local scroll = content:Add("esclib.scrollpanel")
	scroll:SetY(top_bar:GetY()+top_bar:GetTall()+5)
	scroll:SetSize(content:GetWide(),content:GetTall()-top_bar:GetTall()-bot_bar:GetTall()-20)

	local list = scroll:Add("DIconLayout")
	list:SetY(5)
	list:SetSize(content:GetWide(),content:GetTall()-10)
	list:SetSpaceY(5)

	local selected
	if multi then selected = {} end

	function list:eClear()
		for k,v in ipairs(self:GetChildren()) do
			v:Remove()
		end
	end

	local function Update()
		local filter = string.lower(textinput:GetValue())


		local has_results = false
		for k,name in ipairs(items_list) do
			if custom_filter then
				if isfunction(custom_filter) then
					if not custom_filter(name,(filter or "")) then continue end
				end
			else
				if type(name) == "string" then
					if (not string.find(string.lower(name),filter)) then continue end
				end
			end

			local player_panel = list:Add("DButton")
			player_panel:SetSize(scroll:GetWide(),scroll:GetTall()*0.07)
			player_panel:SetText("")

			function player_panel:Paint(w,h)
				local active
				if multi then 
					active = selected[name] 
				else
					active = (selected == name)
				end

				if item_paint then
					if isfunction(item_paint) then item_paint(self, w,h, name, active) end
				else
					local hovered = self:IsHovered()

					draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
					if active then
						draw.RoundedBox(0,0,0,5,h,clr.button.apply)
					end

					draw.SimpleText(name,"es_esclib_24_500",w*0.5,h*0.5,hovered and clr.button.text_hover or clr.button.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
			function player_panel:DoClick()
				if multi then
					if selected[name] then selected[name] = nil return end
					selected[name] = name
				else
					selected = name
				end
			end
			has_results = true
		end

		if not has_results then
			local player_panel = list:Add("DPanel")
			player_panel:SetSize(scroll:GetWide(),scroll:GetTall()*0.07)
			player_panel:SetText("")

			function player_panel:Paint(w,h)
				-- draw.RoundedBox(0,0,0,w,h,clr.button.main)

				draw.SimpleText(esclib.addon:Translate("phrase_NoResults"),"es_esclib_24_500",w*0.5,h*0.5,hovered and clr.button.text_hover or clr.button.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			return
		end

	end

	Update()

	local border = 50
	local revert = bot_bar:Add("DButton")
	revert:SetText("")
	revert:SetSize( bot_bar:GetWide()*0.5-border*2,bot_bar:GetTall()*0.7 )
	revert:SetX(border)
	revert:CenterVertical()
	local hovcol = clr.button.discard
	function revert:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.discard_hover)
		draw.SimpleText(esclib.addon:Translate("button_Discard"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function revert:DoClick()
		callback()
		pnl:Close()
	end

	local confirm = bot_bar:Add("DButton")
	confirm:SetSize(revert:GetWide(),revert:GetTall())
	confirm:SetX(revert:GetX() + revert:GetWide() + border*2)
	confirm:SetText("")
	confirm:CenterVertical()
	local hovcol = clr.button.apply_hover
	function confirm:Paint(w,h)
		draw.RoundedBox(16,0,0,w,h,self:IsHovered() and hovcol or clr.button.apply)
		draw.SimpleText(esclib.addon:Translate("button_Confirm"),"es_esclib_20_500",w*0.5,h*0.5,clr.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function confirm:DoClick()
		if istable(selected) then
			if table.IsEmpty(selected) then
				selected = nil
			else
				selected = table.ClearKeys(selected)
			end
		end

		callback(selected)
		pnl:Close()
	end

	function textinput:OnChange()
		list:eClear()
		Update()
	end
end

function esclib:PlayerSelectWindow(title,multi,hide_self,callback,custom_filter)
	local player_list = player.GetAll()
	table.sort(player_list, function(a,b) return a:Nick() < b:Nick() end)

	local filter_func = function(ply,filter)
		if not IsValid(ply) then return false end
		if hide_self then 
			if ply:Name() == LocalPlayer():Name() then return false end
		end

		local res = false

		if ply.Name then
			res = string.find(string.lower(ply:Name()),filter)
		else
			res = (filter == "")
		end

		if custom_filter then
			if isfunction(custom_filter) then
				if not custom_filter(ply) then res = false end
			end
		end

		return res
	end

	local player_paint = function(self,w,h,ply,active)
		local hovered = self:IsHovered()
		local clr = esclib.addon:GetColors()

		draw.RoundedBox(0,0,0,w,h,hovered and clr.button.hover or clr.button.main)
		if active then
			draw.RoundedBox(0,0,0,5,h,clr.button.apply)
		end

		draw.SimpleText(ply:Name(),"es_esclib_24_500",15,h*0.5,hovered and clr.button.text_hover or clr.button.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if DarkRP then
			local jobclr = team.GetColor(ply:Team()) or escore.colors.default.white
			draw.SimpleText(ply:getDarkRPVar("job"),"es_esclib_24_500",w-15,h*0.5,jobclr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	local return_result = function(result)
		callback(result)
	end

	esclib:ChoiceMenu(title, player_list, multi, player_paint, return_result, filter_func, true)

end