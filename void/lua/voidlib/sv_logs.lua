VoidLib.Logs = VoidLib.Logs or {}
VoidLib.Logs.LogAttempts = 10

function VoidLib.Logs:UploadLogs(strToken, tblAddon)
    local strLog = VoidLib.Logging:FormatReadLogs(tblAddon, true)

    local postData = {
        token = strToken,
        log = strLog,
        ip = game.GetIPAddress()
    }

    http.Post( "https://voidstudios.dev/api/log/upload", postData, function (strBody, intSize, tblHeaders, intCode)
        if (intCode != 200) then
            VoidLib:Log("Something went wrong while uploading logs - error code: :code:, response: :body:", { code = intCode, body = strBody }, "Support")
            return
        end

        VoidLib:Log("Successfully uploaded your logs to VoidStudios support team.", "Support")
    end, function ()
        VoidLib:Log("Failed to contact the VoidStudios servers.", "Support")
    end)
end