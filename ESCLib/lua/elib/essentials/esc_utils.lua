esclib.util = {}

local sin = math.sin
local cos = math.cos
local floor = math.floor
local max = math.max
local min = math.min

--Do it once
if not esclib.scrw or not esclib.scrh then
	esclib.scrw = ScrW()
	esclib.scrh = ScrH()
end

hook.Add("OnScreenSizeChanged", "esclib.onscreenchange", function(oldw, oldh)
	esclib.scrw = ScrW()
	esclib.scrh = ScrH()
end)

local blur = Material("pp/blurscreen")
function esclib.util:DrawBlur(pnl,amount)
	local x, y, w, h = pnl:GetBounds(0, 0)
    surface.SetDrawColor(color_white:Unpack())
    surface.SetMaterial(blur)
    for i = 1, 6 do
        blur:SetFloat("$blur", 3)
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x,y,w,h)
    end
end

function esclib.util:TextOnBG(bgCol, col_white, col_black)
	return (((bgCol.r + bgCol.g + bgCol.b) / 3 >= 127) and col_white or col_black)
end

function esclib.util.GetTextSize(txt,font)
	surface.SetFont(font)
	local x, y = surface.GetTextSize(txt)
	return {w = x, h = y}
end

function esclib.util:TextSize(txt,font)
	surface.SetFont(font)
	return surface.GetTextSize(txt)
end

--fast function, but can be less accurate
function esclib.util:TextCut(text,font,maxw, add_symbol)
	if not text then return end
	local add_symbol = add_symbol or ""

	local textw,texth = esclib.util:TextSize(text,font)
	if textw <= maxw then return text end

	local len = string.len( text )

	local to_cut = math.Clamp(math.ceil((textw-maxw)/(textw/len)), 0, len )

	return string.sub( text, 1, len-to_cut )..add_symbol
end

function esclib.util:TextCutAccurate(text,font,maxw, add_symbol)
	if not text then return end
	local add_symbol = add_symbol or ""

	local textw_max,_ = esclib.util:TextSize(text,font)
	if textw_max <= maxw then return text end

	local text_cutted = text
	for i = string.len(text), 1, -1 do
		text_cutted = string.sub( text, 1, i )
		local textw,_ = esclib.util:TextSize(text_cutted,font)
		if textw <= maxw then
			break
		end
	end

	return text_cutted..add_symbol
end

function esclib.util:Round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function esclib.util:NiceTime(time, bHours, bMinutes, bSeconds, bMilliseconds)
	local time = string.FormattedTime( time )
	local result = ""

	local hours, bHours 	= time.h, ((bHours == nil) or bHours)
	local minutes, bMinutes = time.m, ((bMinutes == nil) or bMinutes)
	local seconds, bSeconds = time.s, ((bSeconds == nil) or bSeconds)
	local milliseconds, bMilliseconds = time.ms, (bMilliseconds)

	if (not bHours) then minutes = minutes + (hours * 60) end
	if (not bHours) and (not bMinutes) then seconds = seconds + (minutes * 60) end
	if (not bHours) and (not bMinutes) and (not bSeconds) then milliseconds = milliseconds + (seconds * 1000) end

	if bHours then
		result = result..string.format("%d%s ", hours, esclib.addon:Translate("char_hours"))
	end
	if bMinutes then
		result = result..string.format("%d%s ", minutes, esclib.addon:Translate("char_minutes"))
	end
	if bSeconds then
		result = result..string.format("%d%s ", seconds, esclib.addon:Translate("char_seconds"))
	end
	if bMilliseconds then
		result = result..string.format("%d%s ", milliseconds, esclib.addon:Translate("char_milliseconds"))
	end



	return result
end

function esclib.util:NumberLimit(number, min, max, str_format)
	local res = number

	if number >= max then
		res = string.format(str_format or "%d+", max-1 )
	elseif number < min then
		res = string.format(str_format or "<%d", min )
	end

	return res
end

--https://gist.github.com/theawesomecoder61/d2c3a3d42bbce809ca446a85b4dda754
function esclib.util.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness, rote)
	local triarc = {}
	local deg2rad = math.pi / 180
	local rote = rote or 0
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	local bClockwise = (startang < endang)
	startang = startang + rote
	endang = endang + rote
	if bClockwise then
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	elseif (startang > endang) then 
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	end
	
	
	-- Define step
	local roughness = max(roughness or 1, 1)
	local step = roughness
	if bClockwise then
		step = math.abs(roughness) * -1
	end
	
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(inner, {
			x=cx+(cos(rad)*r),
			y=cy+(sin(rad)*r)
		})
	end
	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(outer, {
			x=cx+(cos(rad)*radius),
			y=cy+(sin(rad)*radius)
		})
	end
	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[floor(tri/2)+1]
		p3 = inner[floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[floor((tri+1)/2)]
		else
			p2 = inner[floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
	
end


esclib.restricted_chars = {
	["\\"] = true,
	["/"] = true,
	[":"] = true,
	["*"] = true,
	["?"] = true,
	['"'] = true,
	["'"] = true,
	["<"] = true,
	[">"] = true,
	["|"] = true,
	["CON"] = true,
	["PRN"] = true,
	["AUX"] = true,
	["NUL"] = true,
	["COM"] = true,
	["LPT"] = true,
}

function esclib.util:IsRestrictedChar(strs)
	return esclib.restricted_chars[strs or ""]
end