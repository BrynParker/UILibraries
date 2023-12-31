local yellow = Color(201, 176, 15)
local red = Color(230, 58, 64)
local green = Color(46, 204, 113)

function XeninUI:InvokeSQL(conn, str, name, successFunc, errFunc, returnId, transaction)
	local p = XeninUI.Promises.new()
	local debug = self.Debug
	local sqlStr = conn.isMySQL() and "[MySQL] " or "[SQLite] "
	local successDetour = function(result)
		if debug then
			MsgC(yellow, sqlStr, color_white, name, green, " Success!\n")
		end
	end
	local _successFunc = function(result, id)
		if (returnId and !conn.isMySQL()) then
			id = sql.QueryRow("SELECT last_insert_rowid() AS id").id
		end

		successDetour(result, id)
		if returnId then
			p:resolve({
				result,
				id
			})
		else
			p:resolve(result)
		end
	end
	local errDetour = function(err)
		if debug then
			MsgC(yellow, sqlStr, color_white, name, red, " Failure! ", color_white, err .. "\n")
		end
	end
	local _errFunc = function(err)
		errDetour(err)
		p:reject(err)
	end

	if transaction then
		if debug then
			MsgC(yellow, sqlStr, color_white, name, yellow, " Queuing!\n")
		end

		conn.queueQuery(str, _successFunc, _errFunc)
	else
		conn.query(str, _successFunc, _errFunc)
	end

	return p
end
