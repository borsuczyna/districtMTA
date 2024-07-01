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
    }
}

function getModelsCount()
    local count = 0
    for _, model in pairs(models) do
        count = count + 1
    end
    return count
end

local isActionAuthorized = false

local function authorizeAction()
    isActionAuthorized = true
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
    
    return teaDecode(data, hash)
end