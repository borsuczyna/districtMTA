addEvent('jobs:burger:board', true)
addEvent('jobs:burger:playSound', true)

local boards = {}

addEventHandler('jobs:burger:board', resourceRoot, function(boardId, objectHash, model)
    playSound('data/click.wav')
    
    if boards[boardId] then
        destroyElement(boards[boardId].object)
        if boards[boardId].effect then
            destroyElement(boards[boardId].effect)
        end

        boards[boardId] = nil
    end

    if objectHash and model then
        local boardObject = exports['m-jobs']:getObjectByHash(objectHash)
        if not boardObject then return end

        local layData = settings.layPositions[model]
        local ax, ay, az = unpack(layData.position)

        local x, y, z = getPositionFromElementOffset(boardObject, ax, ay, az)
        local object = createObject(1337, x, y, z)
        setElementData(object, 'element:model', model)
        setObjectScale(object, layData.scale)
        setElementDimension(object, getElementDimension(localPlayer))
        setElementCollisionsEnabled(object, false)

        local effect;
        
        if model == 'burger/meat-overcooked' or model == 'burger/fries-burned' then
            effect = createEffect('fire', x, y, z, 0, 0, 0)
            setEffectDensity(effect, 0.2)
        end

        boards[boardId] = {
            object = object,
            effect = effect
        }
    end
end)

function clearBoards()
    for i, board in pairs(boards) do
        if board.object then
            destroyElement(board.object)
        end

        if board.effect then
            destroyElement(board.effect)
        end
    end
end

addEventHandler('jobs:burger:playSound', resourceRoot, function(sound)
    playSound('data/' .. sound .. '.wav')
end)