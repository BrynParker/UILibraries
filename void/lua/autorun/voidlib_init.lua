
--[[---------------------------------------------------------
	Name: Setup
-----------------------------------------------------------]]
VoidLib = VoidLib or {}
VoidUI = VoidUI or {}

VoidLib.Dir = "voidlib"
VoidLib.Debug = false

VoidLib.Version = "1.0.0"

--[[---------------------------------------------------------
	Name: Main
-----------------------------------------------------------]]
function VoidLib.Load(dir)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		if string.StartWith(v, "cl") then

			AddCSLuaFile(dir.. "/".. v)

			if CLIENT then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sv") then
			if SERVER then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sh") then

			AddCSLuaFile(dir.. "/".. v)

			local load = include(dir.. "/".. v)
			if load then load() end
		end
	end
end

function VoidLib.AddCSDir(dir)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		AddCSLuaFile(dir.. "/".. v)

		if CLIENT then
			include(dir.. "/".. v)
		end
	end
end

--[[---------------------------------------------------------
	Name: Functions
-----------------------------------------------------------]]
function VoidLib.PrintError(...)
	MsgC(Color(120, 255, 120), "[VoidLib] (ERROR): ", Color(255, 255, 255), ..., "\n")
end

function VoidLib.PrintDebug(...)
	if (!VoidLib.Debug) then return end

	MsgC(Color(120, 255, 120), "[VoidLib] (DEBUG): ", Color(255, 255, 255), ..., "\n")
end

function VoidLib.Print(...)
	MsgC(Color(255, 120, 120), "[VoidLib]: ", Color(255, 255, 255), ..., "\n")
end

--[[---------------------------------------------------------
	Name: Loading
-----------------------------------------------------------]]

VoidLib.Load(VoidLib.Dir)
VoidLib.AddCSDir(VoidLib.Dir.. "/vgui")
hook.Run("VoidLib.Loaded")