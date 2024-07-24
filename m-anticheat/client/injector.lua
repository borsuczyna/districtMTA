function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)

    for _, v in pairs({...}) do
        if #(''..tostring(v)..'\n') > 1000 then
            ban(localPlayer, ('tried to execute a code `%s` using **%s** from resource `%s`'):format(tostring(v), functionName, resourceName))
            return
        end

        ban(localPlayer, ('tried to execute a code `%s` using **%s** from resource `%s`'):format(tostring(v), functionName, resourceName))
    end

    return 'skip'
end

function ban(player, reason)
    print('TODO: Ban player '..getPlayerName(player)..' for '..reason)
end

addDebugHook('preFunction', onPreFunction, {'xpcall', 'pcall', 'loadstring'})

function onPreEvent(sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)

    for _, v in pairs({...}) do
        ban(localPlayer, ('tried to execute a code `%s` using **%s** from resource `%s`'):format(tostring(v), eventName, resourceName))
    end
end
addDebugHook('preEvent', onPreEvent, {'onClientPaste'})

addCommandHandler('testuse', function(plr,cmd,...)
    loadstring('outputChatBox("random")')()
end)