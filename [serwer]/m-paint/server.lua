addEvent('paint:takeSpray')
addEvent('paint:fire', true)

addEventHandler('paint:takeSpray', root, function(hash, player, color, type)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if getPlayerMoney(player) < 500 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie stać cię na zakup spray\'u.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'paint', ('Zakup spray\'u o kolorze %s'):format(color), -500)

    local typeString = nil
    if tonumber(type) == 1 then
        typeString = 'podstawowy'
    elseif tonumber(type) == 2 then
        typeString = 'dodatkowy'
    elseif tonumber(type) == 3 then
        typeString = 'felg'
    else
        typeString = 'rantów'
    end

    exports['m-inventory']:addPlayerItem(player, 'spray', 1, {color = color, type = typeString})

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zakupiono spray\'a, znajdziesz go w swoim ekwipunku.'})
end)

addEventHandler('paint:fire', resourceRoot, function(x, y, z)
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local paint = getElementData(client, 'player:paint')
    if not paint then return end

    local vehicle = getClosestVehicle(x, y, z, 5)
    if not vehicle then return end

    local vUid = getElementData(vehicle, 'vehicle:uid')
    if not vUid then
        exports['m-notis']:addNotification(client, 'warning', 'Lakiernia', 'Możesz malować tylko prywatne pojazdy.')
        return
    end

    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner ~= uid then
        exports['m-notis']:addNotification(client, 'warning', 'Lakiernia', 'Nie jesteś właścicielem tego pojazdu.')
        return
    end

    local r, g, b = hexToRGB(paint.color)
    local vr, vg, vb = 0, 0, 0
    local r1, g1, b1, r2, g2, b2, r3, g3, b3 = getVehicleColor(vehicle, true)

    if paint.type == 'podstawowy' then
        vr, vg, vb = r1, g1, b1
    elseif paint.type == 'dodatkowy' then
        vr, vg, vb = r2, g2, b2
    elseif paint.type == 'felg' then
        vr, vg, vb = r3, g3, b3
    end

    if r == vr and g == vg and b == vb then
        exports['m-notis']:addNotification(client, 'warning', 'Lakiernia', 'Ten kolor jest już na pojeździe.')
        return
    end

    local function interpolate(a, b)
        -- if a > b then
        --     return a - 1
        -- elseif a < b then
        --     return a + 1
        -- end

        local diff = b - a
        if diff == 0 then return a end

        if diff > 2 then
            return a + 2
        elseif diff < -2 then
            return a - 2
        end

        return a + diff
    end

    vr = interpolate(vr, r)
    vg = interpolate(vg, g)
    vb = interpolate(vb, b)

    if paint.type == 'podstawowy' then
        setVehicleColor(vehicle, vr, vg, vb, r2, g2, b2, r3, g3, b3)
    elseif paint.type == 'dodatkowy' then
        setVehicleColor(vehicle, r1, g1, b1, vr, vg, vb, r3, g3, b3)
    elseif paint.type == 'felg' then
        setVehicleColor(vehicle, r1, g1, b1, r2, g2, b2, vr, vg, vb)
    end
end)

function getClosestVehicle(x, y, z, distance)
    local vehicles = getElementsByType('vehicle')
    local closest = nil
    local distance = distance or 10

    for k, v in ipairs(vehicles) do
        local vx, vy, vz = getElementPosition(v)
        local dist = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
        if dist < distance then
            distance = dist
            closest = v
        end
    end

    return closest
end

function hexToRGB(hex)
    hex = hex:gsub('#', '')
    return tonumber('0x' .. hex:sub(1, 2)), tonumber('0x' .. hex:sub(3, 4)), tonumber('0x' .. hex:sub(5, 6))
end