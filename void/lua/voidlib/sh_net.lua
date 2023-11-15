VoidLib.Net = VoidLib.Net or {}
VoidLib.Net.Receivers = VoidLib.Net.Receivers or {}

if (SERVER) then
    util.AddNetworkString("VoidLib.TestingNetMessage")
end

-- Consts
local NET_CHUNK_SIZE = 65530

-- Class definition

local NET_CLASS = {}
NET_CLASS.__index = NET_CLASS

AccessorFunc(NET_CLASS, "strName", "Name", FORCE_STRING)
AccessorFunc(NET_CLASS, "bReceiving", "IsReceiving", FORCE_BOOL)
AccessorFunc(NET_CLASS, "bReadingChunks", "IsReadingChunks", FORCE_BOOL)
AccessorFunc(NET_CLASS, "intChunkIndex", "ChunkIndex", FORCE_NUMBER)
AccessorFunc(NET_CLASS, "pPlayer", "Sender")

function NET_CLASS:New(strName, bReceiving)
	local newObject = setmetatable({}, NET_CLASS)
    newObject.writtenData = {}
    newObject.readData = {}
    newObject.bLargeMessage = false
    newObject.intTotalBytes = 0

    -- define default type methods
    for k, v in pairs(newObject.DefaultTypes) do
        newObject["Write" .. v] = function(...) newObject:WriteField(v, { ... }) end
        newObject["Read" .. v] = function(...) return newObject:ReadField(v, { ... }) end
    end

    if (!bReceiving) then
        newObject:Start(strName)
    end

	return newObject
end

-- Getters

function NET_CLASS:GetBytes()
    return net.BytesWritten()
end

-- Methods

local function getTypeIndex(strType)
    for k, v in ipairs(NET_CLASS.DefaultTypes) do
        if (v == strType) then
            return k
        end
    end
end

-- starts a new message, for example we want to send a net message from a receiver object
function NET_CLASS:Start(strMessage) 
    self:SetName(strMessage)
    self.writtenData = {}
    pcall(net.Start, strMessage)
end

function NET_CLASS:Send(pPlayer, bBroadcast)
    self.pReceiver = pPlayer
    VoidLib:LogDebug("Sending net message :net: with size :size: bytes (:from: -> :to:)!", { net = self:GetName(), size = self:GetBytes(), from = CLIENT and "CLIENT" or "SERVER", to = CLIENT and "SERVER" or "CLIENT" }, "Networking")

    if (self:GetBytes() >= NET_CHUNK_SIZE) then
        VoidLib:LogDebug("Sending a split message because net size too big!", "Networking")
        self:SendSplitMessage()
    else
        -- Create a new net message, and cancel the prev one

        if (SERVER) then
            net.Send({})

            net.Start(self:GetName())
            net.WriteBool(false)

            for k, v in ipairs(self.writtenData) do
                self:WriteDataObject(v)
            end

            self:SendInternal(pPlayer, bBroadcast)
        else
            self:SendInternal(pPlayer)
        end
    end
end

function NET_CLASS:Broadcast(pPlayer)
    return self:Send(pPlayer, true)
end

function NET_CLASS:SendInternal(pPlayer, bBroadcast)
    if (istable(pPlayer) and table.IsEmpty(pPlayer)) then
        net.Send({})
        return
    end

    VoidLib:LogDebug("Internal message :message: size :size: bytes", { message = self:GetName(), size = net.BytesWritten() }, "Networking")
    if (SERVER) then
        if (bBroadcast) then
            net.Broadcast()
        else
            net.Send(pPlayer)
        end
    else
        net.SendToServer()
    end
end

function NET_CLASS:SendSplitMessage()
    local tblData = {}
    for k, v in pairs(self.writtenData) do
        local t = { getTypeIndex(v[1]) }
        table.insert(tblData, t)
        if (v[2] and v[2][2]) then
            t[2] = v[2][2]
        end
    end

    local str = util.TableToJSON(tblData)
    local binCompressed = util.Compress(str)
    tblData = nil

    VoidLib:Log("Sending a large message, ignore the error below!", "Networking")

    pcall(net.Send, {}) -- discard the overflowing previous one

    VoidLib:Log("Sending a large message, ignore the error above!", "Networking")

    local _net = VoidLib.Net:Start(self:GetName())
    _net:WriteBool(true)
    _net:WriteUInt(#binCompressed, 32)
    _net:WriteData(binCompressed)
    _net:SendInternal(self.pReceiver)

    VoidLib:LogDebug("Wrote table structure, total types: :types:", {types = #self.writtenData}, "Networking")

    -- now send the individual messages until done
    -- local _net = VoidLib.Net:Start(self:GetName())
    -- -- _net:

    local intTotalBytes = 0
    local bWriteDone = false
    local i = 0
    local intWriteLastPos = 0
    while (!bWriteDone) do
        if (intWriteLastPos >= #self.writtenData) then
            bWriteDone = true
            break
        end

        local iterNet = VoidLib.Net:Start(self:GetName())
        for k, v in pairs(self.writtenData) do
            if (k <= intWriteLastPos) then continue end
            iterNet:AddDataObject(v)

            intWriteLastPos = k
            if (iterNet:GetBytes() > 60000) then
                VoidLib:LogDebug("Net message chunk is larger than :x: kb, splitting, pos: :pos:!", {x = 60000, pos = k}, "Networking")
                break
            end
        end

        VoidLib:LogDebug("Sending large net message chunk!", "Networking")
        iterNet:SendInternal({})

        local tblWritten = iterNet.writtenData
        local intCount = #iterNet.writtenData

        -- Wrap message with size
        local _wrappedNet = VoidLib.Net:Start(iterNet:GetName())
        _wrappedNet:WriteBool(true)
        _wrappedNet:WriteBool(false)
        _wrappedNet:WriteUInt(intCount, 32)
        for k, v in pairs(tblWritten) do
            _wrappedNet:WriteDataObject(v)
        end
        intTotalBytes = intTotalBytes + _wrappedNet:GetBytes()
        _wrappedNet:SendInternal(self.pReceiver)

        i = i + 1
        if (i > 20) then
            VoidLib:LogError("Failed to send large net message after 20 iterations! Aborting.", "Networking")
            break
        end
    end

    _net:Start(self:GetName())
    _net:WriteBool(true)
    _net:WriteBool(true)
    _net:SendInternal(self.pReceiver)

    VoidLib:Log("Sent a large net message, in total sent :bytes: bytes!", { bytes = intTotalBytes }, "Networking")
end

function NET_CLASS:ReadNetStructure()
    VoidLib:LogDebug("Reading large net message structure", "Networking")

    local intLen = self:ReadUInt(32)
    local strJson = util.Decompress(self:ReadData(intLen))
    local tbl = util.JSONToTable(strJson)

    self.tblStruct = tbl
    self.intStructPos = 1
end

function NET_CLASS:ReadMessageChunk()
    local bLastMessage = self:ReadBool()

    if (bLastMessage) then
        -- Finish reading!
        self:SetIsReadingChunks(false)
        VoidLib:LogDebug("Large message read done!", "Networking")

        self.fFunc(nil, nil, true)

        return
    end
    

    local tblStruct = self.tblStruct
    
    local intLen = self:ReadUInt(32)

    for i = 1, intLen do
        local tblInfo = tblStruct[self.intStructPos]
        if (!tblInfo) then
            break
        end

        local strType = tblInfo[1]
        local intX = tblInfo[2]

        strType = NET_CLASS.DefaultTypes[strType]

        local xData = net["Read" .. strType](intX)
        table.insert(self.readData, xData)

        -- VoidLib:LogDebug("Iter (:i:), read type :type: with value :value:", {i = i, type = strType, value = xData}, "Networking")
        self.intStructPos = self.intStructPos + 1
        i = i + 1
    end
end

-- Net basic fields table
NET_CLASS.DefaultTypes = {
    "String",
    "Bit",
    "Bool",
    "Int",
    "UInt",
    "Float",
    "Double",
    "Table",
    "Entity",
    "Color",
    "Vector",
    "Angle",
    "Data"
}

-- Write methods

function NET_CLASS:WriteField(strType, tblData)
    table.remove(tblData, 1)
    table.insert(self.writtenData, {
        [1] = strType,
        [2] = tblData
    })

    net["Write" .. strType](unpack(tblData))
    -- VoidLib:LogDebug("Written field of type :type:, data: :data:", { type = strType, data = tblData[1] }, "Networking" )
end

function NET_CLASS:WriteDataObject(tObj)
    local strName = tObj[1]
    net["Write" .. strName](unpack(tObj[2]))
end

function NET_CLASS:AddDataObject(tObj)
    local strName = tObj[1]
    net["Write" .. strName](unpack(tObj[2]))

    table.insert(self.writtenData, {
        [1] = strName,
        [2] = tObj[2]
    })
end

function NET_CLASS:ReadField(strType, tblData)
    table.remove(tblData, 1)

    local xRes = self.bLargeMessage and self.readData[self.intReadPos] or net["Read" .. strType](unpack(tblData))

    if (self.bLargeMessage) then
        self.intReadPos = self.intReadPos + 1
    end

    return xRes
end


-- Methods

function VoidLib.Net:Start(strMessage)
    return NET_CLASS:New(strMessage)
end

function VoidLib.Net:ReceiverDummy()
    local cl = NET_CLASS:New()
    cl:ReadBool()
    return cl
end

function VoidLib.Net:WriterDummy()
    local cl = NET_CLASS:New()
    return cl
end


function VoidLib.Net:Receive(strMessage, fFunc)
    local _net = NET_CLASS:New(strMessage, true)

    if (!VoidLib.Net.Receivers[strMessage]) then
        VoidLib.Net.Receivers[strMessage] = {}
    end


    local fNew = function (intLen, pPlayer, bLargeMessage)
        if (CLIENT) then
            local bSplit = _net:ReadBool()

            if (_net:GetIsReadingChunks()) then
                _net:ReadMessageChunk()
            else
                -- check here if we are reading a splitted message, if yes, then reconstruct the message later
                if (bSplit and !bLargeMessage) then
                    _net:SetIsReadingChunks(true)
                    _net:ReadNetStructure()
                else
                    if (bLargeMessage) then
                        _net.intReadPos = 1
                        _net.bLargeMessage = true
                    end

                    fFunc(_net, intLen, pPlayer)
                end
            end
        else
            fFunc(_net, intLen, pPlayer)
        end
    end

    _net.fFunc = fNew

    net.Receive(strMessage, fNew)
    table.insert(VoidLib.Net.Receivers[strMessage], _net)
end

VoidLib.Net.Listen = VoidLib.Net.Receive