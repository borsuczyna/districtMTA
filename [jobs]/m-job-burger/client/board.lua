addEvent('jobs:burger:board', true)

local boards = {}

addEventHandler('jobs:burger:board', resourceRoot, function(boardId, objectHash, model)
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
        
        if model == 'burger/meat-overcooked' then
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
    for i, board in ipairs(boards) do
        if isElement(board) then
            destroyElement(board.object)
            if board.effect then
                destroyElement(board.effect)
            end
        end
    end
end