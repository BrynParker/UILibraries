local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self.inputWidth = sc(70)

	local textInput = self:Add("VoidUI.TextInput")
	textInput:SetWide(self.inputWidth)
	textInput:SSetTall(20)
	textInput:SetFont("VoidUI.R18")
	textInput.dockL = 4
	textInput.dockR = 4

	textInput:InvalidateLayout()


	local icon = self:Add("DImage")

	function textInput:OnValueChange(val)
		icon:SetMaterial(nil)
		if (#val > 3) then
			icon.isLoading = true
			VoidLib.FetchImage(val, function (mat)
				if (!IsValid(icon)) then return end
				icon.isLoading = false
				if (!mat) then return end
				icon:SetMaterial(mat)
			end)
		end
	end

	self.textInput = textInput

	self.icon = icon

end

function PANEL:PerformLayout(w, h)
	local center = w / 2
	local inputHalf = self.inputWidth / 2
	local textX = center - inputHalf

	surface.SetFont("VoidUI.R18")
	local textSize = surface.GetTextSize(VoidLib.ImageProvider)

	self.textX = textX
	self.textInput:SetPos(self.textX + textSize/2, sc(10))

	self.icon:SetSize(w*0.5,w*0.5)
	self.icon:SetPos(w/2-self.icon:GetWide()/2,h/2-self.icon:GetTall()/2+sc(10))
end

function PANEL:Paint(w, h)
	draw.RoundedBox(10, 0, 0, w, h, VoidUI.Colors.Primary)

	local provider = VoidLib.ImageProvider
	draw.SimpleText(provider, "VoidUI.R18", self.textX, sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	if (!self.icon:GetMaterial() or self.icon.isLoading) then
		local text = self.icon.isLoading and "Loading.." or "None"
		draw.SimpleText(text, "VoidUI.R36", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("VoidUI.IconSelector", PANEL, "Panel")