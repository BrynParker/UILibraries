-- E SCRIPTS LIB
esclib = esclib or {}
esclib.ownloader = {}

------------------------
/// LOADER FUNCTIONS ///
------------------------

local epath = "elib/" 

if (SERVER) then
MsgC(Color(5,255,197), "@ esclib [Loading started]\n\n")
end

function esclib.ownloader:IncludeClient(path)
	if (CLIENT) then
		include(epath .. path)
	end

	if (SERVER) then
		AddCSLuaFile(epath .. path)
		MsgC(Color(13, 255, 51), "• ")
		print(epath .. path)
	end
end

function esclib.ownloader:IncludeServer(path)
	if (SERVER) then
		include(epath .. path)
		MsgC(Color(13, 255, 51), "• ")
		print(epath .. path)
	end
end

function esclib.ownloader:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
end

function esclib.ownloader:ResourceAddFile(path)
	if (SERVER) then
		resource.AddFile(path)
		MsgC(Color(13, 255, 51), "• ")
		print("Resource added to loader: ( ".. path.." )")
	end
end

function esclib.ownloader:ResourceAddFolder(name, recurse)
    local files, folders = file.Find(name .."/*", "GAME")

    for _, fname in ipairs(files) do
        self:ResourceAddFile(name .."/".. fname)
    end

    if recurse then
        for _, fname in ipairs(folders) do
            esclib.ownloader:ResourceAddFolder(name .."/".. fname, recurse)
        end
    end
end

esclib.Materials = {}
function esclib.ownloader:MaterialAddFolder(name, recurse)
    local files, folders = file.Find(name .."/*", "GAME")

    for _, fname in ipairs(files) do
        self:ResourceAddFile(name .."/".. fname)
        esclib.Materials[fname] = Material(name .."/".. fname,"smooth")
    end

    if recurse then
        for _, fname in ipairs(folders) do
            esclib.ownloader:MaterialAddFolder(name .."/".. fname, recurse)
        end
    end
end

function esclib.ownloader:ClAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeClient(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ClAddFolder(name .."/".. fname, recurse)
        end
    end
end

function esclib.ownloader:SvAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeServer(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:SvAddFolder(name .."/".. fname, recurse)
        end
    end
end

function esclib.ownloader:ShAddFolder(name,recurse)
	local files, folders = file.Find(epath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		local path = name.."/"..fname
		self:IncludeShared(path)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ShAddFolder(name .."/".. fname, recurse)
        end
    end
end



-----------------
/// MAIN LOAD ///
-----------------

-- MAIN LOAD FUNCTION
function esclib.ownloader:Load()
	timer.Simple(0,function() --because globals not working 

		self.finished = false

		self:ResourceAddFile("resource/fonts/amsterdam.ttf")
		self:MaterialAddFolder("materials/esclib",true)-- CHANGE TRUE - FALSE

		--CORE files 1. SubAddons structure must be (addon creation > config > languages)
		self:IncludeClient("essentials/esc_utils.lua")
		self:IncludeClient("essentials/esc_draw.lua")
		self:IncludeShared("essentials/esc_files.lua")
		self:IncludeServer("essentials/esc_server.lua")
		self:IncludeShared("essentials/esc_addons_core.lua")
		self:IncludeShared("essentials/esc_load_manager.lua")

		--CORE files 2
		self:IncludeClient("essentials/esc_fonts.lua")
		self:IncludeClient("essentials/esc_vgui.lua")

		--PANELS
		self:ClAddFolder("vgui",true)

		--OTHER
		self:IncludeShared("essentials/esc_settings_types.lua")
		self:IncludeClient("essentials/esc_settings_default_tabs.lua")
		self:IncludeClient("essentials/esc_settings_menu.lua")
		self:IncludeShared("essentials/esc_settings_wrapper.lua")

		--CONFIG files
		self:IncludeShared("config/esc_meta.lua")
		self:IncludeClient("config/esc_theme.lua")
		self:IncludeShared("config/esc_config.lua")
		self:IncludeShared("config/esc_languages.lua")
		
		-- esclib.addon:PerformSettings() --SaveSettings

		if (SERVER) then
			MsgC(Color(30,235,157), "\n@ esclib [Loading finished]\n")
			MsgC(Color(30,235,157), "\nLoading dependent addons...\n")
		end

		self.finished = true
		hook.Run("esclib_loaded",esclib) 

		esclib.loader:LoadAllAddons()

	end)

	--Context menu button
	hook.Add("ContextMenuCreated","esclib.context_button",function(context)
		list.Add( "DesktopWindows", {
			title = "ESettings",
			icon = "materials/esclib/esclib_logo.png",
			init = function(icon, window)
				RunConsoleCommand("esettings")
			end
		})
	end)

end

esclib.ownloader:Load()


concommand.Add("esclib_restart",function()
	if esclib.ownloader.finished then
		esclib.ownloader:Load()
	end
end)