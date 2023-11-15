esclib.draw = {}

local clr_white = Color(255,255,255)
local clr_shadow = Color(30,30,33,255)

local sin = math.sin
local cos = math.cos
local rad = math.rad
local min = math.min

------------
/// TEXT ///
------------
function esclib.draw:ShadowText(text,font,px,py,col,textax,textay,offset,clr)
	local textax = textax or TEXT_ALIGN_LEFT
	local textay = textay or TEXT_ALIGN_TOP
	local offset = offset or 2

	draw.SimpleText(text,font, px+offset, py+offset, clr or clr_shadow, textax, textay)
	draw.SimpleText(text,font, px, py, col, textax, textay)
end

--------------
/// CIRCLE ///
--------------
function esclib.draw:GenCircle(x,y,r,v)
	local circle = {}
	local v = v or 360 -- poly count
    local angle = -rad(0) -- start angle
    local esin, ecos = sin(angle), cos(angle)
    for i = 0, 360, 360 / v do
        local newang = rad(i)
        local newsin, newcos = sin(newang), cos(newang)

        local oldcos = newcos * r * ecos - newsin * r * esin + x
        newsin = newcos * r * esin + newsin * r * ecos + y
        newcos = oldcos

        circle[#circle + 1] = {x = newcos,y = newsin}
    end
    return circle
end

function esclib.draw:PolyCircle( x, y, r, col, v)
	local circle = self:GenCircle(x,y,r, v or 360)

	if circle and #circle > 0 then
		surface.SetDrawColor(col:Unpack())
		draw.NoTexture()
		surface.DrawPoly(circle)
	end
end

function esclib.draw:Circle(x,y,r,col)
	local clr = esclib.addon:GetColors()

	x = x - r
	y = y - r
	col = col or clr_white

	surface.SetDrawColor(col:Unpack())
	surface.SetMaterial(esclib.Materials["circle.png"])
	surface.DrawTexturedRect(x, y, r*2, r*2)
end

-------------
/// OTHER ///
-------------
function esclib.draw:Mask(func, drawfunc, inverse, reference)
	if not reference then reference = 1 end

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(inverse and STENCILOPERATION_REPLACE or STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(reference)

	func()

	if inverse then reference = reference - 1 end
	render.SetStencilFailOperation(inverse and STENCILOPERATION_REPLACE or STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(reference)

	drawfunc()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

-----------------
/// MATERIALS ///
-----------------
function esclib.draw:Material(x,y,w,h,col,mat)
	if not mat then return end
	col = col or color_white
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x,y,w,h)
end

function esclib.draw:MaterialRotated(x,y,w,h,r,col,mat)
	if not mat then return end
	col = col or color_white
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x,y,w,h,r)
end

function esclib.draw:MaterialCentered(x,y,r,col,mat)
	self:Material(x-r, y-r, r*2, r*2, col, mat)
end

function esclib.draw:MaterialCenteredRotated(x,y,r,rot,col,mat)
	self:MaterialRotated(x, y, r*2, r*2, rot, col, mat)
end

function esclib.draw:MaterialCenteredShadowed(x,y,r,col,mat,offset, shadowcolor)
	local offset = offset or 1
	local shadowcolor = shadowcolor or clr_shadow
	self:Material(x-r+offset, y-r+offset, r*2+offset, r*2+offset, shadowcolor, mat)
	self:Material(x-r, y-r, r*2, r*2, col, mat)
end




-- https://dl.dropboxusercontent.com/u/104427432/Scripts/drawarc.lua
-- https://facepunch.com/showthread.php?t=1438016&p=46536353&viewfull=1#post46536353
function esclib.draw:SurfaceArc(arc,todraw)
	local todraw = min(#arc, (todraw or math.huge) )
	draw.NoTexture()
	for i=1,todraw do
		surface.DrawPoly(arc[i])
	end
end

function esclib.draw:Arc(cx,cy,radius,thickness,startang,endang,roughness,color,bClockwise)
	surface.SetDrawColor(color.r,color.g,color.b,color.a)
	local arc = esclib.util.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise) or {}
	esclib.draw:SurfaceArc(arc)
end