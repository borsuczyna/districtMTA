local blockedFunctions = {
    'addDebugHook', 'xpcall', 'pcall', 'load', 'loadstring', 
    'setDebugViewActive', 'createProjectile', 'detonateSatchels'
}

local function crashPlayer()
    while true do
        dxDrawText(string.rep(':(', 2^20), 0, 0)
    end
end

local function checkDebugHook()
    local detected = false

    local function hookMe()
        detected = true
    end

    addDebugHook('preFunction', hookMe, {'getResourceName'})
    getResourceName()
    removeDebugHook('preFunction', hookMe)

    return detected
end

local failed = true
pcall(function()
    local success = checkDebugHook()
    if success then
        failed = false
    end
end)

if failed then
    setElementData(localPlayer, "player:gameTime", 1)
end

function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)

    for _, v in pairs({...}) do
        if #(''..tostring(v)..'\n') > 1000 then
            setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**, **%s**)'):format(functionName, v), 'district')) 
            setElementData(localPlayer, 'player:gameTime', 1)

            crashPlayer()
            return
        end

        setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**, **%s**)'):format(functionName, v), 'district')) 
        setElementData(localPlayer, 'player:gameTime', 1)
        
        crashPlayer()
    end

    return 'skip'
end

addDebugHook('preFunction', onPreFunction, blockedFunctions)

function loadInterface()
    return 1
end