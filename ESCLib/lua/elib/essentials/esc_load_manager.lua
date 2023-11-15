esclib.loader = esclib.loader or {}
esclib.loader.addons = esclib.loader.addons or {}


local loader_meta = {}
function loader_meta:Print(msg)
	-- MsgC(Color(13, 255, 51), "• ")
	-- print(msg)
end

function loader_meta:Client(path)
	if (CLIENT) then include(self.dpath .. path) end
	if (SERVER) then
		AddCSLuaFile(self.dpath .. path)
		self:Print(self.dpath .. path)
	end
end

function loader_meta:ClientFolder(name,recurse)
	local files, folders = file.Find(self.dpath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		self:Client(name.."/"..fname)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ClientFolder(name .."/".. fname, recurse)
        end
    end
end

function loader_meta:Server(path)
	if (SERVER) then
		include(self.dpath .. path)
		self:Print(self.dpath .. path)
	end
end

function loader_meta:ServerFolder(name,recurse)
	local files, folders = file.Find(self.dpath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		self:Server(name.."/"..fname)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:ServerFolder(name .."/".. fname, recurse)
        end
    end
end

function loader_meta:Shared(path)
	self:Client(path)
	self:Server(path)
end

function loader_meta:SharedFolder(name,recurse)
	local files, folders = file.Find(self.dpath .. name .. "/*", "LUA")
	for k, fname in ipairs(files) do
		self:Shared(name.."/"..fname)
	end
	if recurse then
		for _, fname in ipairs(folders) do
            self:SharedFolder(name .."/".. fname, recurse)
        end
    end
end

function loader_meta:Resource(fullpath)
	if (SERVER) then
		resource.AddFile(fullpath)
		self:Print("Resource added to loader: ( ".. fullpath.." )")
	end
end

function loader_meta:ResourceFolder(fullpath, recurse)
    local files, folders = file.Find(fullpath .."/*", "GAME")

    for _, fname in ipairs(files) do
        self:Resource(fullpath .."/".. fname)
    end

    if recurse then
        for _, fname in ipairs(folders) do
            self:ResourceFolder(fullpath .."/".. fname, recurse)
        end
    end
end

function loader_meta:Material(fullpath, name, download)
	if (CLIENT) then
		local mat = Material(fullpath,"smooth")
		if name then
			self.Materials[name] = mat
		else
			table.insert(self.Materials, mat)
		end
		return mat
	end

	if (SERVER) and (download) then
		resource.AddFile(fullpath)
		self:Print("Material added to loader: ( ".. fullpath.." )")
	end
end

function loader_meta:MaterialFolder(fullpath, recurse, download)
    local files, folders = file.Find(fullpath .."/*", "GAME")

    for _, fname in ipairs(files) do
        self:Material(fullpath .."/".. fname, fname, download)
    end

    if recurse then
        for _, fname in ipairs(folders) do
            self:MaterialFolder(fullpath .."/".. fname, recurse, download)
        end
    end
end




function esclib.loader:New(uid,path,callback)
	if not uid then return end
	if not path then return end
	if not callback then
		callback = path
		path = ""
	end
	if not isfunction(callback) then return end

	-- if already exists:
	if self.addons[uid] then 
		self.addons[uid]["Materials"] = {}
		self.addons[uid]["dpath"] = path
		self.addons[uid]["Load"] = function(add)
			add.finished = false
			callback(add)
			add.finished = true
		end

		table.Merge(self.addons[uid], loader_meta)

		self.addons[uid]:Load()
		return
	end

	--else
	self.addons[uid] = {}
	self.addons[uid]["Materials"] = {}
	self.addons[uid]["dpath"] = path
	self.addons[uid]["Load"] = function(add)
		add.finished = false
		callback(add)
		add.finished = true
	end

	table.Merge(self.addons[uid], loader_meta)
	self.addons[uid]:Load()
	-- setmetatable(self.addons[uid], loader_meta)

end

function esclib.loader:LoadAllAddons()
	for uid,addon in pairs(self.addons) do
		addon:Load()
	end
end


-- esclib.loader:New("ehud","ehud/",function(load)
-- 	-- PrintTable(loader)
-- 	load:Client("config/ehud_config.lua")
-- end)

-- esclib.loader:LoadAllAddons()