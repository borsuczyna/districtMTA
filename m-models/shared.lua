cancelLoadingModels = false
models = {
    ['int-1'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['spawn-ls'] = {
        custom = false,
        type = 'object',
        model = 4824,
    },
    ['cablecar'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['cablecar-door'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['cablecar-rail'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['railway-station'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
}

function getModelsCount()
    local count = 0
    for _, model in pairs(models) do
        count = count + 1
    end
    return count
end

function encodeFileIn(path, pathOut, hash)
    if not fileExists(path) then return end

    local file = fileOpen(path)
    if not file then return end
    local data = fileRead(file, fileGetSize(file))
    fileClose(file)
    
    if fileExists(pathOut) then
        fileDelete(pathOut)
    end
    
    local newData = teaEncode(data, hash)
    local newFile = fileCreate(pathOut)
    fileWrite(newFile, newData)
    fileClose(newFile)
end
    
function decodeFileIn(path, hash)
    if not fileExists(path) then return end

    local file = fileOpen(path)
    local size = fileGetSize(file)
    local data = fileRead(file, size)
    fileClose(file)
    
    return data
    -- return teaDecode(data, hash)
end

function createCustomObject(model, x, y, z, rx, ry, rz)
    local original = models[model]
    if not original then return end

    local object = createObject(original.model, x, y, z, rx, ry, rz)
    setElementData(object, 'element:model', model)

    return object
end

createCustomObject('railway-station', 1177.474, -1993.162, 67.508)