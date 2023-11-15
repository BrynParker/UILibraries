
local branch = "master"
local rawUrl = "https://raw.githubusercontent.com/VoidTeam1/VoidLanguages/"
local apiEndpoint = "https://api.github.com/repos/VoidTeam1/VoidLanguages/git/trees/master?recursive=1"

VoidLib.Lang = VoidLib.Lang or {}

if (SERVER) then
    util.AddNetworkString("VoidLib.Lang.NetworkLocalLanguages")

    concommand.Add("voidlib_reloadlangs", function (ply, cmd, args)
        if (!ply:IsSuperAdmin()) then return end

        for k, v in pairs(VoidLib.Tracker.Addons) do
            local gTable = _G[k]
            if (!gTable) then continue end

            VoidLib.Lang:LoadLocalLanguages(k, true)

            if (table.Count(gTable.Lang.LocalLanguages) > 0) then
                VoidLib.Lang:NetworkLocalLanguages(k, gTable.Lang.LocalLanguages)
            end
        end

        VoidLib:Log("Successfully reloaded local languages!", "Languages")
    end)
end

if (CLIENT) then
    net.Receive("VoidLib.Lang.NetworkLocalLanguages", function ()
        local addon = net.ReadString()
        local tbl = VoidLib.ReadCompressedTable()

        local gTable = _G[addon]
        if (!gTable) then return end

        gTable.Lang.Langs = tbl

        gTable:Log("Received local languages from server!", "Languages")
    end)
end

function VoidLib.Lang:Init(addon, onlyLocal)

    local gTable = _G[addon]
    if (!gTable) then return end

    if (!gTable.Logging) then
        VoidLib.Logging:Inject(addon, VoidLib.Logging.AddonColors[addon])
    end

    if (addon == "VoidChar") then return end -- ignore voidchar, it has it's own language system

    gTable.Lang = gTable.Lang or {}
    gTable.Lang.Langs = gTable.Lang.Langs or {}
    gTable.Lang.AvailableLangs = gTable.Lang.AvailableLangs or {}

    function gTable.Lang.GetPhrase(phrase, x)
        return VoidLib.Lang:GetLangPhrase(addon, phrase, x)
    end

    -- We need to wait until first tick is called because of HTTP API not working yet
    hook.Add("Tick", "VoidLib.Lang.InitTick" .. addon, function ()
        
        hook.Remove("Tick", "VoidLib.Lang.InitTick" .. addon)

        if (onlyLocal) then
            gTable:Log("Dev environment detected, using only local languages!", "Languages")
            VoidLib.Lang:LoadLanguages(addon)
        else
            VoidLib.Lang:DownloadLanguages(addon, function (failed)
                if (failed) then
                    gTable:LogWarning("Failed to fetch available languages - using only local languages!", "Languages")
                end

                timer.Simple(2, function () -- Wait until files are written
                    VoidLib.Lang:LoadLanguages(addon)
                end)
            end)
        end
    end)
end

function VoidLib.Lang:GetAvailableLanguages(addon, callback, failCallback)
    local gTable = _G[addon]
    if (!gTable) then return end
    local url = apiEndpoint
    http.Fetch(url, function (body, size, headers, code)
        -- Success
        if (code != 200 or !body or body == "") then
            gTable:LogError("Couldn't get available languages - error code :code: (please try again later)", { code = code }, "Languages")
            return
        end

        local tbl = util.JSONToTable(body)
        if (!tbl or table.Count(tbl) < 1) then
            gTable:LogError("Couldn't parse available languages - no languages exist?", "Languages")
            return
        end

        local langs = {}
        for k, fileTbl in pairs(tbl.tree) do
            if (!string.StartWith(fileTbl.path, addon) or addon == fileTbl.path) then continue end

            local fileName = string.Replace(fileTbl.path, addon .. "/")
            if (fileName == ".gitkeep") then continue end

            local name = string.Replace(fileName, ".json", "")
            langs[#langs + 1] = name
        end

        callback(langs)

    end, function (err)
        -- Failure
        gTable:LogError("Couldn't get available languages - error: :err:", { err = err }, "Languages")
        failCallback()
    end)
end

function VoidLib.Lang:GetLangPhrase(addon, phrase, x)
    local gTable = _G[addon]
    if (!gTable) then return end

    local langRef = gTable.Config.Language
    if (!langRef) then
        gTable:LogError("Tried to get langauge phrase, but no selected language! Falling back to English.", "Languages")
        gTable.Config.Language = "English"

        return phrase
    end

    -- We don't want the reference
    local lang = string.lower(langRef)

    local langs = gTable.Lang.Langs
    if (!langs) then
        gTable:LogWarning("Langs table not initialized yet!", "Languages")
        return phrase
    end
    
    local returnVal = phrase
    if (langs[lang] and langs[lang][phrase]) then
        -- If the language has the phrase
        returnVal = langs[lang][phrase]
    elseif (langs["english"] and langs["english"][phrase]) then
        -- If not, fallback to english
        returnVal = langs["english"][phrase]
    end

    if (x) then
        returnVal = VoidLib.StringFormat(returnVal, x)
    end

    -- If no langauge has the phrase, return the phrase itself
    return returnVal
end

function VoidLib.Lang:IsLanguageInstalled(addon, lang)
    local langFile = "voidlanguages/" .. addon .. "/" .. lang .. ".json"
    return file.Exists(langFile, "DATA"), langFile
end

function VoidLib.Lang:IsLatest(addon, lang, newLang)
    local isInstalled, path = self:IsLanguageInstalled(addon, lang)
    if (!isInstalled) then return false, false end

    local langContent = file.Read(path)

    local existingLangCRC = util.CRC(langContent)
    local newLangCRC = util.CRC(newLang)

    return newLangCRC == existingLangCRC, true
end

function VoidLib.Lang:WriteLanguage(addon, lang, json)
    if (!file.Exists("voidlanguages", "DATA")) then
        file.CreateDir("voidlanguages")
    end

    if (!file.Exists("voidlanguages/" .. addon, "DATA")) then
        file.CreateDir("voidlanguages/" .. addon)
    end

    file.Write("voidlanguages/" .. addon .. "/" .. lang .. ".json", json)
end

function VoidLib.Lang:FlattenLanguageTable(tbl, res)
    if (type(tbl) != "table") then
        return tbl
    end

    if (res == nil) then
        res = {}
    end

    for k, v in pairs(tbl) do
        if (type(v) == "table") then
            local v = VoidLib.Lang:FlattenLanguageTable(v, {})
            for k2, v2 in pairs(v) do
                res[k .. "." .. k2] = v2
            end
        else
            res[k] = v
        end
    end

    return res
end

function VoidLib.Lang:LoadLocalLanguages(addon, reload)

    if (!SERVER) then return end

    local gTable = _G[addon]
    if (!gTable) then return end

    local files = file.Find("voidlanguages/" .. addon .. "/*.json", "DATA")
    local langs = {}
    for k, v in pairs(files) do

        local langName = string.Replace(v, ".json", "")
        if (!reload) then
            if (gTable.Lang.Langs[langName]) then continue end
        end

        local json = file.Read("voidlanguages/" .. addon .. "/" .. v)

        local tbl = util.JSONToTable(json)
        local length = table.Count(tbl or {})
        if (!tbl or length < 1) then
            gTable:LogError("Tried to load " .. v .. ", but langauge file is corrupt/empty!", "Languages")
            continue
        end

        gTable:LogDebug("Loaded :langName: local language! (:length: phrases)", { langName = langName, length = length }, "Languages")

        langs[langName] = VoidLib.Lang:FlattenLanguageTable(tbl)
    end



    gTable.Lang.LocalLanguages = langs


    VoidLib.Lang:NetworkLocalLanguages(addon, langs)

    local totalLangs = table.Count(langs) 
    if (totalLangs > 0) then
        table.Merge(gTable.Lang.Langs, langs)

        gTable:Log("Loaded :totalLangs: local languages!", { totalLangs = totalLangs }, "Languages")
    end
end

function VoidLib.Lang:NetworkLocalLanguages(addon, tbl, ply)
    if (!SERVER) then return end

    net.Start("VoidLib.Lang.NetworkLocalLanguages")
        net.WriteString(addon)
        VoidLib.WriteCompressedTable(tbl)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
    
end

function VoidLib.Lang:LoadLanguages(addon)

    local gTable = _G[addon]
    if (!gTable) then return end

    for _, lang in pairs(gTable.Lang.AvailableLangs or {}) do
        local langExists, langFile = self:IsLanguageInstalled(addon, lang)
        if (!langExists) then
            gTable:LogError("Tried to load :lang:, but langauge is not installed!", { lang = lang }, "Languages")
            continue
        end

        local json = file.Read(langFile)
        if (!json or json == "") then
            gTable:LogError("Tried to load :lang:, but langauge file is empty!", { lang = lang }, "Languages")
            continue
        end
        
        local tbl = util.JSONToTable(json)
        if (!tbl or table.Count(tbl) < 1) then
            gTable:LogError("Tried to load :lang:, but langauge file is corrupt/empty!", { lang = lang }, "Languages")
            continue
        end

        gTable.Lang.Langs[lang] = VoidLib.Lang:FlattenLanguageTable(tbl)

    end

    VoidLib.Lang:LoadLocalLanguages(addon)

    if (table.Count(gTable.Lang.Langs) < 1) then
        gTable:LogError("Tried to load languages, but none downloaded!", "Languages")
        return
    end

    gTable:Log("Loaded " .. table.Count(gTable.Lang.Langs) .. " languages!", "Languages")

    gTable.Lang.LanguagesLoaded = true
    hook.Run(addon .. ".Lang.LanguagesLoaded")
end

function VoidLib.Lang:DownloadLanguages(addon, callback)
    local gTable = _G[addon]
    if (!gTable) then return end


    self:GetAvailableLanguages(addon, function (languages)

        gTable.Lang.AvailableLangs = languages

        local callbacksDone = 0

        if (#languages == 0) then
            callback()
        end

        for _, lang in pairs(languages) do
            local formattedLangName = lang:gsub("^%l", string.upper)
            local url = rawUrl .. branch .. "/" .. addon .. "/" .. lang .. ".json"
            http.Fetch(url, function (body, size, headers, code)

                callbacksDone = callbacksDone + 1
            
                if (code != 200 or !body or body == "") then
                    gTable:LogError("Couldn't get " .. lang .. " language: " .. code .. " (please try again later)", "Languages")
                    if (callbacksDone == #languages) then
                        callback()
                    end
                    return
                end

                local tbl = util.JSONToTable(body)
                if (!tbl or table.Count(tbl) < 1) then
                    gTable:LogError("Couldn't parse language " .. lang .. " - incorrect or empty JSON!", "Languages")
                    if (callbacksDone == #languages) then
                        callback()
                    end
                    return
                end

                local isLatest, isUpdating = VoidLib.Lang:IsLatest(addon, lang, body)
                if (!isLatest) then
                    local operationString = isUpdating and "Updated" or "Downloaded"
                    gTable:Log(operationString .. " " .. formattedLangName .. " language", "Languages")

                    self:WriteLanguage(addon, lang, body)
                elseif (gTable.Debug) then
                    gTable:LogDebug(formattedLangName .. " language is up to date!", "Languages")
                end

                if (callbacksDone == #languages) then
                    callback()
                end
                

            end, function (err)
                gTable:LogError("Couldn't download " .. lang .. " language - error: " .. err, "Languages")
            end)
        end

    end, function ()
        -- Failed
        callback(true)
    end)
end
