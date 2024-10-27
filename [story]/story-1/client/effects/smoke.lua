local smokeShader = false
local smoke = {}
local shadersData = {}

function getSmokeShader()
    -- return dxCreateShader('data/shaders/smoke.fx')
    if not smokeShader then
        smokeShader = dxCreateShader('data/shaders/smoke.fx')
    end

    return smokeShader
end

function createSmoke(shader, x, y, z, vx, vy, vz, size, fallSpeed, fallSpeedHorizontal)
    local object = createObject(2000, x, y, z)
    setObjectScale(object, size/40)
    setElementCollisionsEnabled(object, false)
    local lod = assignLOD(object)
    -- engineApplyShaderToWorldTexture(shader, '*', object)
    -- engineApplyShaderToWorldTexture(shader, '*', lod)
    setObjectCustomModel(object, 'smoke')

    smoke[object] = {
        x = x,
        y = y,
        z = z,
        vx = vx,
        vy = vy,
        vz = vz,
        size = size,
        fallSpeed = fallSpeed or 1,
        fallSpeedHorizontal = fallSpeedHorizontal or 1,
        object = object
    }

    return object, lod
end

function destroySmoke(object)
    setElementAlphaWithLOD(object, 0)
    local lod = getLowLODElement(object)
    if lod then
        destroyElement(lod)
    end
    destroyElement(object)
    smoke[object] = nil
end

function updateSmoke(dt)
    local dts = (1000-dt*0.5/settings.eventSpeed)/1000
    local dtm = (1000-dt*5/settings.eventSpeed)/1000
    for object, data in pairs(smoke) do
        if data then
            local nextX, nextY, nextZ = data.x, data.y, data.z
            local downX, downY, downZ = data.x, data.y, data.z - data.size/2

            -- if isLineOfSightClear(data.x, data.y, data.z, downX, downY, downZ, true, false, false, true, false, false, false) then
            --     -- data.z = data.z - 0.1
            --     -- data.vz = data.vz - 0.007
            --     data.vz = data.vz - 0.007 * data.fallSpeed
            -- else
                data.vz = data.vz + 0.003
            -- end

            data.vx = data.vx * (1-(1-dts)*data.fallSpeedHorizontal)
            data.vy = data.vy * (1-(1-dts)*data.fallSpeedHorizontal)
            data.vz = data.vz * (1-(1-dtm)*data.fallSpeed)

            local nextX = data.x + data.vx * dts
            local nextY = data.y + data.vy * dts
            local nextZ = data.z + data.vz * dts

            -- if is under ground go to ground z
            -- local groundZ = getGroundPosition(nextX, nextY, nextZ + 10)
            -- if nextZ - data.size/2 < groundZ then
            --     -- nextZ = groundZ
            --     data.vz = ((groundZ + data.size/2) - data.z) / 10
            -- end

            data.x = nextX
            data.y = nextY
            data.z = nextZ

            setElementPosition(object, data.x, data.y, data.z)
        end
    end

    for shader, data in pairs(shadersData) do
        local liveTime = getTickCount() - data.startTime
        local alpha = 1 - math.max(liveTime / data.liveTime, 0)
        local appearSize = math.min(1, liveTime / data.appearTime)

        for i, smoke in ipairs(data.smoke) do
            setElementAlphaWithLOD(smoke, alpha * 255)
        end

        if liveTime > data.liveTime then
            for _, smoke in ipairs(data.smoke) do
                destroySmoke(smoke)
            end

            -- destroyElement(shader)
            shadersData[shader] = nil
        end
    end
end

addEventHandler('onClientPreRender', root, updateSmoke)

function createSmokeExplosion(options)
    -- local shader = getSmokeShader()
    local i = #shadersData + 1
    shadersData[i] = {
        liveTime = options.liveTime,
        startTime = getTickCount(),
        smoke = {},
        smokeSizes = {},
        appearTime = options.appearTime or 800
    }

    -- dxSetShaderValue(shader, 'dissolvePosition', options.position)
    -- dxSetShaderValue(shader, 'dissolveSize', options.drawSize * 10)
    for c=1,options.count do
        local vx = math.random(-100, 100) / 1000 * options.size
        local vy = math.random(-100, 100) / 1000 * options.size
        local vz = math.random(50, 60) / 1000 * options.size

        if options.startVelocity then
            vx = vx + options.startVelocity[1]
            vy = vy + options.startVelocity[2]
            vz = vz + options.startVelocity[3]
        end

        local size = math.random(options.minSize * 100, options.maxSize * 100) / 100
        local smoke = createSmoke(shader, options.position[1], options.position[2], options.position[3], vx, vy, vz, size, options.fallSpeed, options.fallSpeedHorizontal)
        
        table.insert(shadersData[i].smoke, smoke)
        table.insert(shadersData[i].smokeSizes, size)
    end
end

addEvent('story:playExplosion', true)
addEventHandler('story:playExplosion', resourceRoot, function(x, y, z, vx, vy, vz, sound)
    createSmokeExplosion({
        position = {x, y, z},
        count = 30,
        minSize = 4.5,
        maxSize = 17.5,
        size = 6,
        drawSize = 7,
        fallSpeed = 1.5,
        liveTime = 15000,
        startVelocity = {vx, vy, vz}
    })

    if sound then
        local sound = playSound3D('data/sounds/crash.wav', x, y, z)
        setSoundMaxDistance(sound, 1500)
        setSoundMinDistance(sound, 300)
        setSoundVolume(sound, 3)
    end
end)

-- createSmokeExplosion(463.20001, 1528.1, 46, 100, 2.5, 12.5, 6, 7, 0.5)
-- createSmokeExplosion({
--     position = {463.20001, 1528.1, 46},
--     count = 100,
--     minSize = 2.5,
--     maxSize = 12.5,
--     size = 6,
--     drawSize = 7,
--     fallSpeed = 0.5,
--     liveTime = 5000
-- })

-- setTimer(function()
--     createSmokeExplosion({
--         position = {463.20001, 1528.1, 66},
--         count = 25,
--         minSize = 2.5,
--         maxSize = 12.5,
--         size = 6,
--         drawSize = 7,
--         fallSpeed = 3,
--         liveTime = 5000
--     })
-- end, 500, 5)

-- local x, y, z = getElementPosition(localPlayer)
-- local smoke = createSmoke(450.20001, 1528.1, 35, -1, 0, 0, 20)
-- local smoke = createSmoke(450.20001, 1521.1, 35, -1, 0, 0, 8)
-- -- move it on x by 0.01 every frame
-- addEventHandler('onClientRender', root, function()
--     x = x + 0.1
--     -- setElementPosition(smoke, x, y, z)
-- end)