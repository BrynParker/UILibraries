

////////////////
///  Colors  ///
////////////////

-- https://stackoverflow.com/a/3943023
function VoidLib.DynamicTextColor(col)
    local sum = col.r * 0.299 + col.g * 0.587 + col.b * 0.114
    if (sum > 186) then
        return VoidUI.Colors.Background
    else
        return VoidUI.Colors.Gray
    end
end


//////////////////////////
///  String Functions  ///
//////////////////////////

function VoidLib.StringFormat(str, x)
    -- x can be either a table of key value -> [level] = 25
    -- or just one argument
    str = tostring(str)

    if (istable(x)) then
        local currStr = str
        for k, v in pairs(x) do
            local valToReplace = ":" .. tostring(k) .. ":"
            currStr = string.Replace(currStr, valToReplace, tostring(v))
        end
        return currStr
    else
        return string.gsub(str, ":[%w_]+:", x)
    end
end

function VoidLib.IsNilOrEmpty(var)
    if var == nil then return true end
    if var == NULL then return true end
    if isstring(var) then
        return var:Replace(" ", "") == ""
    end
    return false
end


/////////////////////////
///   Net functions   ///
/////////////////////////

function VoidLib.CompressTable(tbl)
    local json = util.TableToJSON(tbl)
    if (!json) then return end

    return util.Compress(json)
end

function VoidLib.DecompressTable(json)
    local data = util.Decompress(json)

    return util.JSONToTable(data)
end

function VoidLib.WriteCompressedTable(tbl)
    local data = VoidLib.CompressTable(tbl)
    net.WriteUInt(#data, 32)
    net.WriteData(data, #data)
end

function VoidLib.ReadCompressedTable()
    local length = net.ReadUInt(32)
    local data = net.ReadData(length)

    return VoidLib.DecompressTable(data)
end

/////////////////////////////////
///  Serialization functions  ///
/////////////////////////////////

-- Not really CSV but who cares
-- table -> string (csv)
function VoidLib.TableToCSV(tbl)
    return table.concat(tbl, ";")
end

-- string (csv) -> table
function VoidLib.CSVToTable(csv)
    return string.Explode(";", csv)
end

-- Vector -> string
function VoidLib.SerializeVector(vec)
    if (!vec) then return nil end
    local tbl = vec:ToTable()
    return VoidLib.TableToCSV(tbl)
end

-- string -> Vector
function VoidLib.DeserializeVector(str)
    local tbl = VoidLib.CSVToTable(str)
    return Vector(unpack(tbl))
end

