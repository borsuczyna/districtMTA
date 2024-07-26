local blockedFunctions = {
    'addDebugHook', 'xpcall', 'pcall', 'loadstring',
    'createProjectile', 'detonateSatchels'
}

function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)

    for _, v in pairs({...}) do
        if #(''..tostring(v)..'\n') > 1000 then
            crashPlayer()
            ban(localPlayer, ('tried to execute a code `%s` using **%s** from resource `%s`'):format(tostring(v), functionName, resourceName))
            
            return
        end

        crashPlayer()
        ban(localPlayer, ('tried to execute a code `%s` using **%s** from resource `%s`'):format(tostring(v), functionName, resourceName))
    end

    return 'skip'
end

addDebugHook('preFunction', onPreFunction, blockedFunctions)