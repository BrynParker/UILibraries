local PANEL = {}

function PANEL:Init()
	self:SetTextColor(Color(255,255,255,255))
	self:SetFont("HUDNumber5")
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(29, 0, 255, 255)) 
end

function PANEL:OnCursorEntered()
	self:SetTextColor(Color(0,0,0,255))
end

function PANEL:OnCursorExited()
	self:SetTextColor(Color(255,255,255,255))
end

vgui.Register("UBlueButton", PANEL, "DButton")

PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 255)) 
end

vgui.Register("URedButton", PANEL, "UBlueButton")

PANEL = {}

function PANEL:Init()
	self:SetTextColor(Color(0,0,0,255))
	self:SetFont("HUDNumber5")
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) 
end

function PANEL:OnCursorExited()
	self:SetTextColor(Color(0,0,0,255))
end

vgui.Register("UWhiteButton", PANEL, "UBlueButton")

PANEL = {}

function PANEL:Init()
	local sbar = self:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
	end
	
	sbar:SetWide(0)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255)) 
end

function PANEL:Think()
	if input.IsKeyDown(KEY_DOWN) then
		local x = self:GetWide()
		local y = self:GetTall()
		local cursorX, cursorY = self:LocalCursorPos()
		
		if cursorX > x or cursorX < 0 or cursorY > y or cursorY < 0 then return end
		
		local sbar = self:GetVBar()
		
		sbar:AddScroll(0.4)
	elseif input.IsKeyDown(KEY_UP) then
		local x = self:GetWide()
		local y = self:GetTall()
		local cursorX, cursorY = self:LocalCursorPos()
		
		if cursorX > x or cursorX < 0 or cursorY > y or cursorY < 0 then return end
		
		local sbar = self:GetVBar()
		
		sbar:AddScroll(-0.4)
	end
end

function PANEL:SetScroll(amount)
	local sbar = self:GetVBar()
	
	sbar:SetScroll(amount)
end

vgui.Register("UBlackScrollPanel", PANEL, "DScrollPanel")

PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0)) 
end

vgui.Register("UClearScrollPanel", PANEL, "UBlackScrollPanel")

PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80)) 
end

vgui.Register("ULightPanel", PANEL, "DPanel")

PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 185)) 
end

vgui.Register("UDarkPanel", PANEL, "DPanel")

PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50)) 
	
	draw.RoundedBox(0, 0, 0, w, 3, Color(0, 0, 0, 255)) 
	draw.RoundedBox(0, 0, 0, 3, h, Color(0, 0, 0, 255)) 
	draw.RoundedBox(0, 0, h - 3, w, 3, Color(0, 0, 0, 255)) 
	draw.RoundedBox(0, w - 3, 0, 3, h, Color(0, 0, 0, 255)) 
end

vgui.Register("UGreyButton", PANEL, "DButton")
