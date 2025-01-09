local function updatePlayerOnStretcher(player, object)
    local x, y, z = getElementPosition(object)
    local rx, ry, rz = getElementRotation(object)

    setElementPosition(player, x, y, z + 0.6)
    setElementRotation(player, -90, 0, rz, 'default', true)
end

local function updatePlayerOnPlank(player, object)
    local x, y, z = getElementPosition(object)
    local rx, ry, rz = getElementRotation(object)

    setElementPosition(player, x, y, z + 0.1)
    setElementRotation(player, -90, 0, rz + 180, 'default', true)
end

addEventHandler('onClientPreRender', root, function()
    for _, player in ipairs(getElementsByType('player')) do
        local stretcher = getElementData(player, 'player:stretcher')
        if stretcher and isElement(stretcher) then
            updatePlayerOnStretcher(player, stretcher)
        end

        local plank = getElementData(player, 'player:plank')
        if plank and isElement(plank) then
            updatePlayerOnPlank(player, plank)
        end
    end
end)