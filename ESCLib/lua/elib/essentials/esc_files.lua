esclib.file = {}

local function Split(istring,sep)
	local sep = sep or "%s"
    local t={}
    for str in string.gmatch(istring, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function esclib.file:MakeIfNotExists(file_name)
	if file.Exists(file_name, "DATA") then return end
	local files = Split(file_name,"/")
	local o_file_name = ""
	if #files > 1 then
		o_file_name = files[1]
		for i=2,#files-1 do
			o_file_name = o_file_name.."/"..files[i]
		end
		file.CreateDir( o_file_name )
		o_file_name = o_file_name.."/"..files[#files]
		file.Write(o_file_name,"")

		return true
	elseif #files == 0 then
		return false
	end
end

--EXAMPLE:
-- esclib.file:SaveVar("ehud/savedvars.txt",{["hello"]={"214151","215161664",""}})
-- print(esclib.file:ReadVar("ehud/savedvars.txt","hello"))

function esclib.file:SaveVar(file_name,content)
	esclib.file:MakeIfNotExists(file_name)

	local filecontent = file.Read(file_name,"DATA")
	if filecontent then
		filecontent = util.JSONToTable(filecontent) or {}
	else
		filecontent = {}
	end

	if istable(content) then
		if not table.IsEmpty(filecontent) then
			table.Merge(filecontent,content)
		else
			filecontent = content
		end
	else
		table.insert(filecontent,content)
	end

	file.Write(file_name,util.TableToJSON(filecontent))
end

function esclib.file:ReadVar(file_name, var)
	local filecontent = file.Read(file_name,"DATA")
	if filecontent then
		local content = util.JSONToTable(filecontent) or {}
		if var then
			return content[var]
		else
			return content
		end
	else
		return
	end
end

function esclib.file:Remove(file_name)
	file.Delete(file_name)
end