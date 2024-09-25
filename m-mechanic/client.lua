addEvent('mechanic:showRepairWindow', true)
addEvent('mechanic:hide', true)
addEvent('mechanic:repair', true)
addEvent('mechanic:respond', true)
addEvent('mechanic:serverTickResponse', true)
addEvent('mechanic:gateSound', true)

local mechanicUILoaded, mechanicUIVisible, mechanicHideTimer = false, false, false
local repairData = nil
local serverTick = {
    clientStart = 0,
    serverStart = 0
}

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('mechanic', 'play-animation', true)
    exports['m-ui']:setInterfaceData('mechanic', 'repairs', repairData.repairs)
end

addEventHandler('interface:load', root, function(name)
    if name == 'mechanic' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showMechanicInterface()
    exports['m-ui']:loadInterfaceElementFromFile('mechanic', 'm-mechanic/data/interface.html')
end

function setMechanicUIVisible(visible)
    if mechanicHideTimer and isTimer(mechanicHideTimer) then
        killTimer(mechanicHideTimer)
    end

    mechanicUIVisible = visible

    if not visible and isTimer(mechanicTimer) then
        killTimer(mechanicTimer)
    end

    showCursor(visible, false)

    if not mechanicUILoaded and visible then
        showMechanicInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('mechanic', 'play-animation', false)
            mechanicHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('mechanic')
                mechanicUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('mechanic', true)
            setInterfaceData()
            mechanicUIVisible = true
        end
    end
end

function toggleMechanicUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setMechanicUIVisible(not mechanicUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleMechanicUI()
    addEventHandler('interfaceLoaded', root, function()
        mechanicUILoaded = false
        setMechanicUIVisible(mechanicUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('mechanic')
end)

-- local renderTarget = dxCreateRenderTarget(900, 200, true)
local renderTargets = {}

local function getRenderTarget(element)
    if not renderTargets[element] then
        renderTargets[element] = dxCreateRenderTarget(900, 200, true)
    end

    return renderTargets[element]
end

local function destroyRenderTarget(element)
    if renderTargets[element] then
        destroyElement(renderTargets[element])
        renderTargets[element] = nil
    end
end

local function renderRepairShop(element)
    local x, y, z = getCameraMatrix()
    local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(element))
    if distance > 80 then return end
    
    local position = getElementData(element, 'repair:data')
    local state = getElementData(element, 'repair:state')
    local colshape = getElementData(element, 'repair:colShape')
    local renderTarget = getRenderTarget(element)

    dxSetRenderTarget(renderTarget, true)
    dxDrawRectangle(0, 0, 900, 200, tocolor(0, 0, 0, 255))

    if state == 0 then
        dxDrawText('Wolne stanowisko', 0, 0, 900, 200, tocolor(255, 255, 255), 6, 'default-bold', 'center', 'center')
    elseif state == 1 then
        local vehicle = getElementData(element, 'repair:vehicle')
        if isElement(vehicle) and getTickCount() % 3000 > 2000 then
            dxDrawText(exports['m-models']:getVehicleName(vehicle), 0, 0, 900, 200, tocolor(255, 255, 255), 6, 'default-bold', 'center', 'center')
        else
            dxDrawText('Zajęte stanowisko', 0, 0, 900, 200, tocolor(255, 255, 255), 6, 'default-bold', 'center', 'center')
        end
    elseif state == 2 then
        dxDrawText('Za dużo pojazdów\nna stanowisku', 0, 0, 900, 200, tocolor(255, 255, 255), 4, 'default-bold', 'center', 'center')
    elseif state == 3 then
        local endTime = getElementData(element, 'repair:time')
        local vehicle = getElementData(element, 'repair:vehicle')
        if not isElement(vehicle) then
            dxDrawText('Błąd: pojazd nie istnieje', 0, 0, 900, 200, tocolor(255, 255, 255), 6, 'default-bold', 'center', 'center')
            dxSetRenderTarget()
            return
        end

        local timeLeft = endTime - getServerTick()

        local seconds = math.max(math.floor(timeLeft / 1000), 0)
        local minutes = math.floor(seconds / 60)
        seconds = seconds - minutes * 60

        if getTickCount() % 3000 > 1500 then
            dxDrawText(string.format('Pozostały czas: %02d:%02d', minutes, seconds), 0, 0, 900, 200, tocolor(255, 255, 255), 5, 'default-bold', 'center', 'center')
        else
            dxDrawText('Pojazd w naprawie\n' .. exports['m-models']:getVehicleName(vehicle), 0, 0, 900, 200, tocolor(255, 255, 255), 4, 'default-bold', 'center', 'center')
        end
    end

    dxSetRenderTarget()

    dxDrawMaterialLine3D(
        position[1], position[2], position[3] + 0.4,
        position[1], position[2], position[3],
        renderTarget, 1.9, tocolor(255, 255, 255), 'prefx',
        position[1] + position[4][1], position[2] + position[4][2], position[3] + 0.2
    )
end

addEventHandler('onClientElementStreamOut', root, function()
    if getElementType(source) == 'repair:render' then
        destroyRenderTarget(source)
    end
end)

local function renderRepairShops()
    local renderElements = getElementsByType('repair:render', resourceRoot, true)
    for i, element in ipairs(renderElements) do
        renderRepairShop(element)
    end
end

addEventHandler('onClientRender', root, renderRepairShops)

addEventHandler('mechanic:showRepairWindow', root, function(repairs, vehicle)
    toggleMechanicUI()
    repairData = {
        repairs = repairs,
        vehicle = vehicle
    }
end)

addEventHandler('mechanic:hide', root, function()
    setMechanicUIVisible(false)
end)

addEventHandler('mechanic:repair', root, function(repair)
    if not repairData then return end

    triggerServerEvent('mechanic:repair', resourceRoot, repairData.vehicle, repair)
end)

addEventHandler('mechanic:respond', resourceRoot, function(response)
    if response then
        setMechanicUIVisible(false)
    else
        exports['m-ui']:triggerInterfaceEvent('mechanic', 'response', response)
    end
end)

addEventHandler('mechanic:serverTickResponse', resourceRoot, function(tick)
    serverTick.clientStart = getTickCount()
    serverTick.serverStart = tick
end)

function getServerTick()
    return serverTick.serverStart + (getTickCount() - serverTick.clientStart)
end

function fetchServerTick()
    triggerServerEvent('mechanic:getServerTick', resourceRoot)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    fetchServerTick()
end)

addEventHandler('mechanic:gateSound', resourceRoot, function(x, y, z)
    local sound = playSound3D('data/garage.wav', x, y, z)
    setSoundMaxDistance(sound, 20)
    setSoundVolume(sound, 0.5)
end)