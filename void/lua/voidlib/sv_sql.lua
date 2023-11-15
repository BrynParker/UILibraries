--[[
	VoidLib.Database - 1.0.3
	A simple database wrapper for Garry's Mod.
	
    Made by
    Alexander Grist-Hucker
	http://www.alexgrist.com

    Modified by m0uka
--]]

local UTF8MB4 = "ALTER DATABASE %s CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"

VoidLib.Database = VoidLib.Database or {}

local DATABASE_CLASS = {}
DATABASE_CLASS.__index = DATABASE_CLASS

function DATABASE_CLASS:New(tblAuth)
	if (!tblAuth) then return end

	local newObject = setmetatable({}, DATABASE_CLASS)
	newObject.tblAuth = {
		host = tblAuth.host,
		username = tblAuth.username,
		password = tblAuth.password,
		database = tblAuth.database,
		port = tblAuth.port,
		socket = nil,
		flags = nil
	}

	newObject.module = tblAuth.useMySQL and "mysqloo" or "sqlite"
	return newObject
end

function DATABASE_CLASS:Connect()
	local host, username, password, database, port, module = self.tblAuth.host, self.tblAuth.username, self.tblAuth.password, self.tblAuth.database, self.tblAuth.port, self.module
	port = port or 3306

	if (module == "mysqloo") then
		if (!istable(mysqloo)) then
			require("mysqloo")
		end

		if (mysqloo) then
			if (self.connection and self.connection:ping()) then
				return
			end

			local clientFlag = flags or 0

			if (!isstring(socket)) then
				self.connection = mysqloo.connect(host, username, password, database, port)
			else
				self.connection = mysqloo.connect(host, username, password, database, port, socket, clientFlag)
			end

			self.connection.onConnected = function(connection)
		        local success, error_message = connection:setCharacterSet("utf8mb4")

		        if (!success) then
					ErrorNoHalt("Failed to set MySQL encoding!\n")
					ErrorNoHalt(error_message .. "\n")
				else
					self:RawQuery(string.format(UTF8MB4, database))
		        end

				self:OnConnected()
			end

			self.connection.onConnectionFailed = function(database, errorText)
				self:OnConnectionFailed(errorText)

				-- Try to reconnect
				MsgC(Color(87, 180, 242), "[VoidLib] [SQL]", Color(214, 235, 25), " Couldn't connect to the MySQL database, retrying in 5 seconds...\n")

				timer.Simple(5, function ()
					if (!self:IsConnected()) then
						MsgC(Color(87, 180, 242), "[VoidLib] [SQL]", Color(214, 235, 25), " Couldn't connect to the MySQL database, reconnecting...\n")
						self:Connect()
					end
				end)
			end

			self.connection:connect()
		else
			ErrorNoHalt(string.format(MODULE_NOT_EXIST, module))
		end
	elseif (module == "sqlite") then
		timer.Simple(0, function ()
			self:OnConnected()
		end)
	end
end

-- Supposed to be overriden
function DATABASE_CLASS:OnConnected()
	MsgC(Color(87, 180, 242), "[VoidLib] [SQL]", Color(25, 235, 25), " Connected to the database!\n")
end

-- Supposed to be overriden
function DATABASE_CLASS:OnConnectionFailed(strError)
	ErrorNoHalt(string.format("[VoidLib SQL] Unable to connect to the database!\n%s\n", errorText))
end

function VoidLib.Database:Create(tblAuth)
	return DATABASE_CLASS:New(tblAuth)
end

local QueueTable = {}
local tostring = tostring
local table = table

--[[
	Replacement tables
--]]

local Replacements = {
	sqlite = {
		Create = {
			{"UNSIGNED ", ""},
			{"NOT NULL AUTO_INCREMENT", ""}, -- assuming primary key
			{"AUTO_INCREMENT", ""},
			{"INT%(%d*%)", "INTEGER"},
			{"INT ", "INTEGER"}
		}
	}
}

--[[
	Phrases
--]]

local MODULE_NOT_EXIST = "[VoidLib SQL] The %s module does not exist!\n"

--[[
	Begin Query Class.
--]]

local QUERY_CLASS = {}
QUERY_CLASS.__index = QUERY_CLASS

function QUERY_CLASS:New(tableName, queryType, dbInstance)
	local newObject = setmetatable({}, QUERY_CLASS)
		newObject.queryType = queryType
		newObject.tableName = tableName
		newObject.selectList = {}
		newObject.groupList = {}
		newObject.insertList = {}
		newObject.updateList = {}
		newObject.createList = {}
		newObject.whereList = {}
		newObject.orderByList = {}
        newObject.joinList = {}
		newObject.indexList = {}
		newObject.instance = dbInstance

		newObject.whereOr = false
	return newObject
end

function QUERY_CLASS:Escape(text)
	return self.instance:Escape(tostring(text))
end

function QUERY_CLASS:ForTable(tableName)
	self.tableName = tableName
end

function QUERY_CLASS:Where(key, value, isOr)
	self:WhereEqual(key, value, isOr)
end

function QUERY_CLASS:InnerJoin(tbl1, tbl2, key, value)
    self.joinList[#self.joinList + 1] = " INNER JOIN " .. tbl2 .. " ON " .. tbl2 .. "." .. value .. " = " .. tbl1 .. "." .. key .. ""
end

function QUERY_CLASS:LeftJoin(tbl1, tbl2, key, value)
    self.joinList[#self.joinList + 1] = " LEFT JOIN " .. tbl2 .. " ON " .. tbl2 .. "." .. value .. " = " .. tbl1 .. "." .. key .. ""
end

function QUERY_CLASS:RightJoin(tbl1, tbl2, key, value)
    self.joinList[#self.joinList + 1] = " RIGHT JOIN " .. tbl2 .. " ON " .. tbl2 .. "." .. value .. " = " .. tbl1 .. "." .. key .. ""
end

function QUERY_CLASS:WhereEqual(key, value, isOr)
	self.whereOr = isOr or false
	self.whereList[#self.whereList + 1] = ""..key.." = '"..self:Escape(value).."'"
end

function QUERY_CLASS:WhereNotEqual(key, value, isOr)
	self.whereOr = isOr or false
	self.whereList[#self.whereList + 1] = ""..key.." != '"..self:Escape(value).."'"
end

function QUERY_CLASS:WhereLike(key, value, format)
	format = format or "%%%s%%"
	self.whereList[#self.whereList + 1] = ""..key.." LIKE '"..string.format(format, self:Escape(value)).."'"
end

function QUERY_CLASS:WhereNotLike(key, value, format)
	format = format or "%%%s%%"
	self.whereList[#self.whereList + 1] = ""..key.." NOT LIKE '"..string.format(format, self:Escape(value)).."'"
end

function QUERY_CLASS:WhereGT(key, value)
	self.whereList[#self.whereList + 1] = ""..key.." > '"..self:Escape(value).."'"
end

function QUERY_CLASS:WhereLT(key, value, noEscape)
	local val = "'" .. self:Escape(value) .. "'"
	if (noEscape) then
		val = value
	end
	self.whereList[#self.whereList + 1] = ""..key.." < ".. val
end

function QUERY_CLASS:WhereGTE(key, value)
	self.whereList[#self.whereList + 1] = ""..key.." >= '"..self:Escape(value).."'"
end

function QUERY_CLASS:WhereLTE(key, value)
	self.whereList[#self.whereList + 1] = ""..key.." <= '"..self:Escape(value).."'"
end

function QUERY_CLASS:WhereIn(key, value)
	value = istable(value) and value or {value}

	local values = ""
	local bFirst = true

	for k, v in pairs(value) do
		values = values .. (bFirst and "" or ", ") .. self:Escape(v)
		bFirst = false
	end

	self.whereList[#self.whereList + 1] = ""..key.." IN ("..values..")"
end

function QUERY_CLASS:OrderByDesc(key, noEscape)
	self.orderByList[#self.orderByList + 1] = (!noEscape and ""..key.." DESC") or key .. " DESC"
end

function QUERY_CLASS:OrderByAsc(key)
	self.orderByList[#self.orderByList + 1] = ""..key.." ASC"
end

function QUERY_CLASS:Callback(queryCallback)
	self.callback = queryCallback
end

function QUERY_CLASS:Select(fieldName, noEscape)
	self.selectList[#self.selectList + 1] = (noEscape and fieldName) or ""..fieldName..""
end

function QUERY_CLASS:GroupBy(fieldName)
	self.groupList[#self.groupList + 1] = "" .. fieldName .. ""
end

function QUERY_CLASS:Insert(key, value)
	local val = "'"..self:Escape(value).."'"
	if (isbool(value)) then
		val = tostring(value)
	end
	if (isnumber(value)) then
		val = value
	end
	if (value == nil) then
		val = "NULL"
	end
	self.insertList[#self.insertList + 1] = {""..key.."", val}
end

function QUERY_CLASS:Update(key, value, noEscape)
	
	local val = "'"..self:Escape(value).."'"
	if (isbool(value)) then
		val = tostring(value)
	end
	if (isnumber(value)) then
		val = value
	end
	if (value == nil) then
		val = "NULL"
	end
	if (noEscape) then
		val = value
	end

	self.updateList[#self.updateList + 1] = {""..key.."", val}
end

function QUERY_CLASS:Create(key, value)
	self.createList[#self.createList + 1] = {""..key.."", value}
end

function QUERY_CLASS:Add(key, value)
	self.add = {""..key.."", value}
end

function QUERY_CLASS:Drop(key)
	self.drop = ""..key..""
end

function QUERY_CLASS:PrimaryKey(key)
	self.primaryKey = ""..key..""
end

function QUERY_CLASS:Index(column, name)
	self.indexList[#self.indexList + 1] = { column, name }
end

function QUERY_CLASS:Limit(value)
	self.limit = value
end

function QUERY_CLASS:Offset(value)
	self.offset = value
end

local function ApplyQueryReplacements(mode, query, strModule)
	if (!Replacements[strModule]) then
		return query
	end

	local result = query
	local entries = Replacements[strModule][mode]

	for i = 1, #entries do
		result = string.gsub(result, entries[i][1], entries[i][2])
	end

	return result
end

local function BuildSelectQuery(queryObj)
	local queryString = {"SELECT"}

	if (!istable(queryObj.selectList) or #queryObj.selectList == 0) then
		queryString[#queryString + 1] = " *"
	else
		queryString[#queryString + 1] = " "..table.concat(queryObj.selectList, ", ")
	end

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " FROM "..queryObj.tableName.." "
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	if (istable(queryObj.joinList) and #queryObj.joinList > 0) then
        queryString[#queryString + 1] = table.concat(queryObj.joinList, " ")
    end

	if (istable(queryObj.whereList) and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = " WHERE "
		queryString[#queryString + 1] = table.concat(queryObj.whereList, !queryObj.whereOr and " AND " or " OR ")
	end

	if (istable(queryObj.groupList) and #queryObj.groupList > 0) then
		queryString[#queryString + 1] = " GROUP BY "
		queryString[#queryString + 1] = table.concat(queryObj.groupList, ", ")
	end

	if (istable(queryObj.orderByList) and #queryObj.orderByList > 0) then
		queryString[#queryString + 1] = " ORDER BY "
		queryString[#queryString + 1] = table.concat(queryObj.orderByList, ", ")
	end

	
	if (isnumber(queryObj.limit)) then
		queryString[#queryString + 1] = " LIMIT "
		queryString[#queryString + 1] = queryObj.limit
	end

	if (isnumber(queryObj.offset)) then
		queryString[#queryString + 1] = " OFFSET "
		queryString[#queryString + 1] = queryObj.offset
	end


	return table.concat(queryString)
end

local function BuildInsertQuery(queryObj, bIgnore, bReplace)
	local suffix = (bReplace and "REPLACE INTO") or (bIgnore and (queryObj.instance.module == "sqlite" and "INSERT OR IGNORE INTO" or "INSERT IGNORE INTO") or "INSERT INTO")

	local queryString = {suffix}
	local keyList = {}
	local valueList = {}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	for i = 1, #queryObj.insertList do
		keyList[#keyList + 1] = queryObj.insertList[i][1]
		valueList[#valueList + 1] = queryObj.insertList[i][2]
	end

	if (#keyList == 0) then
		return
	end

	queryString[#queryString + 1] = " ("..table.concat(keyList, ", ")..")"
	queryString[#queryString + 1] = " VALUES ("..table.concat(valueList, ", ")..")"


	return table.concat(queryString)
end




local function BuildUpdateQuery(queryObj)
	local queryString = {"UPDATE"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	if (istable(queryObj.updateList) and #queryObj.updateList > 0) then
		local updateList = {}

		queryString[#queryString + 1] = " SET"

		for i = 1, #queryObj.updateList do
			updateList[#updateList + 1] = queryObj.updateList[i][1].." = "..queryObj.updateList[i][2]
		end

		queryString[#queryString + 1] = " "..table.concat(updateList, ", ")
	end

	if (istable(queryObj.whereList) and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = " WHERE "
		queryString[#queryString + 1] = table.concat(queryObj.whereList, !queryObj.whereOr and " AND " or " OR ")
	end

	if (isnumber(queryObj.offset)) then
		queryString[#queryString + 1] = " OFFSET "
		queryString[#queryString + 1] = queryObj.offset
	end


	return table.concat(queryString)
end

local function BuildDeleteQuery(queryObj)
	local queryString = {"DELETE FROM"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName..""
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	if (istable(queryObj.whereList) and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = " WHERE "
		queryString[#queryString + 1] = table.concat(queryObj.whereList, !queryObj.whereOr and " AND " or " OR ")
	end

	if (isnumber(queryObj.limit)) then
		queryString[#queryString + 1] = " LIMIT "
		queryString[#queryString + 1] = queryObj.limit
	end

	return table.concat(queryString)
end

local function BuildDropQuery(queryObj)
	local queryString = {"DROP TABLE"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName..""
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	return table.concat(queryString)
end

local function BuildTruncateQuery(queryObj)
	local queryString = {"TRUNCATE TABLE"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName..""
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	return table.concat(queryString)
end

local function BuildCreateQuery(queryObj)
	local queryString = {"CREATE TABLE IF NOT EXISTS"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName..""
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	queryString[#queryString + 1] = " ("

	if (istable(queryObj.createList) and #queryObj.createList > 0) then
		local createList = {}

		for i = 1, #queryObj.createList do
			if (queryObj.instance.module == "sqlite") then
				createList[#createList + 1] = queryObj.createList[i][1].." "..ApplyQueryReplacements("Create", queryObj.createList[i][2], queryObj.instance.module)
			else
				createList[#createList + 1] = queryObj.createList[i][1].." "..queryObj.createList[i][2]
			end
		end

		queryString[#queryString + 1] = " "..table.concat(createList, ", ")
	end

	if (isstring(queryObj.primaryKey)) then
		queryString[#queryString + 1] = ", PRIMARY KEY"
		queryString[#queryString + 1] = " ("..queryObj.primaryKey..")"
	end

	if (istable(queryObj.indexList) and #queryObj.indexList > 0 and queryObj.instance.module != "sqlite") then
		for k, indexTbl in pairs(queryObj.indexList) do
			local col = indexTbl[1]
			local name = indexTbl[2]

			queryString[#queryString + 1] = string.format(", INDEX `%s` (%s)", name, col)
		end
	end

	queryString[#queryString + 1] = " )"

	if (istable(queryObj.indexList) and #queryObj.indexList > 0 and queryObj.instance.module == "sqlite") then
		queryString[#queryString + 1] = "; "
		for k, indexTbl in pairs(queryObj.indexList) do
			local col = indexTbl[1]
			local name = indexTbl[2]

			queryString[#queryString + 1] = string.format("CREATE INDEX IF NOT EXISTS %s ON %s(%s); ", name, queryObj.tableName, col)
		end
	end

	return table.concat(queryString)
end

local function BuildAlterQuery(queryObj)
	local queryString = {"ALTER TABLE"}

	if (isstring(queryObj.tableName)) then
		queryString[#queryString + 1] = " "..queryObj.tableName..""
	else
		ErrorNoHalt("[VoidLib SQL] No table name specified!\n")
		return
	end

	if (istable(queryObj.add)) then
		queryString[#queryString + 1] = " ADD "..queryObj.add[1].." "..ApplyQueryReplacements("Create", queryObj.add[2], queryObj.instance.module)
	elseif (isstring(queryObj.drop)) then
		if (queryObj.instance.module == "sqlite") then
			ErrorNoHalt("[VoidLib SQL] Cannot drop columns in sqlite!\n")
			return
		end

		queryString[#queryString + 1] = " DROP COLUMN "..queryObj.drop
	end

	return table.concat(queryString)
end


function QUERY_CLASS:Execute(bQueueQuery)
	local queryString = nil
	local queryType = string.lower(self.queryType)

	if (queryType == "select") then
		queryString = BuildSelectQuery(self)
	elseif (queryType == "insert") then
		queryString = BuildInsertQuery(self)
	elseif (queryType == "insert ignore") then
		queryString = BuildInsertQuery(self, true)
	elseif (queryType == "update") then
		queryString = BuildUpdateQuery(self)
	elseif (queryType == "delete") then
		queryString = BuildDeleteQuery(self)
	elseif (queryType == "drop") then
		queryString = BuildDropQuery(self)
	elseif (queryType == "truncate") then
		queryString = BuildTruncateQuery(self)
	elseif (queryType == "create") then
		queryString = BuildCreateQuery(self)
	elseif (queryType == "alter") then
		queryString = BuildAlterQuery(self)
	elseif (queryType == "replace") then
		queryString = BuildInsertQuery(self, true, true)
	end

	if (isstring(queryString)) then
		if (!bQueueQuery) then
			return self.instance:RawQuery(queryString, self.callback)
		else
			return self.instance:Queue(queryString, self.callback)
		end
	end
end

--[[
	End Query Class.
--]]

function DATABASE_CLASS:Select(tableName)
	return QUERY_CLASS:New(tableName, "SELECT", self)
end

function DATABASE_CLASS:Insert(tableName)
	return QUERY_CLASS:New(tableName, "INSERT", self)
end

function DATABASE_CLASS:InsertIgnore(tableName)
	return QUERY_CLASS:New(tableName, "INSERT IGNORE", self)
end

function DATABASE_CLASS:Replace(tableName)
	return QUERY_CLASS:New(tableName, "REPLACE", self)
end

function DATABASE_CLASS:Update(tableName)
	return QUERY_CLASS:New(tableName, "UPDATE", self)
end

function DATABASE_CLASS:Delete(tableName)
	return QUERY_CLASS:New(tableName, "DELETE", self)
end

function DATABASE_CLASS:Drop(tableName)
	return QUERY_CLASS:New(tableName, "DROP", self)
end

function DATABASE_CLASS:Truncate(tableName)
	return QUERY_CLASS:New(tableName, "TRUNCATE", self)
end

function DATABASE_CLASS:Create(tableName)
	return QUERY_CLASS:New(tableName, "CREATE", self)
end

function DATABASE_CLASS:Alter(tableName)
	return QUERY_CLASS:New(tableName, "ALTER", self)
end


-- A function to query the database.
function DATABASE_CLASS:RawQuery(query, callback, flags, queueCallback)
	if (self.module == "mysqloo") then

		if (!self.connection) then
			-- connection not done yet, try to connect
			VoidLib.Print("MySQL connection not ready but trying to execute query, retrying after connection...")
			self:Connect()

			hook.Add("VoidLib.DatabaseConnected", "VoidLib.Query.WaitForTheConnection", function ()
				VoidLib.Print("Connection established, retrying query..")
				self:RawQuery(query, callback, flags, queueCallback) -- rerun query
				hook.Remove("VoidLib.DatabaseConnected", "VoidLib.Query.WaitForTheConnection")
			end)

			return
		end

		local queryObj = self.connection:query(query)

		queryObj:setOption(mysqloo.OPTION_NAMED_FIELDS)

		queryObj.onSuccess = function(self, result)
			if (callback) then
				callback(result, true, tonumber(queryObj:lastInsert()))
			end

			if (queueCallback) then
				queueCallback()
			end
		end

		function queryObj:onError(errorText, sql)
			ErrorNoHalt(string.format("[VoidLib SQL] SQL Query Error!\nQuery: %s\n%s\n", query, errorText))
		end

		queryObj:start()
	elseif (self.module == "sqlite") then
		local result = sql.Query(query)


		if (result == false) then
			error(string.format("[VoidLib SQL] SQL Query Error!\nQuery: %s\n%s\n", query, sql.LastError()))
		else
			if (callback) then
				callback(result, true, tonumber(sql.QueryValue("SELECT last_insert_rowid()")))

				if (queueCallback) then
					queueCallback()
				end
			else
				if (queueCallback) then
					queueCallback()
				end
			end
		end
	else
		ErrorNoHalt(string.format("[VoidLib SQL] Unsupported module \"%s\"!\n", self.module))
	end
end

-- A function to add a query to the queue.
function DATABASE_CLASS:Queue(queryString, callback)
	if (isstring(queryString)) then
		QueueTable[#QueueTable + 1] = {queryString, callback}
	end
end

-- A function to escape a string.
function DATABASE_CLASS:Escape(text)
	if (self.connection) then
		if (self.module == "mysqloo") then
			return self.connection:escape(text)
		end
	else
		return sql.SQLStr(text, true)
	end
end

-- A function to disconnect from the database.
function DATABASE_CLASS:Disconnect()
	if (self.connection) then
		if (self.module == "mysqloo") then
			self.connection:disconnect(true)
		end
	end
end

function DATABASE_CLASS:Think()
	if (#QueueTable > 0) then
		if (istable(QueueTable[1])) then
			local queueObj = QueueTable[1]
			local queryString = queueObj[1]
			local callback = queueObj[2]

			if (isstring(queryString)) then
				self:RawQuery(queryString, callback)
			end

			table.remove(QueueTable, 1)
		end
	end
end

-- A function to set the module that should be used.
function DATABASE_CLASS:SetModule(moduleName)
	self.module = moduleName
end

-- A function to check whether or not the module is connected to a database.
function DATABASE_CLASS:IsConnected()
	return self.module == "mysqloo" and (self.connection and self.connection:status() == mysqloo.DATABASE_CONNECTED) or self.module == "sqlite"
end

hook.Run("VoidLib.DatabaseLibInitialized")
