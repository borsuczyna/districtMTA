addEvent('models:receiveEncodeHashes', true)
setOcclusionsEnabled(false)

local encodeHashes = false
local txdCache = {}
local loadingQueue = {
    nextModelLoad = getTickCount()
}

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

function getTXDFromPath(path, hash)
    if txdCache[path] then
        return txdCache[path]
    end

    local data = decodeFileIn(path, hash)
    txdCache[path] = engineLoadTXD(data)

    return txdCache[path]
end

function loadModel(name, data)
    if cancelLoadingModels then return end -- nop addDebugHook detected

    local filePath = 'data/encoded/' .. name
    local model = data.model
    if data.custom then
        data.newModel = engineRequestModel(data.type or 'object', model or 1337)
        model = data.newModel
    end

    local txdPath = data.txd and 'data/encoded/' .. data.txd or filePath
    if fileExists(txdPath .. '.txd') then
        local txd = getTXDFromPath(txdPath .. '.txd', getEncodeHash((data.txd or name) .. '.txd'))
        engineImportTXD(txd, model)
    end
    if fileExists(filePath .. '.dff') then
        local dff = decodeFileIn(filePath .. '.dff', getEncodeHash(name .. '.dff'))
        engineReplaceModel(engineLoadDFF(dff), model, true)
    end
    if fileExists(filePath .. '.col') then
        local col = decodeFileIn(filePath .. '.col', getEncodeHash(name .. '.col'))
        engineReplaceCOL(engineLoadCOL(col), model)
    end

    clearDecodeFileIn()

    local total = getElementData(localPlayer, 'models:loading:total')
    local loaded = getElementData(localPlayer, 'models:loading:progress') + 1
    outputConsole('Załadowano model ' .. name .. ' (' .. loaded .. '/' .. total .. ')')

    setElementData(localPlayer, 'models:loading:progress', loaded)
    data.loaded = true

    -- local x, y, z = getElementPosition(localPlayer)
    -- createObject(model, x, y, z-1)

    if total == loaded then
        updateAllCustomModels()
    else
        setTimer(updateQueue, 0, 1)
    end
end

function getCustomModel(name)
    local data = models[name]
    if not data then 
        return false
    end

    return data.newModel
end

function getOriginalModel(name)
    local data = models[name]
    if not data then 
        return false
    end

    return data.model
end

function updateQueue()
    local name, model = getNextNotLoadedModel()
    if not name or not model then return end

    loadModel(name, model)
end

function getEncodeHashes()
    local wanted = {}
    for name, model in pairs(models) do
        if fileExists('data/encoded/' .. name .. '.txd') then
            table.insert(wanted, name .. '.txd')
        end
        if fileExists('data/encoded/' .. name .. '.dff') then
            table.insert(wanted, name .. '.dff')
        end
        if fileExists('data/encoded/' .. name .. '.col') then
            table.insert(wanted, name .. '.col')
        end
        if model.txd then
            table.insert(wanted, model.txd .. '.txd')
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

addEventHandler('onClientElementDataChange', root, function(dataName)
    if dataName == 'element:model' then
        local model = getElementData(source, 'element:model')
        if model then
            local customModel = getCustomModel(model)
            if customModel then
                setElementModel(source, customModel)
            else
                local vehicleModel = getElementData(source, 'vehicle:model')
                if vehicleModel then
                    setElementModel(source, vehicleModel)
                end
            end
        else
            local vehicleModel = getElementData(source, 'vehicle:model')
            if vehicleModel then
                setElementModel(source, vehicleModel)
            end
        end
    end
end)

addEventHandler('onClientElementStreamIn', root, function()
    local model = getElementData(source, 'element:model')
    if model then
        local customModel = getCustomModel(model)
        if customModel then
            setElementModel(source, customModel)
        end
    end
end)

function updateAllCustomModels()
    updateCustomModels(getElementsByType('object'))
    updateCustomModels(getElementsByType('vehicle'))
    updateCustomModels(getElementsByType('ped'))
    updateCustomModels(getElementsByType('player'))
    updateCustomModels(getElementsByType('pickup'))
end

function updateCustomModels(elements)
    for i, element in ipairs(elements) do
        local model = getElementData(element, 'element:model')
        if model then
            local customModel = getCustomModel(model)
            if customModel then
                setElementModel(element, customModel)
            else
            end
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, loadModels)

-- on resource stop if element has element:model restore original model
addEventHandler('onClientResourceStop', resourceRoot, function()
    for i, element in ipairs(getElementsByType('object')) do
        local model = getElementData(element, 'element:model')
        if model then
            local originalModel = getOriginalModel(model)
            if originalModel then
                setElementModel(element, originalModel)
            else
            end
        end
    end
end)