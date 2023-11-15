local PANEL = {}

function PANEL:Init()
	self.skin = esclib.addon:GetCurrentSkin()
	self.colors = self.skin.colors 

	self.list = {}
	self.seqlist = {}
	self.panels = {}
	self.navfont = "es_esclib_20_500"
	self.activetextcol = self.colors.frame.text
	self.textcol = self.colors.frame.text
	self.textcolhover = self.colors.frame.text_hover
	self.minsize = 30
	self.dock = LEFT


	self.navbar = self:Add("DPanel")
	local navbar = self.navbar
	local accent = Color(13,13,13,100)
	
	self.navbar.Accent = self.colors.frame.accent2
	self.navbar.PaintBG = true
	self.navbar.ColorBG = self.colors.frame.accent

	local xb2 = 0
	local wb2 = 0
	function navbar.Paint(pnl,w,h)
		if self.activename then
			local button = self.list[self.activename]
			if not IsValid(button) then return end

			if self.navbar.PaintBG then
				local clr = self.navbar.ColorBG
				surface.SetDrawColor(clr.r,clr.g,clr.b,clr.a)
				surface.DrawRect(0,0,w,h)
			end

			-- surface.SetDrawColor(accent:Unpack())
			-- surface.DrawRect(0,h-3,w,3)

			local xb1,yb1,wb1,hb1 = button:GetBounds()
			
			xb2 = Lerp(0.1, xb2, xb1)
			wb2 = Lerp(0.1, xb2, wb1)

			local clr =  pnl.Accent
			surface.SetDrawColor(clr.r,clr.g,clr.b,clr.a)
			surface.DrawRect(xb2,h-3,wb1,3)
		end
	end

	self.content = self:Add("EditablePanel")
end

function PANEL:InvalidateSize()
	local navsize = draw.GetFontHeight(self.navfont)
	self.navbar:SetSize(self:GetWide(),navsize+10)

	self.content:SetSize(self:GetWide(),self:GetTall()-self.navbar:GetTall())
	self.content:SetPos(0,self.navbar:GetTall())
end

function PANEL:EnableBG(bool)
	self.navbar.PaintBG = bool
end

function PANEL:SetBGColor(col)
	if IsColor(col) then
		self.navbar.ColorBG = col
	end
end

function PANEL:SetAccentColor(col)
	if IsColor(col) then
		self.navbar.Accent = col
	end
end


function PANEL:SetActiveTextColor(col)
	if IsColor(col) then
		self.activetextcol = col
	end
end


function PANEL:SetTextColor(col)
	if IsColor(col) then
		self.textcol = col
	end
end

function PANEL:SetTextHoverColor(col)
	if IsColor(col) then
		self.textcolhover = col
	end
end

function PANEL:SetFont(font)
	self.navfont = font
	self:InvalidateSize()
end

function PANEL:AddTab(name,func,customCheck)
	if isfunction(customCheck) then
		if not customCheck() then return end
	end
	if not name then return end
	self:InvalidateSize()
	table.insert(self.seqlist,name)

	self.list[name] = vgui.Create("DButton",self.navbar)
	local button = self.list[name]
	button:SetText("")
	button:SetFont(self.navfont)
	button:SetTextColor(self.textcol)
	function button.Paint(pnl,w,h)
		local active = self.activename == name
		local hovered = pnl:IsHovered()
		draw.SimpleText(name,self.navfont, w*0.5, h*0.5, hovered and self.textcolhover or self.textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local tsize = esclib.util.GetTextSize(name,self.navfont)
	button:SetWide(math.max(self.minsize,tsize.w+20))
	button:Dock(self.dock)

	function button.DoClick(pnl)
		self:SetActive(name)
	end

	self.panels[name] = func

	if #self.seqlist == 1 then
		self:SetActive(name)
	end

	return button
end

function PANEL:GetCurrentPanel()
	return self.active
end

function PANEL:SetActive(name)
	if self.activename == name then return end
	if self.panels[name] then
		if IsValid(self.content) then

			local direction = 1
			for k,v in ipairs(self.seqlist) do
				if self.activename == v then
					direction = 1
					break
				elseif name == v then
					direction = -1
					break
				end
			end

			self.content:MoveTo(direction*self.content:GetWide(), self.content:GetY(), 0.1, 0, -1, function()
				if IsValid(self.content) then self.content:Remove() end
				if isfunction(self.panels[name]) then
					self.content = self:Add("EditablePanel")--self.panels[name](self.content)
					self:InvalidateSize()

					self.panels[name](self.content)

					if IsValid(self.content) then
						self.content:SetX(-direction*self.content:GetWide())
						self.content:MoveTo(0,self.content:GetY(),0.1)

						self.activename = name
					end
				end
			end)

			return
		end

		self.content = self:Add("EditablePanel")
		self:InvalidateSize()

		self.panels[name](self.content)
		self.activename = name
	end
end

function PANEL:GetActive()
	return self.activename
end

function PANEL:GetNavBar()
	return self.navbar
end

function PANEL:GetContent()
	return self.content
end

function PANEL:Paint(w,h)

end

vgui.Register( "esclib.combolist", PANEL, "DPanel" )