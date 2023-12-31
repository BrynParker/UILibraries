CreateClientConVar("xenin_debug_print_file_enabled", "1", true, false)
CreateClientConVar("xenin_debug_print_console_enabled", "0", true, false)

function XeninUI:HasDebugFilePrintEnabled()
  return GetConVar("xenin_debug_print_file_enabled"):GetBool() or ply:IsSuperAdmin()
end

function XeninUI:HasDebugConsolePrintEnabled()
  return GetConVar("xenin_debug_print_console_enabled"):GetBool()
end

function XeninUI:EnsureDebugFileExists()
  local ply = LocalPlayer()

  local path = self.debugPath or "xenin/debug/"
  local time = os.time()
  local date = os.date("%d_%m_%Y_%H_%M_%S", time)
  local realPath = path .. date .. ".txt"

  if (!file.IsDir(path, "DATA")) then
    file.CreateDir(path)
  end

  if (!file.Exists(realPath, "DATA")) then
    local str = "Debug log for " .. ply:Nick() .. " [" .. ply:SteamID() .. "] initialised at " .. os.date("%d/%m/%Y %H:%M:%S", time) .. "\n"
    file.Write(realPath, str)

    ply.debug = realPath
  end
end

hook.Add("InitPostEntity", "XeninUI.Debug", function()
  XeninUI:EnsureDebugFileExists()
end)

function XeninUI:DebugPrint(prefix, ...)
  local rawPrefix = prefix
  local args = {
  ... }
  local ply = LocalPlayer()
  local printEnabled = XeninUI:HasDebugConsolePrintEnabled()
  local fileEnabled = XeninUI:HasDebugFilePrintEnabled()

  if (!printEnabled and !fileEnabled) then return end
  local path = ply.debug
  if (!path) then print("ERROR AT DEBUG PRINT")end
  local time = os.time()
  local date = os.date("%H:%M:%S", time)
  prefix = "[" .. prefix:upper() .. " ENTRANCE AT " .. date .. "]"

  local str = prefix .. "\n	-	"

  for i, v in ipairs(args) do
    if istable(v) then
      local json = util.TableToJSON(v, true)
      local exploded = string.Explode("\n", json)

      for i, v in ipairs(exploded) do
        if (i == 1) then continue end

        exploded[i] = "	-	" .. v
      end

      json = table.concat(exploded, "\n")
      str = str .. "Table: " .. json .. "\n	- "

      continue
    end

    str = str .. v .. "\n	-	"
  end
  str = str:sub(1, str:len() - 3)

  if fileEnabled then
    file.Append(path, str)
  end

  if printEnabled then
    ply.debugTbl = ply.debugTbl or {}
    ply.debugTbl[rawPrefix] = ply.debugTbl[rawPrefix] or {}

    table.insert(ply.debugTbl[rawPrefix], {
      time = CurTime(),
      str = str
    })
  end
end

function XeninUI:DebugQuery(prefix, secs)
  if (!prefix) then
    print("You need a category!")

    return
  end

  secs = secs or 300

  local ply = LocalPlayer()
  if (!ply.debugTbl) then
    print("No debug info at all")

    return
  end
  if (!ply.debugTbl[prefix]) then
    print("No debug info for " .. prefix)

    return
  end

  local tbl = ply.debugTbl[prefix]
  local size = #tbl

  if (size == 0) then
    print("The category exists, but there's no info")

    return
  end

  local curTime = CurTime() - secs
  local infoTbl = {}

  for i = size, 1, -1 do
    if (tbl[i] and tbl[i].time > curTime) then
      table.insert(infoTbl, tbl[i])

      continue
    end

    break
  end

  return infoTbl
end

concommand.Add("xenin_debug_query", function(ply, cmd, args)
  local prefix = args[1]
  local secs = args[2]
  local tbl = XeninUI:DebugQuery(args[1], args[2])

  if tbl then
    local str = ""

    for i, v in ipairs(tbl) do
      str = str .. v.str .. "\n"

      if (i == #tbl) then str = str:sub(1, str:len() - 2)end
    end

    print(str)
    MsgC(XeninUI.Theme.Accent, "Results: ")
    MsgC(XeninUI.Theme.Green, #tbl .. "\n")
  end
end)
