addEvent('cablecar:playDoorSound', true)

local sounds = {}

function renderCableCar(position, cableCar)
    local start = cableCar.lineStart
    local finish = cableCar.lineFinish
    local middle = (start + finish) / 2

    local distance = getDistanceBetweenPoints3D(position, middle)
    if distance > cableCar.drawDistance then return end

    dxDrawLine3D(start, finish, tocolor(0, 0, 0), 3)
end

function renderCableCars()
    local position = Vector3(getCameraMatrix())
    for i, cableCar in ipairs(cableCars) do
        renderCableCar(position, cableCar)
    end
end

addEventHandler('onClientRender', root, renderCableCars)

addEventHandler('cablecar:playDoorSound', resourceRoot, function(x, y, z)
    local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer))
    if distance > 30 then return end

    local sound = playSound3D('data/door.mp3', x, y, z)
    setSoundMaxDistance(sound, 25)
    setSoundMinDistance(sound, 3)
end)

function startCableCarSound(cableCar)
    local sound = playSound3D('data/ride.mp3', 0, 0, 0, true)
    setSoundMaxDistance(sound, 70)
    setSoundMinDistance(sound, 10)
    setSoundVolume(sound, getElementData(cableCar, 'ride:volume') or 0)
    attachElements(sound, cableCar)

    sounds[cableCar] = sound
end

addEventHandler('onClientElementDataChange', root, function(dataName, oldValue)
    if dataName == 'ride:volume' then
        local sound = sounds[source]
        if sound then
            setSoundVolume(sound, getElementData(source, 'ride:volume'))
        end
    end
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    local cableCars = getElementsByType('object')
    for i, cableCar in ipairs(cableCars) do
        if getElementData(cableCar, 'element:model') == 'cablecar' then
            startCableCarSound(cableCar)
        end
    end
end)