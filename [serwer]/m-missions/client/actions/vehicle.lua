addEvent('missions:receiveServerSideVehicle', true)
addEvent('missions:madePedSyncer', true)
addEvent('missions:removedPedFromVehicle', true)

defineMissionAction({
    name = 'createServerSideVehicle',
    editorName = 'Stwórz pojazd',
    specialId = true,
    arguments = {
        Number('Model'),
        Position('Pozycja'),
        Rotation3D('Rotacja'),
        Color('Kolor podstawowy', {255, 255, 255, 255}),
        Color('Kolor dodatkowy', {255, 255, 255, 255}),
    },
    codeGeneration = function(specialId, model, position, rotation, primaryColor, secondaryColor)
        local index = #allowedMissionVehicles + 1
        allowedMissionVehicles[index] = {
            specialId = specialId,
            model = model,
            position = position,
            rotation = rotation,
            primaryColor = primaryColor,
            secondaryColor = secondaryColor,
        }

        return index
    end,
    callback = function(model, position, rotation, primaryColor, secondaryColor, index)
        triggerServerEvent('missions:requestServerSideVehicle', resourceRoot, getCurrentMission(), index)
        local vehicle = await(waitForVehicleCreation(index))
        return vehicle
    end,
})

function waitForVehicleCreation(index)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:receiveServerSideVehicle', resourceRoot, function(mission, vehicleIndex, vehicle)
            if vehicleIndex == index then
                resolve(vehicle)
            end
        end)
    end)
end

defineMissionAction({
    name = 'setVehicleDamageProof',
    editorName = 'Ustaw pojazd na odporny na uszkodzenia',
    arguments = {
        String('Pojazd'),
        Checkbox('Odporność na uszkodzenia'),
    },
    callback = function(vehicle, damageProof)
        local vehicle = getMissionElement(vehicle)
        setElementData(vehicle, 'missions:vehicleDamageProof', damageProof, false)
    end,
})

addEventHandler('onClientVehicleDamage', root, function(loss)
    if getElementData(source, 'missions:vehicleDamageProof') then
        cancelEvent()
    end
end)

defineMissionAction({
    name = 'disableVehicleExit',
    editorName = 'Zablokuj wyjście z pojazdu',
    arguments = {
        Checkbox('Zablokuj'),
    },
    callback = function(lock)
        setElementData(localPlayer, 'missions:vehicleExitLocked', lock)
    end,
})

defineMissionAction({
    name = 'disableVehicleEnter',
    editorName = 'Zablokuj wejście do pojazdu',
    arguments = {
        Checkbox('Zablokuj'),
    },
    callback = function(lock)
        setElementData(localPlayer, 'missions:vehicleEnterLocked', lock, false)
    end,
})

addEventHandler('onClientVehicleStartEnter', root, function(player)
    if player == localPlayer and getElementData(localPlayer, 'missions:vehicleEnterLocked') then
        cancelEvent()
    end
end)

defineMissionAction({
    name = 'makePedExitVehicle',
    editorName = 'Wysadź peda z pojazdu',
    arguments = {
        String('ped'),
    },
    callback = function(ped)
        local ped = getMissionElement(ped)
        if not ped or (getElementType(ped) ~= 'ped' and getElementType(ped) ~= 'player') then return end

        if not isElementSyncer(ped) and ped ~= localPlayer then
            triggerServerEvent('missions:makeMePedSyncer', resourceRoot, ped)
            await(waitForElementSyncer(ped))
        end
        
        forceExitVehicle(ped)
    end,
})

defineMissionAction({
    name = 'removeFromVehicle',
    editorName = 'Wysadź peda z pojazdu (force)',
    arguments = {
        String('ped'),
    },
    callback = function(ped)
        triggerServerEvent('missions:removePedFromVehicle', resourceRoot, getMissionElement(ped))
        await(waitForPedExit(getMissionElement(ped)))
    end,
})

function forceExitVehicle(ped)
    local vehicle = getPedOccupiedVehicle(ped)
    if not vehicle then return end

    setElementVelocity(vehicle, 0, 0, 0)
    setPedExitVehicle(ped)
end

function waitForElementSyncer(element)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:madePedSyncer', resourceRoot, function(ped)
            if ped == element then
                resolve()
            end
        end)
    end)
end

function waitForPedExit(ped)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:removedPedFromVehicle', resourceRoot, function(exitedPed)
            if exitedPed == ped then
                resolve()
            end
        end)
    end)
end