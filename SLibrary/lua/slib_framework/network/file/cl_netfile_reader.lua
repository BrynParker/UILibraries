local slib = slib
local snet = slib.Components.Network
local table = table
--
local wait_read_data = {}
local wait_exist_check = {}

snet.Callback('snet_file_read_in_server_get', function(ply, customId, data)
	for i = #wait_read_data, 1, -1 do
		local value = wait_read_data[i]

		if value.id == customId then
			value.func(data)
			table.remove(wait_read_data, i)
			break
		end
	end
end)

snet.Callback('snet_file_read_in_client', function(ply, path, customId)
	local data = slib.FileRead(path)
	snet.Invoke('snet_file_read_in_client_get', ply, customId, data)
end)

function snet.FileReadInServer(path, response_action)
	local name = 'snet_file_read_in_server'
	local customId = slib.GenerateUid(name)

	local request = snet.Request(name, path, customId)
	request.id = customId

	table.insert(wait_read_data, {
		id = request.id,
		func = response_action
	})

	request.InvokeServer()
end

snet.Callback('snet_file_exists_in_server_get', function(ply, customId, is_exist)
	for i = #wait_exist_check, 1, -1 do
		local value = wait_exist_check[i]

		if value.id == customId then
			value.func(is_exist)
			table.remove(wait_exist_check, i)
			break
		end
	end
end)

snet.Callback('snet_file_exists_in_client', function(ply, path, customId)
	snet.Invoke('snet_file_exists_in_client_get', ply, customId, slib.FileExists(path))
end)

function snet.FileExistsInServer(path, response_action)
	local name = 'snet_file_exists_in_server'
	local customId = slib.GenerateUid(name)

	local request = snet.Request(name, path, customId)
	request.id = customId

	table.insert(wait_exist_check, {
		id = request.id,
		func = response_action
	})

	request.InvokeServer()
end