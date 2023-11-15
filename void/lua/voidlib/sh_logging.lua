VoidLib.Logging = VoidLib.Logging or {}
VoidLib.Logging.InjectedAddons = VoidLib.Logging.InjectedAddons or {}

VoidLib.Logging.AddonColors = {
    ["VoidCases"] = Color(210, 153, 38),
    ["VoidFactions"] = Color(66, 170, 70)
}

local LOG_KEEP_PERIOD = 60 * 60 * 48

CreateConVar("voidlib_logging_enable", SERVER and 1 or 0, FCVAR_NONE, "Enables logging for VoidLib.", 0, 1)
CreateConVar("voidlib_logging_savetofile", 0, FCVAR_NONE, "Commits logs to files.", 0, 1)
CreateConVar("voidlib_logging_commitinterval", 60, FCVAR_NONE, "The interval between file writes if savetofile is enabled. Server restart is required.", 1, 3600)

function VoidLib.Logging:Init(strAddon, tblAddon)
    local strDate = os.date("%Y-%m-%d")
    if (file.Exists("voidlib/persistent_logs/" .. strAddon .. "/" .. strDate .. ".dat", "DATA")) then
        local strData = file.Read("voidlib/persistent_logs/" .. strAddon .. "/" .. strDate .. ".dat")
        local tblDat = util.JSONToTable(strData)

        for k, v in ipairs(tblDat) do
            if (os.time() < v.time + LOG_KEEP_PERIOD) then
                table.insert(tblAddon.Logging.Logs, v)
            end
        end

        tblAddon:Log("Loaded previous persistent logs (:logCount:) from today (:date:)", {
            date = strDate,
            logCount = #tblDat
        }, "Logging")
    end
end

function VoidLib.Logging:CommitToDisk(bShutdown)
    -- Create a table that stores all data
    for strAddon, tblGlobal in pairs(VoidLib.Logging.InjectedAddons) do
        VoidLib:LogDebug("Commiting logs of :addon: to disk...", { addon = strAddon }, "Logging")

        if (bShutdown) then
            file.CreateDir("voidlib/persistent_logs")
            file.CreateDir("voidlib/persistent_logs/" .. strAddon)

            local strDate = os.date("%Y-%m-%d")
            file.Write("voidlib/persistent_logs/" .. strAddon .. "/" .. strDate .. ".dat", util.TableToJSON(tblGlobal.Logging.Logs))
            
            local tblFiles = file.Find("*.dat", "voidlib/persistent_logs/" .. strAddon)
            for k, v in pairs(tblFiles) do
                if (strDate .. ".dat" != v) then
                    file.Delete("voidlib/persistent_logs/" .. strAddon .. "/" .. v)
                end
            end
        else
            if (!GetConVar("voidlib_logging_savetofile"):GetBool() and !tblGlobal.Debug) then return end
            file.CreateDir("voidlib/logs/" .. strAddon)

            local strTime = os.date("%Y-%m-%d")
            local strFormat = VoidLib.Logging:FormatReadLogs(tblGlobal, true)

            file.Append("voidlib/logs/" .. strAddon .. "/" .. strTime .. ".txt", strFormat)
        end

        VoidLib:LogDebug("Commited logs of :addon: to disk!", { addon = strAddon }, "Logging")
    end
end

function VoidLib.Logging:FormatReadLogs(tblGlobal, bAllData)
    local strFormat = ""
    for k, v in pairs(tblGlobal.Logging.Logs) do
        local strFormatted = tblGlobal.Logging:FormatLog(v)
        if (bAllData) then
            strFormat = strFormat .. string.format("%s | [%s]: <%s> %s (%s:%s)", os.date("%d-%m-%Y %H:%M:%S", v.time), v.type:upper(), v.scope, VoidLib.StringFormat(v.log, v.args), v.src, v.line) .. "\n"
        else
            strFormat = strFormat .. string.format("%s | [%s]: <%s> %s", os.date("%d-%m-%Y %H:%M:%S", v.time), v.type:upper(), v.scope, VoidLib.StringFormat(v.log, v.args)) .. "\n"
        end
    end

    return strFormat
end

function VoidLib.Logging:Inject(strAddonGlobal, colLogColor)
    colLogColor = colLogColor or VoidUI.Colors.Blue

    local tblAddonGlobal = _G[strAddonGlobal]
    if (!tblAddonGlobal) then
        VoidLib.PrintError("Tried to inject logs to " .. strAddonGlobal .. ", which does not exist!")
        return
    end

    if (tblAddonGlobal.Logging and strAddonGlobal != "VoidLib") then return end

    VoidLib.Print("[Logging] Injecting log system to " .. strAddonGlobal)

    VoidLib.Logging.InjectedAddons[strAddonGlobal] = tblAddonGlobal

    tblAddonGlobal.Logging = tblAddonGlobal.Logging or {}
    tblAddonGlobal.Logging.Logs = {}
    tblAddonGlobal.Logging.Color = colLogColor

    function tblAddonGlobal.Logging:PrintLog(tblLog)
        MsgC(self.Color, string.format("[%s] ", strAddonGlobal), Color(0, 255, 255), string.format("[%s] ", tblLog.scope), self:GetTypeColor(tblLog.type), string.format("[%s] ", tblLog.type:upper()), VoidUI.Colors.White, unpack(tblLog.formattedLog))
    end

    function tblAddonGlobal.Logging:FormatLog(tblLog)
        local tblVarArgs = {}
        local intPrevStartPos = 1

        for k in string.gmatch(tblLog.log, ":[%w_]+:") do
            local intPos, intEndPos = string.find(tblLog.log, k, 1, true)

            local strSub = tblLog.log:sub(intPrevStartPos, intPos - 1)
            table.insert(tblVarArgs, strSub)

            local strKey = k:gsub(":", "")
            local strValue = tblLog.args[strKey] or "N/A"

            -- This is the log variable itself
            table.insert(tblVarArgs, VoidUI.Colors.Gold)
            table.insert(tblVarArgs, strValue)
            table.insert(tblVarArgs, VoidUI.Colors.White)

            intPrevStartPos = intEndPos + 1
        end

        table.insert(tblVarArgs, tblLog.log:sub(intPrevStartPos))
        table.insert(tblVarArgs, "\n")
        return tblVarArgs
    end

    function tblAddonGlobal.Logging:ConvertArgs(tblArgs)
        for k, strValue in pairs(tblArgs) do
            if (istable(strValue)) then
                strValue = table.ToString(strValue)
            end

            if (IsEntity(strValue)) then
                if (strValue:IsPlayer()) then
                    strValue = string.format("%s", strValue:Nick())
                end
            end

            tblArgs[k] = strValue
        end

        return tblArgs
    end

    function tblAddonGlobal.Logging:GetTypeColor(strType)
        local tblColors = {
            ["info"] = Color(0, 255, 255),
            ["error"] = Color(255, 0, 0),
            ["debug"] = Color(255, 0, 255),
            ["warning"] = Color(255, 255, 0)
        }

        return tblColors[strType]
    end

    function tblAddonGlobal.Logging:Log(strText, xFirst, xSecond, strType, bIsPrint)
        if (!GetConVar("voidlib_logging_enable"):GetBool()) then return end

        local tblArgs = {}
        local strName = "Generic"

        if (xFirst and istable(xFirst)) then
            tblArgs = xFirst
        end

        if (xFirst and isstring(xFirst)) then
            strName = xFirst
        end

        if (xSecond and xFirst and istable(xFirst)) then
            strName = xSecond
        end

        tblArgs = self:ConvertArgs(tblArgs)

        local tblDebugInfo = debug.getinfo(bIsPrint and 3 or 2)
        local tblLog = {
            src = tblDebugInfo.short_src,
            line = tblDebugInfo.currentline,

            log = strText,
            args = tblArgs,
            scope = strName,

            time = os.time(),
            type = strType,
        }

        local tblFormatted = self:FormatLog(tblLog)
        tblLog.formattedLog = tblFormatted
        
        if (strType != "debug" or tblAddonGlobal.Debug) then
            self:PrintLog(tblLog)
        end

        table.insert(tblAddonGlobal.Logging.Logs, tblLog)
    end

    function tblAddonGlobal.Logging:LogInfo(strText, xFirst, xSecond, bPrint)
        return self.Logging:Log(strText, xFirst, xSecond, "info", bPrint)
    end

    function tblAddonGlobal.Logging:LogDebug(strText, xFirst, xSecond, bPrint)
        return self.Logging:Log(strText, xFirst, xSecond, "debug", bPrint)
    end

    function tblAddonGlobal.Logging:LogError(strText, xFirst, xSecond, bPrint)
        return self.Logging:Log(strText, xFirst, xSecond, "error", bPrint)
    end

    function tblAddonGlobal.Logging:LogWarning(strText, xFirst, xSecond, bPrint)
        return self.Logging:Log(strText, xFirst, xSecond, "warning", bPrint)
    end

    tblAddonGlobal.Log = tblAddonGlobal.Logging.LogInfo
    tblAddonGlobal.LogInfo = tblAddonGlobal.Logging.LogInfo
    tblAddonGlobal.LogWarning = tblAddonGlobal.Logging.LogWarning
    tblAddonGlobal.LogDebug = tblAddonGlobal.Logging.LogDebug
    tblAddonGlobal.LogError = tblAddonGlobal.Logging.LogError

    local function varArgsToString(...)
        local str = ""
        for k, v in pairs({...}) do
            if (isstring(v)) then
                str = str .. v
            end
        end
        return str
    end

    function tblAddonGlobal.Print(...)
        tblAddonGlobal:LogInfo(varArgsToString(...), nil, nil, true)
    end

    function tblAddonGlobal.PrintError(...)
        tblAddonGlobal:LogError(varArgsToString(...), nil, nil, true)
    end

    function tblAddonGlobal.PrintDebug(...)
        tblAddonGlobal:LogDebug(varArgsToString(...), nil, nil, true)
    end

    VoidLib.Print("[Logging] Successfully injected log system to " .. strAddonGlobal)

    VoidLib.Logging:Init(strAddonGlobal, tblAddonGlobal)

    if (tblAddonGlobal.Debug) then
        tblAddonGlobal:LogWarning("Debug mode is enabled - logs will be saved. If you encounter any performance issues, disable Debug mode.", "Logging")
    end

    local tblDebugInfo = debug.getinfo(2)
    tblAddonGlobal:LogDebug("Logging injected from file :file:::line:", { file = tblDebugInfo.short_src, line = tblDebugInfo.currentline }, "Logging")
end

file.CreateDir("voidlib")
file.CreateDir("voidlib/logs")
timer.Create("VoidLib.Logging.LogFileCommiter", GetConVar("voidlib_logging_commitinterval"):GetInt(), 0, function ()
    VoidLib.Logging:CommitToDisk()
end)

hook.Add("ShutDown", "VoidLib.Logging.WriteLogDataToFile", function ()
    VoidLib:Log("Commiting persistent logs to disk...", "Logging")
    VoidLib.Logging:CommitToDisk(true)
    VoidLib:Log("Commited logs to disk! Bye!", "Logging")
end)

-- Inject logs for ourselves :D
VoidLib.Logging:Inject("VoidLib", Color(255, 0, 255))

hook.Add("InitPostEntity", "VoidLib.Logging.BackwardsCompatibility", function ()
    -- Inject older addons automatically! (if they are installed)
    if (VoidCases) then
        VoidLib.Logging:Inject("VoidCases", VoidLib.Logging.AddonColors["VoidCases"])
    end

    if (VoidFactions) then
        VoidLib.Logging:Inject("VoidFactions", VoidLib.Logging.AddonColors["VoidFactions"])
    end
end)