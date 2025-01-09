moneyPerPhoto = math.random(200, 500)
pickups = {
    {1000.131, -1454.277, 13.586}
}

if not localPlayer then
    for i, v in pairs(pickups) do
        createPickup(v[1], v[2], v[3], 2, 43, 100)
    end
end

function isElementInPhotoArea(element)
    if isElementOnScreen(element) then
        local nx, ny, nz = getPedWeaponMuzzlePosition(localPlayer)
        local ignoredElement = false
        if getElementType(element) == 'player' then
            ignoredElement = getPedOccupiedVehicle(element)
        end

        if element ~= localPlayer and isElementOnScreen(element) then
            local px, py, pz = getElementPosition(element)
            local hit, _, _, _, hitElement = processLineOfSight(nx, ny, nz, px, py, pz, true, true, true, true, true, true, true, true, ignoredElement)

            if not hit or (hitElement and hitElement == element) then
                return true
            end
        end
    end
    
    return false
end

function getRandomPlayerInDistanceWithIgnored(player, maxDistance, ignorePlayers)
    local x, y, z = getElementPosition(player)
    local players = {}

    for i, v in pairs(getElementsByType('player')) do
        if v ~= player and not table.includes(ignorePlayers or {}, v) then
            local px, py, pz = getElementPosition(v)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)

            if distance < maxDistance then
                table.insert(players, v)
            end
        end
    end

    if #players > 0 then
        return players[math.random(1, #players)]
    end

    return nil
end

function table.includes(table, value)
    for i, v in pairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

function table.removeElement(table, element)
    for i, v in pairs(table) do
        if v == element then
            table.remove(table, i)
            return true
        end
    end

    return false
end