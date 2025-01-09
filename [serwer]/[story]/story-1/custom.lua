local models = {}
local replace = {
    ['data/story-building'] = 16232,
    ['data/missile'] = true,
    ['data/fire'] = true,
    ['data/smoke'] = true,
    ['data/plane'] = true,
}

function replaceModel(filename, model)
    if model == true then
        model = engineRequestModel('object')

        local objectName = filename:match('.+/(.+)$')
        models[objectName] = model
    end

    if fileExists(filename..'.txd') then
        local txd = engineLoadTXD(filename..'.txd')
        engineImportTXD(txd, model)
    end
    if fileExists(filename..'.dff') then
        local dff = engineLoadDFF(filename..'.dff')
        engineReplaceModel(dff, model, true)
    end
    if fileExists(filename..'.col') then
        local col = engineLoadCOL(filename..'.col')
        engineReplaceCOL(col, model)
    end
end

function replaceModels()
    for filename,model in pairs(replace) do
        replaceModel(filename, model)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, replaceModels)

function getCustomModel(filename)
    if models[filename] then
        return models[filename]
    end
    return false
end

-- local testObject = createObject(16232, 445.22,1555.75,19.0859)
-- assignLOD(testObject)
-- local testObject2 = createObject(getCustomModel('missile'), 463.2, 1528.1, 44.69456, 0, 0, 0)
-- assignLOD(testObject2)

function setObjectCustomModel(object, model)
    setElementData(object, 'story:model', model)
    local lod = getLowLODElement(object)
    if lod then
        setElementData(lod, 'story:model', model)
    end
end

addEventHandler('onClientElementDataChange', resourceRoot, function(key, old, new)
    if key ~= 'story:model' then return end

    local model = getCustomModel(new)
    if not model then return end

    setElementModel(source, model)
end)

addEventHandler('onClientElementStreamIn' , resourceRoot, function()
    local nmodel = getElementData(source, 'element:model')
    if nmodel and (nmodel == 'ufo' or nmodel == 'ufo2') then
        local model = getElementModel(source)
        engineSetModelLODDistance(model, 3000)
    end

    local model = getElementData(source, 'story:model')
    if not model then return end

    model = getCustomModel(model)
    if not model then return end
    setElementModel(source, model)
    engineSetModelLODDistance(model, 3000)
end)

addEventHandler('onElementDataChange', resourceRoot, function(key, old, new)
    if key ~= 'story:model' or not client then return end
    banPlayer(client, true, false, true, 'Live event anticheat')
end)