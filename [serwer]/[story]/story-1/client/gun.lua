addEvent('story:gunAttach', true)
addEvent('story:gunFire', true)

local gun = false
local sx, sy = guiGetScreenSize()
local lastPitch, lastYaw, lastFire = 0, 0, 0
local traces = {}

function getUfos()
    local objects = getElementsByType('object', resourceRoot)
    local ufos = {}

    for i, object in ipairs(objects) do
        local model = getElementData(object, 'element:model')
        if model == 'ufo' or model == 'ufo2' then
            table.insert(ufos, {object, model == 'ufo2' and 70 or 30})
        end
    end

    return ufos
end

function doesLineIntersectSphere(sx, sy, sz, ex, ey, ez, sphereX, sphereY, sphereZ, sphereSize)
    -- Vector from the start of the line to the end
    local dx = ex - sx
    local dy = ey - sy
    local dz = ez - sz

    -- Vector from the start of the line to the sphere center
    local fx = sx - sphereX
    local fy = sy - sphereY
    local fz = sz - sphereZ

    -- Coefficients for the quadratic equation
    local a = dx * dx + dy * dy + dz * dz
    local b = 2 * (fx * dx + fy * dy + fz * dz)
    local c = fx * fx + fy * fy + fz * fz - sphereSize * sphereSize

    -- Calculate discriminant to determine intersection
    local discriminant = b * b - 4 * a * c

    -- If discriminant is negative, no intersection
    if discriminant < 0 then
        return false
    else
        -- Discriminant is non-negative, there is an intersection
        return true
    end
end

function doesLineIntersectAnyUfo(sx, sy, sz, ex, ey, ez)
    local ufos = getUfos()
    for i, ufo in ipairs(ufos) do
        local x, y, z = getElementPosition(ufo[1])
        if doesLineIntersectSphere(sx, sy, sz, ex, ey, ez, x, y, z, ufo[2]) then
            return ufo[1]
        end
    end
    return false
end

function updateGunAttach()
    local x, y, z, lx, ly, lz = getCameraMatrix()
    local pitch, yaw = findRotation3D({x, y, z}, {lx, ly, lz})

    local nyaw = interpolateRotation(lastYaw, yaw + 90, 0.05)
    local npitch = interpolateRotation(lastPitch, -pitch, 0.05)

    setElementRotation(gun.a, 0, 0, nyaw)
    setElementRotation(localPlayer, 0, 0, nyaw + 180, 'default', true)
    setElementRotation(gun.b, npitch, 0, nyaw)

    npitch = math.min(npitch, 10)
    lastPitch, lastYaw = npitch, nyaw
    setElementData(gun.b, 'pitch', npitch)
    
    -- dxDrawImage(sx/2 - 75, sy/2 - 75, 150, 150, 'data/textures/crosshair.png', 0, 0, 0, tocolor(255, 255, 255, 60))
    
    local stx, sty, stz = getPositionFromElementOffset(gun.b, 0, -3, 0)
    local tx, ty, tz = getPositionFromElementOffset(gun.b, 0, -3000, 0)
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(tx, ty, tz, stx, sty, stz, true, false, false, true, false, false, false, false, localPlayer, false, false)
    if hit then
        tx, ty, tz = hitX, hitY, hitZ
    end

    local hitUfo = doesLineIntersectAnyUfo(stx, sty, stz, tx, ty, tz)
    local destroyPos = false

    if hitUfo then
        local x, y, z = getElementPosition(hitUfo)
        x, y = x + math.random(-300, 300), y + math.random(-300, 300)
        z = getGroundPosition(x, y, z)
        destroyPos = {x, y, z}
    end

    if getKeyState('mouse1') and getTickCount() - lastFire > 200 then
        -- local distance = getDistanceBetweenPoints3D(stx, sty, stz, tx, ty, tz)
        local player = getAnyPlayerInDistance(tx, ty, tz, 20)
        if not player then
            triggerServerEvent('story:gunFire', resourceRoot, stx, sty, stz, tx, ty, tz, hitUfo, destroyPos)
            lastFire = getTickCount() + 2000
            -- playSound('data/sounds/turret.wav')
        end
    end
end

function updateGunCrosshair()
    local stx, sty, stz = getPositionFromElementOffset(gun.b, 0, -3, 0)
    local tx, ty, tz = getPositionFromElementOffset(gun.b, 0, -3000, 0)
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(tx, ty, tz, stx, sty, stz, true, false, false, true, false, false, false, false, localPlayer, false, false)
    if hit then
        tx, ty, tz = hitX, hitY, hitZ
    end

    local txs, tys = getScreenFromWorldPosition(tx, ty, tz)
    if txs then
        dxDrawImage(txs - 74, tys - 74, 150, 150, 'data/textures/crosshair.png', 0, 0, 0, tocolor(0, 0, 0, 100))
        dxDrawImage(txs - 75, tys - 75, 150, 150, 'data/textures/crosshair.png', 0, 0, 0, tocolor(255, 255, 255, 255))
    end
end

addEventHandler('story:gunAttach', resourceRoot, function(a, b)
    gun = {a=a,b=b}
    addEventHandler('onClientPreRender', root, updateGunAttach)
    addEventHandler('onClientRender', root, updateGunCrosshair)
end)

function getAnyPlayerInDistance(x, y, z, distance)
    local players = getElementsByType('player', root, true)
    for i, player in ipairs(players) do
        local px, py, pz = getElementPosition(player)
        local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
        if dist < distance then
            return player
        end
    end
    return false
end

function updateTurret(a, b, player)
    local rx, ry, rz = getElementRotation(player)
    setElementRotation(a, 0, 0, rz-180)

    local pitch = getElementData(b, 'pitch') or 0
    setElementRotation(b, pitch, 0, rz+180)
end

function updatePlayersAircraft()
    local players = getElementsByType('player', root, true)
    for i, player in ipairs(players) do
        local elements = getElementData(player, 'player:antiAircraftGun')
        if player ~= localPlayer and elements and isElement(elements[1]) and isElement(elements[2]) then
            updateTurret(elements[1], elements[2], player)
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('onClientPreRender', root, updatePlayersAircraft)
end)

addEventHandler('story:gunFire', resourceRoot, function(player, x, y, z, tx, ty, tz)
    local sound = playSound3D('data/sounds/turret.wav', x, y, z)
    setSoundMinDistance(sound, 10)
    setSoundMaxDistance(sound, 100)
    setSoundVolume(sound, 0.5)

    local elements = getElementData(player, 'player:antiAircraftGun')
    if not elements then return end

    if player == localPlayer then
        lastFire = getTickCount() - getPlayerPing(localPlayer)
    end

    updateTurret(elements[1], elements[2], player)
    local x, y, z = getPositionFromElementOffset(elements[2], -0.04, -1.1, 0.1)
    local pitch, yaw = findRotation3D({x, y, z}, {tx, ty, tz})
    createEffect('gunflash', x, y, z, pitch-90, 0, -yaw-90)
    createEffect('gunsmoke', x, y, z, pitch-90, 0, -yaw-90)

    table.insert(traces, {x, y, z, tx, ty, tz, getTickCount()})
    
    local cx, cy, cz = getCameraMatrix()
    local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)
    local shakeForce = (1 - distance / 20) * 0.3
    shakeCamera(shakeForce)
end)

addEventHandler('onClientPreRender', root, function()
    for i, trace in ipairs(traces) do
        local x, y, z, tx, ty, tz, start = unpack(trace)
        local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
        local progress = (getTickCount() - start) / (distance * 2.5)
        local alpha = interpolateBetween(155, 0, 0, 0, 0, 0, progress, 'Linear')

        local sx, sy, sz = interpolateBetween(x, y, z, tx, ty, tz, math.max(progress - 0.01, 0), 'Linear')
        local ex, ey, ez = interpolateBetween(x, y, z, tx, ty, tz, math.min(progress + 0.02, 1), 'Linear')
        dxDrawLine3D(sx, sy, sz, ex, ey, ez, tocolor(255, 255, 100, alpha), 2)
        if alpha == 0 then
            table.remove(traces, i)
        end
    end
end)