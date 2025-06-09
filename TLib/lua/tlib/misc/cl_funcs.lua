function TLib.Font(name, size, font, weight)
	surface.CreateFont("TLib.Font."..name, {font = font or "Montserrat Medium", size = size, weight = weight or 500, antialias = true,})
    return "TLib.Font."..name
end

TLib.Font("placeholder", 20)
TLib.Font("placeholderBIG", 40)
TLib.Font("Dev", 17)
TLib.Font("TGF_WeaponInfo", 20)

----------------------------------------------------------------------------------------------------------------------!]]
--! Draw Functions
----------------------------------------------------------------------------------------------------------------------!]]

function TLib.DrawOutlinedBox(radius, x,y,w,h, outline, background, tl, tr, bl, br)
    radius = radius or TLib.Config.cornerradius
    outline = outline or TLib.Theme.outline
    background = background or TLib.Theme.background
    tl = tl == nil and true or tl
    tr = tr == nil and true or tr
    bl = bl == nil and true or bl
    br = br == nil and true or br

    draw.RoundedBoxEx(radius, x, y, w, h, outline, tl, tr, bl, br)

    draw.RoundedBoxEx(radius, x+TLib.Config.outlinewidth, y+TLib.Config.outlinewidth, w-TLib.Config.outlinewidth*2, h-TLib.Config.outlinewidth*2, TLib.Theme.background, tl , tr , bl , br )
    draw.RoundedBoxEx(radius, x+TLib.Config.outlinewidth, y+TLib.Config.outlinewidth, w-TLib.Config.outlinewidth*2, h-TLib.Config.outlinewidth*2, background, tl, tr, bl, br )
end

function TLib.DrawLine(x,y,w,h, color)
	surface.SetDrawColor( color or TLib.Theme.outline )
	surface.DrawLine(0, h - 1, w, h - 1 )
	surface.DrawLine(0, h - 2, w, h - 2)
	surface.DrawLine(0, h - 3, w, h - 3)
end

function TLib.DrawInfoText(x,y, text, font, textcolor,outlinecol, backcol)
    surface.SetFont(font)
    local textw, texty = surface.GetTextSize(text)
    local x, y = x - textw / 2, y - texty / 2
    TLib.DrawOutlinedBox(nil, x, y, textw + 16, texty + 16, outlinecol or TLib.Theme.outline, backcol or TLib.Theme.background)
    draw.SimpleText(text, font, x + 8, y + 8, textcolor or TLib.Theme.text.h1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color) 
	surface.SetDrawColor(color)
	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
end

function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
	local triarc = {}

	local roughness = math.max(roughness or 1, 1)
	local step = roughness

	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	for tri=1,#inner*2 do
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	return triarc
	
end

function surface.DrawArc(arc)
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end


function DrawBlur(s, amount, passes)
 		local x, y = s:LocalToScreen(0, 0)
		local scrW, scrH = ScrW(), ScrH()

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(Material("pp/blurscreen"))

		for i = 1, 3 do
			blur:SetFloat("$blur", (i / 3) * (amount or 8))
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
end

----------------------------------------------------------------------------------------------------------------------!]]
--! Helper Functions
----------------------------------------------------------------------------------------------------------------------!]]

function TLib.OnlineAdmins()
    local admincount = 0
    for _, v in ipairs(player.GetAll()) do
        if v:IsAdmin() then
            admincount = admincount + 1
        end
    end
    return admincount
end

function TLib.FormatTimer(seconds)
    local seconds = tonumber(seconds)
    if seconds <= 0 then
        return "00:00"
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return mins..":"..secs
    end
end

function GetTime()
    return os.date("%H:%M:%S")
end

function GetDate()
    return os.date("%d.%m.%Y")
end

function FormatNumber(n)
    if not n then return 0 end
    if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    sep = sep or '.'
    local dp = string.find(n, '%,') or #n+1
    for i=dp-4, 1, -3 do
        n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end

function getTextSize(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

function LerpColor(frac, from, to)
    return Color(
		Lerp(frac, from.r, to.r),
		Lerp(frac, from.g, to.g),
		Lerp(frac, from.b, to.b),
		Lerp(frac, from.a, to.a)
	)
end

function lerpColor(t, a, b)

	local newCol = Color(255, 255, 255, 255)

	newCol.r = Lerp(t, a.r, b.r)

	newCol.g = Lerp(t, a.g, b.g)

	newCol.b = Lerp(t, a.b, b.b)

	newCol.a = Lerp(t, a.a, b.a)

	return newCol

end

function Fade( a, b, frac, alpha )
    local res, me
     res = Color( 0, 0, 0, alpha )
     me = ( 1 - frac )
    res.r = ( a.r * me ) + ( b.r * frac )
    res.g = ( a.g * me ) + ( b.g * frac )
    res.b = ( a.b * me ) + ( b.b * frac )
    return res
end

----------------------------------------------------------------------------------------------------------------------!]]
--! QoL Functions
----------------------------------------------------------------------------------------------------------------------!]]

local player = FindMetaTable("Player")

function player:GetTeamColor()
    return team.GetColor(self:Team())
end

function player:GetTeamColorAlpha()
    return ColorAlpha(self:GetTeamColor(), 32)
end

function player:GetTeamName()
    return team.GetName(self:Team())
end

function player:GetMoney()
    return DarkRP.formatMoney(self:getDarkRPVar("money"))
end

function player:GetRank()
    if self:GetJobRankName() == "No Rank" then 
        return ""
    else
        return self:GetJobRankName()
    end
end

function player:SteamName()
    steamworks.RequestPlayerInfo( self:SteamID64() )
    return steamworks.GetPlayerName( self:SteamID64() )
end

function team.GetModel(teamid)
    return RPExtraTeams[teamid].model[1]
end

----------------------------------------------------------------------------------------------------------------------!]]
--! Panel Functions
----------------------------------------------------------------------------------------------------------------------!]]

local panel = FindMetaTable("Panel")

function panel:SetupDock(pos, marginLeft, marginTop, marginRight, marginBottom)
    self:Dock(pos)
    self:DockMargin(marginLeft or 0, marginTop or 0, marginRight or 0, marginBottom or 0)
end

function panel:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

----------------------------------------------------------------------------------------------------------------------!]]
--! SWEP Functions
----------------------------------------------------------------------------------------------------------------------!]]

local wep = FindMetaTable("Weapon")

TLib.Font("WepSelect", 20)

function wep:PrintWeaponInfo(x, y, alpha)
    if ( self.DrawWeaponInfoBox == false ) then return end

    if ( self.InfoMarkup == nil ) then
        local str
        local title_color = "<color=255, 255, 255>"
        local text_color = "<color=194, 194, 194>"
        local left_click = "<color=150, 150, 255>"
        local right_click = "<color=255, 150, 150>"
        local reload_click = "<color=150, 255, 150>"
        local reload_key = input.LookupBinding("+reload")


        str = "<font=TLib.Font.WepSelect>"
        if ( self.Author != "" ) then str = str .. title_color .. "Autor:</color>\t"..text_color..self.Author.."</color>\n" end
        if ( self.Contact != "" ) then str = str .. title_color .. "Kontakt:</color>\t"..text_color..self.Contact.."</color>\n\n" end
        if ( self.Purpose != "" ) then str = str .. title_color .. "Zweck:</color>\n"..text_color..self.Purpose.."</color>\n\n" end
        if ( self.Instructions != "" ) then str = str .. title_color .. "Anleitung:</color>\n"..text_color..self.Instructions.."</color>\n" end

        -- Include leftclick img & rightclick img
        -- if (self.Keys != "") then str = str .. "\n"..title_color.."Tasten:</color>\n"..text_color..self.Keys.."</color>" end
        if self.LeftClick then
            if (self.LeftClick != "") then str = str .. "\n"..left_click.."Linksklick:</color>\n"..text_color..self.LeftClick.."</color>" end
        end
        if self.RightClick then
            if (self.RightClick != "") then str = str .. "\n"..right_click.."Rechtsklick:</color>\n"..text_color..self.RightClick.."</color>" end
        end
        if self.ReloadClick then
            if (self.ReloadClick != "") then str = str .. "\n"..reload_click.."Nachladen:</color>\n"..text_color..self.ReloadClick.."</color>" end
        end

        str = str .. "</font>"

        self.InfoMarkup = markup.Parse( str, 250 )
    end

    -- draw.RoundedBox(0, x - 5, y - 140, 260, self.InfoMarkup:GetHeight() + 18, TLib.Theme.outline )
    -- TLib.DrawRoundedOutline(x - 5, y - 140, 260, self.InfoMarkup:GetHeight() + 18, TLib.Theme.outline, TLib.Theme.background)
    TLib.DrawOutlinedBox(nil, x - 5, y - 140, 260, self.InfoMarkup:GetHeight() + 18, TLib.Theme.outline, TLib.Theme.background)


    surface.SetDrawColor( TLib.Theme.accent)
    surface.DrawRect( x - 5, y - 140, 5, self.InfoMarkup:GetHeight() + 18 )

    
    self.InfoMarkup:Draw( x+5, y-130, nil, nil, alpha )
end

function wep:DrawWeaponSelection(x, y, wide, tall, alpha)
    if ( self.Icon ) then
        surface.SetDrawColor( 255, 255, 255, alpha )
        surface.SetMaterial( self.Icon )
        local size = math.min( wide, tall )
        surface.DrawTexturedRect( x + wide / 2 - size / 2, y, size, size )
        x = x + size + 20
        wide = wide - size - 20
    end

    draw.SimpleText( "self:GetPrintName()", "TLib.Font.WepSelect", x + wide / 2, y + tall * 0.2, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER )

    if ( self.Slot > 0 ) then
        draw.SimpleText( self.Slot + 1, "TLib.Font.WepSelect", x + wide - 20, y + tall - 14, Color( 255, 255, 255, alpha ), TEXT_ALIGN_RIGHT )
    end
end

----------------------------------------------------------------------------------------------------------------------!]]
--! Image Functions
----------------------------------------------------------------------------------------------------------------------!]]

local materials = {}
local queue = {}

local useProxy = false

local DownloadPath = "tlib/images/"

file.CreateDir(DownloadPath)

local function endsWithExtension(str)
    local fileName = str:match(".+/(.-)$")
    if not fileName then
        return false
    end
    local extractedExtension = fileName and fileName:match("^.+(%..+)$")

    return extractedExtension and string.sub(str, -#extractedExtension) == extractedExtension or false
end

local function processQueue()
    if queue[1] then
        local url, filePath, matSettings, callback = unpack(queue[1])

        http.Fetch((useProxy and ("https://proxy.duckduckgo.com/iu/?u=" .. url)) or url,
            function(body, len, headers, code)
                if len > 2097152 then
                    materials[filePath] = Material("nil")
                else
                    local writeFilePath = filePath
                    if not endsWithExtension(filePath) then
                        writeFilePath = filePath .. ".png"
                    end

                    file.Write(writeFilePath, body)
                    materials[filePath] = Material("../data/" .. writeFilePath, matSettings or "noclamp smooth mips")
                end

                callback(materials[filePath])
            end,
            function(error)
                if useProxy then
                    materials[filePath] = Material("nil")
                    callback(materials[filePath])
                else
                    useProxy = true
                    processQueue()
                end
            end
        )
    end
end

function TLib.GetImage(url, callback, matSettings)
    local protocol = url:match("^([%a]+://)")
    local urlWithoutProtocol = url
    if not protocol then
        protocol = "http://"
    else
        urlWithoutProtocol = string.gsub(url, protocol, "")
    end

    local fileNameStart = url:find("[^/]+$")
    if not fileNameStart then
        return
    end

    local urlWithoutFileName = url:sub(protocol:len() + 1, fileNameStart - 1)

    local dirPath = DownloadPath .. urlWithoutFileName
    local filePath = DownloadPath .. urlWithoutProtocol

    file.CreateDir(dirPath)

    local readFilePath = filePath
    if not endsWithExtension(filePath) and file.Exists(filePath .. ".png", "DATA") then
        readFilePath = filePath .. ".png"
    end

    if materials[filePath] then
        callback(materials[filePath])
    elseif file.Exists(readFilePath, "DATA") then
        materials[filePath] = Material("../data/" .. readFilePath, matSettings or "noclamp smooth mips")
        callback(materials[filePath])
    else
        table.insert(queue, {
            url,
            filePath,
            matSettings,
            function(mat)
                callback(mat)
                table.remove(queue, 1)
                processQueue()
            end
        })

        if #queue == 1 then
            processQueue()
        end
    end
end

local progressMat

local drawProgressWheel
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

do
    local min = math.min
    local curTime = CurTime
    local drawTexturedRectRotated = surface.DrawTexturedRectRotated

    function TLib.DrawProgressWheel(x, y, w, h, col)
        local progSize = min(w, h)
        setMaterial(progressMat)
        setDrawColor(col.r, col.g, col.b, col.a)
        drawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end
    drawProgressWheel = TLib.DrawProgressWheel
end

local materials = {}
local grabbingMaterials = {}

local getImage = TLib.GetImage
getImage("https://pixel-cdn.lythium.dev/i/47qh6kjjh", function(mat)
    progressMat = mat
end)

local drawTexturedRect = surface.DrawTexturedRect
function TLib.DrawImage(x, y, w, h, url, col)
    if not materials[url] then
        drawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRect(x, y, w, h)
end

local drawTexturedRectRotated = surface.DrawTexturedRectRotated
function TLib.DrawImageRotated(x, y, w, h, rot, url, col)
    if not materials[url] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x, y, w, h, rot)
end

----------------------------------------------------------------------------------------------------------------------!]]
--! NONAME
----------------------------------------------------------------------------------------------------------------------!]]
