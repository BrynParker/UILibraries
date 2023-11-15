--------------------
/// FONT MANAGER ///
--------------------
-- EXAMPLE:
-- esclib:SetFontName("shop")
-- esclib:Font(20, 500) -- es_shop_20_500
-- esclib:Font(23, 500) -- es_shop_23_500

-- esclib:SetFontName("jobs")
-- esclib:SetFont("Roboto")
-- esclib:Font(20, 500) -- es_jobs_20_500
-- esclib:ResetFont() -- returns font settings to default


-----------------
/// FUNCTIONS ///
-----------------
esclib.fonts = esclib.fonts or {}
esclib.fonts.heights = {}
esclib.fonts.list = esclib.fonts.list or {}
esclib.fonts.prefix = "es_"
esclib.fonts.default = "Tahoma"
esclib.fonts.curname = "newfont"
local defaultfont = esclib.fonts.default

function esclib.fonts:CreateNew(file_fontname, fontname, size, weight, fontdata)
	local size = size or 15
	local weight = weight or 500
	if fontdata then
		size = fontdata.size or size
		weight = fontdata.weight or weight
	end

	local target_fontname = self.prefix..fontname.."_"..size.."_"..weight

	local target_fontdata = {
		font = file_fontname,
		size = size,
		weight = weight,
		extended = true
	}

	if fontdata then
		table.Merge(target_fontdata, fontdata)
	end

	if not self.list[target_fontname] then
		surface.CreateFont(target_fontname, target_fontdata)
		esclib.fonts.heights[target_fontname] = draw.GetFontHeight(target_fontname)
		self.list[target_fontname] = true
	end

	return target_fontname
end


function esclib:Font(size, weight, fontdata)
	local target_fontname = self.fonts.prefix..self.fonts.curname.."_"..size.."_"..weight

	if self.fonts.list[target_fontname] ~= nil then
		return target_fontname
	end

	return self.fonts:CreateNew(self.fonts.default, self.fonts.curname, size, weight, fontdata)
end

function esclib.fonts:GetAll()
	return self.list
end


function esclib:SetFontName(name)
	self.fonts.curname = isstring(name) and name or "newfont"
end


function esclib:SetFont(name)
	self.fonts.default = isstring(name) and name or defaultfont
end


function esclib:ResetFont()
	self.fonts.default = defaultfont
end


function esclib:SetFontPrefix(name)
	self.fonts.prefix = isstring(name) and name or defaultfont
end


concommand.Add("esclib_getfonts",function()
	local fonts = table.GetKeys(esclib.fonts:GetAll())
	if #fonts ~= 0 then
		PrintTable(fonts)
	else
		print("No fonts.")
	end
end)



-------------
/// FONTS ///
-------------	
esclib:SetFontName("esclib")
esclib:SetFont("Amsterdam")
esclib:Font(30,500)
esclib:Font(26,500)
esclib:Font(24,500) --es_esclib_24_500
esclib:Font(22,500)
esclib:Font(20,500) --es_esclib_20_500
esclib:Font(18,500)
esclib:Font(16,500)
esclib:Font(10,500)