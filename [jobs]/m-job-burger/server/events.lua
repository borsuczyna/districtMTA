local carryObjects = {
    meat = 'meat',
    salad = 'salad-box',
}

function useCarryItem(client, event)
    local carrying = getPlayerCarryObject(client)
    if carrying then return end

    makePlayerCarryObject(client, 'burger/' .. carryObjects[event])
end

addEvent('jobs:burger:clickElement', true)
addEventHandler('jobs:burger:clickElement', resourceRoot, function(event, objectHash)
    if event == 'trash' then
        stopPlayerCarryObject(client)
    elseif event == 'meat' or event == 'salad' then
        useCarryItem(client, event)
    elseif event == 'board-1' or event == 'board-2' then
        local boardId = event == 'board-1' and 1 or 2
        useBoard(client, objectHash, boardId)
    elseif event == 'grill-1' or event == 'grill-2' then
        local grillId = event == 'grill-1' and 1 or 2
        useGrill(client, objectHash, grillId)
    elseif event == 'bun' then
        useBun(client, objectHash)
    elseif event == 'fryer-1' or event == 'fryer-2' then
        local fryerId = event == 'fryer-1' and 1 or 2
        useFryer(client, objectHash, fryerId)
    end
end)