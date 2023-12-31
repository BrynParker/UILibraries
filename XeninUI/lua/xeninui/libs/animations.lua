local PNL = FindMetaTable("Panel")

function PNL:LerpColor(var, to, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local color = self[var]
	local anim = self:NewAnimation(duration)
	anim.Color = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartColor) then
			anim.StartColor = color
		end

		local newColor = XeninUI:LerpColor(newFract, anim.StartColor, anim.Color)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpVector(var, to, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local vector = self[var]
	local anim = self:NewAnimation(duration)
	anim.Vector = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartVector) then
			anim.StartVector = vector
		end

		local newColor = XeninUI:LerpVector(newFract, anim.StartVector, anim.Vector)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpAngle(var, to, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local angle = self[var]
	local anim = self:NewAnimation(duration)
	anim.Angle = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartAngle) then
			anim.StartAngle = angle
		end

		local newColor = XeninUI:LerpAngle(newFract, anim.StartAngle, anim.Angle)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:EndAnimations()
	for i, v in pairs(self.m_AnimList or {}) do
		if v.OnEnd then v:OnEnd(self)end
		self.m_AnimList[i] = nil
	end
end

function PNL:Lerp(var, to, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local varStart = self[var]
	local anim = self:NewAnimation(duration)
	anim.Goal = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.Start) then
			anim.Start = varStart
		end

		local new = Lerp(newFract, anim.Start, anim.Goal)
		self[var] = new
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpMove(x, y, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = Vector(x, y)
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = Vector(pnl.x, pnl.y, 0)
		end

		local new = LerpVector(newFract, anim.StartPos, anim.Pos)
		self:SetPos(new.x, new.y)
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpMoveY(y, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = y
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = pnl.y
		end

		local new = Lerp(newFract, anim.StartPos, anim.Pos)
		self:SetPos(pnl.x, new)
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpMoveX(x, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = x
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = pnl.x
		end

		local new = Lerp(newFract, anim.StartPos, anim.Pos)
		self:SetPos(new, pnl.y)
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpHeight(height, duration, callback, easeFunc)
	if (!duration) then duration = XeninUI.TransitionTime end
	if (!easeFunc) then easeFunc = function(a, b, c, d)
			return XeninUI:Ease(a, b, c, d)end end

	local anim = self:NewAnimation(duration)
	anim.Height = height
	anim.Think = function(anim, pnl, fract)
		local newFract = easeFunc(fract, 0, 1, 1)

		if (!anim.StartHeight) then
			anim.StartHeight = pnl:GetTall()
		end

		local new = Lerp(newFract, anim.StartHeight, anim.Height)
		self:SetTall(new)
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpWidth(width, duration, callback, easeFunc)
	if (!duration) then duration = XeninUI.TransitionTime end
	if (!easeFunc) then easeFunc = function(a, b, c, d)
			return XeninUI:Ease(a, b, c, d)end end

	local anim = self:NewAnimation(duration)
	anim.Width = width
	anim.Think = function(anim, pnl, fract)
		local newFract = easeFunc(fract, 0, 1, 1)

		if (!anim.StartWidth) then
			anim.StartWidth = pnl:GetWide()
		end

		local new = Lerp(newFract, anim.StartWidth, anim.Width)
		self:SetWide(new)
	end
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PNL:LerpSize(w, h, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Size = Vector(w, h)
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartSize) then
			anim.StartSize = Vector(pnl:GetWide(), pnl:GetWide(), 0)
		end

		local new = LerpVector(newFract, anim.StartSize, anim.Size)
		self:SetSize(new.x, new.y)
	end
	anim.OnEnd = function()
		if callback then
			callback()
		end
	end
end
