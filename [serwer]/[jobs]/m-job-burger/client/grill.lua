addEvent('jobs:burger:grill', true)
addEvent('jobs:burger:grillBurn', true)
addEvent('jobs:burger:grilled', true)

local grills = {}
local grillsData = {}
local effects = {}
local grillSounds = {}

local function setEffect(grillId, name, density)
    local x, y, z = getElementPosition(grills[grillId])
    local effect = createEffect(name, x, y, z)
    setEffectDensity(effect, density or 0.2)
    setElementDimension(effect, getElementDimension(localPlayer))

    effects[grillId] = effect
end

addEventHandler('jobs:burger:grill', resourceRoot, function(grillId, objectHash, data)
    if grills[grillId] then
        destroyElement(grills[grillId])
    end
    
    if effects[grillId] then
        destroyElement(effects[grillId])
    end

    if grillSounds[grillId] and isElement(grillSounds[grillId]) then
        stopSound(grillSounds[grillId])
    end

    grillsData[grillId] = nil
    effects[grillId] = nil
    grills[grillId] = nil
    grillSounds[grillId] = nil

    if objectHash then
        local grillObject = exports['m-jobs']:getObjectByHash(objectHash)
        if not grillObject then return end

        local layData = settings.layPositions['burger/grill-meat']
        local ax, ay, az = unpack(layData.position)
        local arx, ary, arz = unpack(layData.rotation or {0, 0, 0})

        local x, y, z = getPositionFromElementOffset(grillObject, ax, ay, az)
        local rx, ry, rz = getElementRotation(grillObject)
        local object = createObject(1337, x, y, z + 0.25, rx + arx, ry + ary, rz + arz)
        setElementData(object, 'element:model', 'burger/meat')
        setObjectScale(object, layData.scale)
        setElementDimension(object, getElementDimension(localPlayer))
        setElementCollisionsEnabled(object, false)
        moveObject(object, 90, x, y, z)

        grills[grillId] = object
        grillsData[grillId] = data
        grillSounds[grillId] = playSound('data/grill.wav')
        playSound('data/click.wav')

        setEffect(grillId, 'vent', 0.8)
    end
end)

addEventHandler('jobs:burger:grillBurn', resourceRoot, function(grillId, objectHash)
    if grills[grillId] and isElement(grills[grillId]) then
        setElementData(grills[grillId], 'element:model', 'burger/meat-overcooked')
        setEffect(grillId, 'fire', 0.2)
        playSound('data/burn.wav')
    end
end)

addEventHandler('jobs:burger:grilled', resourceRoot, function(grillId)
    if grills[grillId] and isElement(grills[grillId]) then
        setElementData(grills[grillId], 'element:model', 'burger/meat-cooked')
    end
end)

function drawGrillProgress(grill, data, serverTick)
    local start = data.start
    local finish = data.finish
    local burn = data.burn

    local progress = (serverTick - start) / (finish - start)
    local burning = progress >= 1
    if burning then
        progress = (serverTick - finish) / (burn - finish)
    end

    local clampedProgress = math.min(math.max(progress, 0), 1)

    local x, y, z = getElementPosition(grill)
    local sx, sy = getScreenFromWorldPosition(x, y, z + 0.5)
    if not sx or not sy then return end

    local bounceAnimation = 1
    local color = 0xFFFFFFFF

    if burning then
        local burnProgress = math.min(clampedProgress * 5, 1)
        local animProgress = getEasingValue(burnProgress, 'OutBounce')
        bounceAnimation = 1 + animProgress * 0.5

        local r, g, b = interpolateBetween(255, 255, 255, 255, 0, 0, burnProgress, 'Linear')
        color = tocolor(r, g, b, 255)

        local fr, fg, gb = interpolateBetween(255, 100, 100, 255, 0, 0, (progress * 5) % 1, 'CosineCurve')
        local jump = getEasingValue((progress * 5) % 1, 'CosineCurve')
        animProgress = animProgress + jump * 0.2

        dxDrawImage(sx - 18/zoom * animProgress, sy - 18/zoom * animProgress, 36/zoom * animProgress, 36/zoom * animProgress, 'data/flame.png', 0, 0, 0, tocolor(fr, fg, gb, 255))
    end
    
    dxDrawImage(sx - 26/zoom * bounceAnimation, sy - 26/zoom * bounceAnimation, 52/zoom * bounceAnimation, 52/zoom * bounceAnimation, 'data/stoper-bg.png', 0, 0, 0, 0x99FFFFFF)
    drawCircleImage(sx - 26/zoom * bounceAnimation, sy - 26/zoom * bounceAnimation, 52/zoom * bounceAnimation, 52/zoom * bounceAnimation, 'data/stoper.png', 0, 360 * clampedProgress, color)
end

function updateGrillsCook()
    updateFryersCook()
    updateColaData()
    renderNpcOrders()

    local serverTick = getServerTick()
    
    for i, grill in pairs(grills) do
        if not isElement(grill) then
            grills[i] = nil
            grillsData[i] = nil
            effects[i] = nil
            return
        end

        local data = grillsData[i]
        if not data then return end

        drawGrillProgress(grill, data, serverTick)
    end
end

function clearGrills()
    for i, grill in ipairs(grills) do
        if isElement(grill) then
            destroyElement(grill)
        end
    end

    for i, effect in ipairs(effects) do
        if isElement(effect) then
            destroyElement(effect)
        end
    end

    for i, sound in ipairs(grillSounds) do
        if isElement(sound) then
            stopSound(sound)
        end
    end

    grills = {}
    grillsData = {}
    effects = {}
end

local effectNames = {
	"blood_heli", "boat_prop", "camflash", "carwashspray", "cement", "cloudfast", "coke_puff", "coke_trail", "cigarette_smoke",
	"explosion_barrel", "explosion_crate", "explosion_door", "exhale", "explosion_fuel_car", "explosion_large", "explosion_medium",
	"explosion_molotov", "explosion_small", "explosion_tiny", "extinguisher", "flame", "fire", "fire_med", "fire_large", "flamethrower",
	"fire_bike", "fire_car", "gunflash", "gunsmoke", "insects", "heli_dust", "jetpack", "jetthrust", "nitro", "molotov_flame",
	"overheat_car", "overheat_car_electric", "prt_blood", "prt_boatsplash", "prt_bubble", "prt_cardebris", "prt_collisionsmoke",
	"prt_glass", "prt_gunshell", "prt_sand", "prt_sand2", "prt_smokeII_3_expand", "prt_smoke_huge", "prt_spark", "prt_spark_2",
	"prt_splash", "prt_wake", "prt_watersplash", "prt_wheeldirt", "petrolcan", "puke", "riot_smoke", "spraycan", "smoke30lit", "smoke30m",
	"smoke50lit", "shootlight", "smoke_flare", "tank_fire", "teargas", "teargasAD", "tree_hit_fir", "tree_hit_palm", "vent", "vent2",
	"water_hydrant", "water_ripples", "water_speed", "water_splash", "water_splash_big", "water_splsh_sml", "water_swim", "waterfall_end",
	"water_fnt_tme", "water_fountain", "wallbust", "WS_factorysmoke"
}