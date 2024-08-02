local blockedFunctions = {
    'addDebugHook', 'call', 'xpcall', 'pcall', 'loadstring', 'setDebugViewActive',
    'createProjectile', 'detonateSatchels'
}

local function crashPlayer()
    while true do
        dxDrawText(string.rep(':(', 2^20), 0, 0)
    end
end

function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)

    for _, v in pairs({...}) do
        if #(''..tostring(v)..'\n') > 1000 then
            setElementData(localPlayer, 'player:gameTime', 1)
            crashPlayer()

            return
        end

        setElementData(localPlayer, 'player:gameTime', 1)
        crashPlayer()
    end

    return 'skip'
end

addDebugHook('preFunction', onPreFunction, blockedFunctions)

function loadInterface()
    return 1
end