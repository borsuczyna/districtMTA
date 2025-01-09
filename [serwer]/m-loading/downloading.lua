local lastDownloaded = {time = getTickCount(), size = 0, lastUpdate = getTickCount(), visible = false}

local function toHumanReadable(bytes)
    local units = {'b', 'kb', 'mb', 'gb', 'tb'}
    local unit = 1

    while bytes > 1024 do
        bytes = bytes / 1024
        unit = unit + 1
    end

    return bytes, units[unit]
end

addEventHandler('onClientTransferBoxProgressChange', root, function(downloaded, total)
    if download ~= total and lastDownloaded.lastUpdate + 1000 > getTickCount() then
        return
    end

    local progress = downloaded / total
    local downloadedHR, downloadedUnit = toHumanReadable(downloaded)
    local totalHR, totalUnit = toHumanReadable(total)
    local downloadedSince = getTickCount() - lastDownloaded.time
    local downloadedSpeed = (downloaded - lastDownloaded.size) / (downloadedSince / 1000)
    local downloadSpeedHR, downloadSpeedUnit = toHumanReadable(downloadedSpeed)
    lastDownloaded = {time = getTickCount(), size = downloaded, lastUpdate = getTickCount(), visible = true}
    
    setTransferBoxVisible(false)
    if progress < 1 then
        if not isLoadingVisible() then
            setLoadingVisible(true, '')
        end
    end
    
    setLoadingProgress(progress * 100, 1000)
    setLoadingText('<span style="font-size: 0.875rem; color: #ffffffaa;">' .. string.format('%.2f%s / %.2f%s (%.2f%s/s)', downloadedHR, downloadedUnit, totalHR, totalUnit, downloadSpeedHR, downloadSpeedUnit) .. '</span><br>Trwa pobieranie zasobów')
    
    if progress >= 1 then
        if isLoadingVisible() then
            setLoadingVisible(false)
            lastDownloaded.visible = false
        end
    end
end)

addEventHandler('onClientTransferBoxVisibilityChange', root, function(visible)
    if not isLoadingVisible() or not lastDownloaded.visible then return end

    if not visible then
        setLoadingVisible(false)
        lastDownloaded.visible = false
    end
end)

function updateDownloading()
    if not isLoadingVisible() or not lastDownloaded.visible then return end

    local timeSinceLastDownload = getTickCount() - lastDownloaded.time
    if timeSinceLastDownload > 10000 then
        setLoadingVisible(false)
        lastDownloaded.visible = false
    end
end

setTimer(updateDownloading, 1000, 0)