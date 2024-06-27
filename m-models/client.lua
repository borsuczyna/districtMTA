local encodeHashes = false
local loadingQueue = {
    nextModelLoad = getTickCount()
}

addEvent('models:receiveEncodeHashes', true)

function decodeFile(path, hash)
    local file = fileOpen(path)
    local data = fileRead(file, fileGetSize(file))
    fileClose(file)

    return teaDecode(data, hash)
end

function getNextNotLoadedModel()
    for name, model in pairs(models) do
        if not model.loaded then
            return name, model
        end
    end
end

function getEncodeHash(name)
    return encodeHashes[name]
end

function loadModel(name, data)
    if cancelLoadingModels then return end -- nop addDebugHook detected

    local filePath = 'data/encoded/' .. name
    local model = data.model
    if data.custom then
        data.model = engineRequestModel(data.type or 'object', model or 1337)
    end

    if fileExists(filePath .. '.txd') then
        local txd = decodeFileIn(filePath .. '.txd', getEncodeHash(name .. '.txd'))
        engineImportTXD(engineLoadTXD(txd), model)
    end
    if fileExists(filePath .. '.dff') then
        local dff = decodeFileIn(filePath .. '.dff', getEncodeHash(name .. '.txd'))
        engineReplaceModel(engineLoadDFF(dff), model)
    end
    if fileExists(filePath .. '.col') then
        local col = decodeFileIn(filePath .. '.col', getEncodeHash(name .. '.txd'))
        engineReplaceCOL(engineLoadCOL(col), model)
    end

    local total = getElementData(localPlayer, 'models:loading:total')
    local loaded = getElementData(localPlayer, 'models:loading:progress') + 1

    outputConsole('Załadowano model ' .. name .. ' (' .. loaded .. '/' .. total .. ')')
    setElementData(localPlayer, 'models:loading:progress', loaded)
    data.loaded = true

    -- local x, y, z = getElementPosition(localPlayer)
    -- createObject(model, x, y, z-1)

    if total == loaded then
        outputConsole('Załadowano wszystkie modele')
    else
        setTimer(updateQueue, 50, 1)
    end
end

function updateQueue()
    local name, model = getNextNotLoadedModel()
    if not name or not model then return end

    loadModel(name, model)
end

function getEncodeHashes()
    local wanted = {}
    for name, model in pairs(models) do
        if model.custom then
            if fileExists('data/encoded/' .. name .. '.txd') then
                table.insert(wanted, name .. '.txd')
            end
            if fileExists('data/encoded/' .. name .. '.dff') then
                table.insert(wanted, name .. '.dff')
            end
            if fileExists('data/encoded/' .. name .. '.col') then
                table.insert(wanted, name .. '.col')
            end
        end
    end

    triggerServerEvent('models:getEncodeHashes', resourceRoot, wanted)
end

addEventHandler('models:receiveEncodeHashes', resourceRoot, function(hashes)
    encodeHashes = hashes
    updateQueue()
end)

function loadModels()
    setElementData(localPlayer, 'models:loading:progress', 0)
    setElementData(localPlayer, 'models:loading:total', getModelsCount())
    getEncodeHashes()
end

addEventHandler('onClientResourceStart', resourceRoot, loadModels)