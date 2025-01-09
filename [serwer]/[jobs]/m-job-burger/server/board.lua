function getBoardKey(player, boardId)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    return ('player:%d:board:%d'):format(uid, boardId)
end

function getPlayerBoardData(player, boardId)
    local key = getBoardKey(player, boardId)
    if not key then return end

    return exports['m-jobs']:getLobbyData(player, key)
end

function useBoard(client, objectHash, boardId)
    local boardData = getPlayerBoardData(client, boardId)
    local key = getBoardKey(client, boardId)
    
    local carryData = getPlayerCarryObject(client)
    
    if not boardData then
        if not carryData then
            playClientSound(client, 'cant')
            return
        end

        stopPlayerCarryObject(client)

        exports['m-jobs']:setLobbyData(client, key, {
            model = carryData.model,
            data = carryData.data,
            options = carryData.options,
        })

        triggerClientEvent(client, 'jobs:burger:board', resourceRoot, boardId, objectHash, carryData.model)
    else
        local carryItem = nil
        if carryData then
            carryItem = {
                model = carryData.model,
                data = carryData.data,
                options = carryData.options,
            }
        end
        
        makePlayerCarryObject(client, boardData.model, boardData.data, boardData.options)
        exports['m-jobs']:setLobbyData(client, key, carryItem)

        triggerClientEvent(client, 'jobs:burger:board', resourceRoot, boardId, carryItem and objectHash or false, carryItem and carryItem.model or false)
    end
end