////////////////////////
///  Util functions  ///
////////////////////////

VoidLib.LoadedImages = VoidLib.LoadedImages or {}

file.CreateDir("voidlib")
file.CreateDir("voidlib/images")

local matBlurScreen = Material( "pp/blurscreen" )

function VoidUI.Scale(x)
	if (ScrH() > 720) then return x end
	return math.ceil(x/1080*ScrH())
end

function VoidUI.PScale(x, w, _w)
	return math.ceil(_w * (x/w) )
end

local sc = VoidUI.Scale

function VoidUI.DrawPanelBlur(panel, fraction)
	local x, y = panel:LocalToScreen(0, 0)
	local w, h = panel:GetSize()

	surface.SetMaterial(matBlurScreen)
	surface.SetDrawColor(VoidUI.Colors.White)

	for i=0.33, 1, 0.33 do
		matBlurScreen:SetFloat( "$blur", fraction * 5 * i )
		matBlurScreen:Recompute()
		if (render) then render.UpdateScreenEffectTexture() end 
		surface.DrawTexturedRect(x * -1, y * -1, w, h)
	end
end

-- Credit goes to wiki
function VoidUI.DrawRotatedText(text, x, y, color, font, ang)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.SetFont(font)
	surface.SetTextColor(color)
	surface.SetTextPos(0, 0)
	local textWidth, textHeight = surface.GetTextSize( text )
	local rad = -math.rad( ang )
	x = x - ( math.cos( rad ) * textWidth / 2 + math.sin( rad ) * textHeight / 2 )
	y = y + ( math.sin( rad ) * textWidth / 2 + math.cos( rad ) * textHeight / 2 )
	local m = Matrix()
	m:SetAngles(Angle(0, ang, 0))
	m:SetTranslation(Vector(x, y, 0))
	cam.PushModelMatrix(m)
		surface.DrawText(text)
	cam.PopModelMatrix()
	render.PopFilterMag()
	render.PopFilterMin()
end

function VoidUI.DrawBox(x,y,w,h,col)
	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)
end

VoidUI.DrawRect = VoidUI.DrawBox

local cornerMat = CreateMaterial("cornarr1", "UnlitGeneric", {
    ["$basetexture"] = "gui/corner8",
    ["$alphatest"] = 1,
    ["$translucent"] = 1,
})

-- Full credit goes to DarkRP for textWrap function

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function VoidUI.TextWrap(text, font, maxWidth)

	if (!text) then 
		return "" 
	end

    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
		local char = string.sub(word, 1, 1)
		if char == "\n" or char == "\t" then
			totalWidth = 0
		end

		local wordlen = surface.GetTextSize(word)
		totalWidth = totalWidth + wordlen

		-- Wrap around when the max width is reached
		if wordlen >= maxWidth then -- Split the word if the word is too big
			local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
			totalWidth = splitPoint
			return splitWord
		elseif totalWidth < maxWidth then
			return word
		end

		-- Split before the word
		if char == ' ' then
			totalWidth = wordlen - spaceWidth
			return '\n' .. string.sub(word, 2)
		end

		totalWidth = wordlen
		return '\n' .. word
	end)

    return text
end


function VoidLib.FetchImage(id, callback, instant)
	local loadedImage = VoidLib.LoadedImages[id]
	if (loadedImage) then
		callback(loadedImage)
		return
	end

	if (file.Exists("voidlib/images/" .. id .. ".png", "DATA")) then
		local mat = Material("data/voidlib/images/"..id..".png", "noclamp smooth")
		if (!mat) then
			-- prevent memory leaks
			mat = VoidUI.Icons.Close
		end
		VoidLib.LoadedImages[id] = mat
		callback(mat)
	else
		http.Fetch("https://" .. VoidLib.ImageProvider .. id .. ".png", function (body, size, headers, code)
			if (code != 200) then
				callback(false)
				return
			end

			if (!body or body == "") then 
				callback(false)
				return 
			end


			file.Write("voidlib/images/" .. id .. ".png", body)
			local mat = Material("data/voidlib/images/" .. id .. ".png", "noclamp smooth")
			VoidLib.LoadedImages[id] = mat
			if (!instant) then
				callback(mat)
			end
		end, function ()
			callback(false)
		end)
	end
end

//////////////////
///  Stencils  ///
//////////////////


function VoidUI.StencilReset()
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
end

function VoidUI.StencilEnable()
	render.SetStencilEnable(true)
end

function VoidUI.StencilMaskStart()
	VoidUI.StencilReset()
	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)
end

function VoidUI.StencilMaskApply()
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilFailOperation(STENCIL_KEEP)
end

function VoidUI.StencilMaskEnd()
	render.SetStencilEnable(false)
	VoidUI.StencilReset()
end

function VoidUI.StencilStart()
	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS ) 	
	render.SetStencilReferenceValue( 1 )
	render.SetColorModulation( 1, 1, 1 )
end

function VoidUI.StencilReplace()
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue(0)
end



function VoidUI.StencilEnd()
	render.SetStencilEnable(false)
	render.ClearStencil()
end

/////////////////////
///  World rings  ///
/////////////////////
-- Credit goes to Raubana and Luabee Gaming

local color_mask2 = Color(0,0,0,0)

local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
    render.SetStencilReferenceValue( ref )
    render.SetStencilCompareFunction( compare_func )
    render.DrawSphere(pos, radius, detail, detail, color)
end
 
-- Call this before calling render.AddWorldRing()
function VoidLib.StartWorldRings()

	VoidUI.StencilReset()

    VoidLib.WORLD_RINGS = {}
    cam.IgnoreZ(false)
    render.SetStencilEnable(true)
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.ClearStencil()
    render.SetColorMaterial()
end
 
-- Args: pos = where, radius = how big, [thicc = how thick, detail = how laggy]
-- Detail must be an odd number or it will look like shit.
function VoidLib.AddWorldRing(pos, radius, thicc, detail)
    detail = detail or 25
    thicc = thicc or 10
    local z = {detail=detail, thicc=thicc, pos=pos, outer_r=radius, inner_r=math.max(radius-thicc,0)}
    table.insert(VoidLib.WORLD_RINGS, z)
end
 
-- Call this to actually draw the rings added with render.AddWorldRing()
function VoidLib.FinishWorldRings(color)
    local ply = LocalPlayer()
    local zones = VoidLib.WORLD_RINGS
   
    render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
   
    for i, zone in ipairs(zones) do
        local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.outer_r, color_mask2, zone.detail ) -- big, inside-out
    end
    render.SetStencilZFailOperation( STENCILOPERATION_DECR )
    for i, zone in ipairs(zones) do
        local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.outer_r, color_mask2, zone.detail ) -- big
    end
    render.SetStencilZFailOperation( STENCILOPERATION_INCR )
    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.inner_r, color_mask2, zone.detail ) -- small, inside-out
    end
    render.SetStencilZFailOperation( STENCILOPERATION_DECR )
    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.inner_r, color_mask2, zone.detail ) -- small
    end
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
   
    local cam_pos = ply:EyePos()
    local cam_angle = ply:EyeAngles()
    local cam_normal = cam_angle:Forward()
    cam.IgnoreZ(true)
    render.SetStencilReferenceValue( 1 )
    render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal,10000,10000,color,cam_angle.roll)
    cam.IgnoreZ(false)
    render.SetStencilEnable(false)

	VoidUI.StencilReset()
end

////////////////////
///  Extensions  ///
////////////////////

local PANEL = FindMetaTable("Panel")

-- Autoscale functions

function PANEL:SetOrigSize(w, h)
	self.origSize = {}
	self.origSize.w = w
	self.origSize.h = h
end

function PANEL:AutoScale()
	if (self:GetDock() != NODOCK) then return end
	
	local w, h = self:GetSize()
	self:SetSize(VoidUI.Scale(w), VoidUI.Scale(h))
end

function PANEL:SDockMargin(l,t,r,b)
	self:DockMargin(VoidUI.Scale(l), VoidUI.Scale(t), VoidUI.Scale(r), VoidUI.Scale(b))
end

function PANEL:SSetSize(w, h)
	self:SetSize(sc(w), sc(h))
end

function PANEL:SSetTall(x, panel)
	if (panel) then
		local s = VoidUI.PScale(x, panel.origSize.h, panel:GetTall())
		self:SetTall(s)
	else
		self:SetTall(sc(x))
	end
end

function PANEL:SSetPos(x, y)
	self:SetPos(sc(x), sc(y))
end

function PANEL:STop(s)
	local x, y = self:GetPos()
	self:SetPos(x, y + sc(s))
end

function PANEL:SSetWide(x, panel)
	if (panel) then
		local s = VoidUI.PScale(x, panel.origSize.w, panel:GetWide())
		self:SetWide(s)
	else
		self:SetWide(sc(x))
	end
end

function PANEL:SDockPadding(l,t,r,b,panel)
	if (panel) then
		l = VoidUI.PScale(l, panel.origSize.w, panel:GetWide())
		t = VoidUI.PScale(t, panel.origSize.h, panel:GetTall())
		r = VoidUI.PScale(r, panel.origSize.w, panel:GetWide())
		b = VoidUI.PScale(b, panel.origSize.h, panel:GetTall())
		self:DockPadding(l,t,r,b)
	else
		self:DockPadding(VoidUI.Scale(l), VoidUI.Scale(t), VoidUI.Scale(r), VoidUI.Scale(b))
	end
end

-- Setters

function PANEL:MarginTop(newTop, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(newTop, panel.origSize.h, panel:GetTall())
		self:DockMargin(left, x, right, bottom)
	else
		self:DockMargin(left, sc(newTop), right, bottom)
	end
end

function PANEL:MarginLeft(newLeft, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(newLeft, panel.origSize.w, panel:GetWide())
		self:DockMargin(x, top, right, bottom)
	else
		self:DockMargin(sc(newLeft), top, right, bottom)
	end
end

function PANEL:MarginRight(newRight, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(newRight, panel.origSize.w, panel:GetWide())
		self:DockMargin(left, top, x, bottom)
	else
		self:DockMargin(left, top, sc(newRight), bottom)
	end
end

function PANEL:MarginBottom(newBottom, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(newBottom, panel.origSize.h, panel:GetTall())
		self:DockMargin(left, top, right, x)
	else
		self:DockMargin(left, top, right, sc(newBottom))
	end
end

function PANEL:MarginSides(m, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(m, panel.origSize.w, panel:GetWide())
		self:DockMargin(x, top, x, bottom)
	else
		self:DockMargin(sc(m), top, sc(m), bottom)
	end
end
function PANEL:MarginTops(m, panel)
	local left, top, right, bottom = self:GetDockMargin()
	if (panel) then
		local x = VoidUI.PScale(m, panel.origSize.h, panel:GetTall())
		self:DockMargin(left, x, right, x)
	else
		self:DockMargin(left, sc(m), right, sc(m))
	end
end


-- Getters

function PANEL:GetTopMargin()
	local left, top, right, bottom = self:GetDockMargin()
	return top
end

function PANEL:GetBottomMargin()
	local left, top, right, bottom = self:GetDockMargin()
	return bottom
end

function PANEL:GetLeftMargin()
	local left, top, right, bottom = self:GetDockMargin()
	return left
end

function PANEL:GetRightMargin()
	local left, top, right, bottom = self:GetDockMargin()
	return right
end


function PANEL:FillContents()

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)

end

///////////////
///  Utils  ///
///////////////

function VoidUI.CreatePopup(strTitle, strPrompt, strYes, strNo, fContinue, fCancel)
	local popup = vgui.Create("VoidUI.Popup")
	popup:SetText(strTitle, strPrompt)
	popup:Continue(strYes, fContinue)
	popup:Cancel(strNo, fCancel)
	popup:SSetTall(160)

	return popup
end

function VoidUI.CreateValuePopup(strTitle, strPrompt, strYes, strNo, fContinue, bIsNumeric, xDefaultValue, fCancel)
	local popup = vgui.Create("VoidUI.ValuePopup")
	popup:SetText(strTitle, strPrompt)
	popup:Continue(strYes, fContinue)
	popup:Cancel(strNo, fCancel)

	if (#strPrompt > 50) then
		popup:SSetTall(210)
	else
		popup:SSetTall(180)
	end

	if (xDefaultValue) then
		popup.textInput.entry:SetValue(xDefaultValue)
	end

	if (bIsNumeric) then
		popup:SetNumeric()
	end

	return popup
end

-- Credit goes to Ben for the drawing functions

function VoidUI.DrawCircle(x, y, r, step, cache)
    local positions = {}

    for i = 0, 360, step do
        positions[#positions + 1] = {
            x = x + math.cos(math.rad(i)) * r,
            y = y + math.sin(math.rad(i)) * r
        }
    end

	draw.NoTexture()

    return (cache and positions) or surface.DrawPoly(positions)
end

function VoidUI.DrawArc(x, y, r, startAng, endAng, step, cache)
    local positions = {}


    positions[1] = {
        x = x,
        y = y
    }

    for i = startAng - 90, endAng - 90, step do
        positions[#positions + 1] = {
            x = x + math.cos(math.rad(i)) * r,
            y = y + math.sin(math.rad(i)) * r,
        }
    end


    return (cache and positions) or surface.DrawPoly(positions)
end

function VoidUI.Lerp(startTime, duration)
	local startTime = startTime
	local animLength = 1
	local currTime = SysTime()

	if (startTime == 0) then return end

	local timeElapsed = currTime - startTime

	local fraction = timeElapsed / animLength
	local returnVal = false
	if (fraction >= 1) then
		fraction = math.Clamp(fraction, 0, 1)
		returnVal = true
	end

	return fraction, returnVal
end

/////////////////////
///  Concommands  ///
/////////////////////

