function cScrH(val)
	return (val / 1800) * ScrH() * 1.5
end

function cScrW(val)
	return (val / 3200) * ScrW() * 1.5 
end

local Fonts = {}   
Fonts["UFont"] = "Ultimate BGT Fonts Light"
  
for a, b in pairs(Fonts) do
	for k = 10,40 do
		local calculated_fontsize = cScrH(k)  
		surface.CreateFont( a .. "_Size" .. k, {font = b, size = calculated_fontsize, weight = cScrW(500), antialias = true})
		surface.CreateFont( a .. "Outline_Size" .. k, {font = b, size = calculated_fontsize, weight = 700, outline = true})
	end
end  