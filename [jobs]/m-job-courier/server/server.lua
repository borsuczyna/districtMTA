addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')

local blip = createBlip(settings.jobStart, 40, 2, 255, 255, 255, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Praca dorywcza<br>Kurier')
local vehicles = {}

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'courier' then return end

    for k,v in pairs(players) do
        if not exports['m-core']:doesPlayerHaveLicense(v, 'C') then
            exports['m-notis']:addNotification(players, 'error', 'Brak licencji', ('Gracz %s nie posiada kat. C'):format(htmlEscape(getPlayerName(v))))
            cancelEvent()
            return
        end
    end

    local spawn = getRandomSpawnPosition()

    local vehicle = createVehicle(413, spawn.vehicle, spawn.rot)
    setElementData(vehicle, 'vehicle:job', {players = players, hash = hash})
    setElementData(vehicle, 'element:ghostmode', true)
    setVehicleDoorOpenRatio(vehicle, 4, 1, 1000)
    setVehicleDoorOpenRatio(vehicle, 5, 1, 1000)

    setVehicleEngineState(vehicle, false)
    setElementFrozen(vehicle, true)
    setVehicleOverrideLights(vehicle, 1)
    vehicles[hash] = vehicle

    exports['m-jobs']:createLobbyBlip(hash, 0, 0, 0, 43, 9999, {
        attach = {
            element = vehicle,
        }
    })

    local cart = exports['m-jobs']:createLobbyObject(hash, model, spawn.cart.x, spawn.cart.y, spawn.cart.z, spawn.rot.x, spawn.rot.y, spawn.rot.z + 90, {
        customModel = 'cart',
        noTrigger = true,
        colshape = {
            size = 1.1,
            attached = true,
            attachPosition = {1.0, 0, -0.4},
            event = 'jobs:courier:cartHit'
        },
        noCollision = true,
        frozen = true,
    })

    -- create shelfs
    local models = {'pears', 'apples', 'bananas', 'lemons'}

    for _, shelf in ipairs(settings.shelfs) do
        exports['m-jobs']:createLobbyObject(hash, 1271, shelf[1], shelf[2], shelf[3], 0, 0, -45, {
            customModel = models[math.random(1, #models)],
            noTrigger = true,
            frozen = true,
            customData = {
                package = true,
                state = 0,
            }
        })
    end

    exports['m-jobs']:createLobbyMarker(hash, 'cylinder', 0, 0, 0, 1, 50, 140, 255, 0, {
        icon = 'work',
        title = 'Kurier',
        desc = 'Tył pojazdu',
        attach = {
            element = vehicle,
            position = {0, -3.3, -1.2},
        },
        event = 'jobs:courier:vehicleHit'
    })

    exports['m-jobs']:updateLobbyObjects(hash)
    exports['m-jobs']:setLobbyData(hash, 'cart:player', nil)
    exports['m-jobs']:setLobbyData(hash, 'cart:object', cart)
    exports['m-jobs']:setLobbyData(hash, 'cart:loadedPackages', 0)
    
    for i, player in ipairs(players) do
        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(player, 'courier')
        setElementData(player, 'player:job-upgrades-cache', upgrades, false)
        setElementData(player, 'element:ghostmode', true)

        setElementPosition(player, spawn.player)
        setElementRotation(player, spawn.rot)
    end

    reloadLobbyPackages(hash)

    for k,v in pairs(players) do
        setElementData(v, 'player:jobVehicle', vehicle)
    end
end)

function reloadLobbyPackages(hash)
    local players = exports['m-jobs']:getLobbyPlayers(hash)
    local multiplier = 1
    
    for _,player in pairs(players) do
        local upgrades = getElementData(player, "player:job-upgrades-cache") or {}

        if table.find(upgrades, 'pojemnosc') then
            multiplier = multiplier + 0.2
        end
    end
    
    local packages = math.floor(math.random(settings.packagesMin * multiplier, settings.packagesMax * multiplier))
    exports['m-jobs']:setLobbyData(hash, 'vehicle:packages', packages)
    exports['m-jobs']:setLobbyData(hash, 'vehicle:deliveredPackages', 0)
    exports['m-jobs']:setLobbyData(hash, 'vehicle:loadedPackages', 0)
    exports['m-jobs']:setLobbyData(hash, 'vehicle:loaded', false)

    exports['m-notis']:addNotification(players, 'info', 'Kurier', ('Paczki do załadowania: %d'):format(packages))
end

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'courier' then return end

    removeElementData(player, 'player:animation')
    removeElementData(player, 'player:holdingPackage')
    setElementData(player, 'element:ghostmode', false)
    setPedAnimation(player)
    detachCartFromPlayer(player)
end)

addEventHandler('jobs:finishJobLobby', root, function(job, hash)
    if job ~= 'courier' then return end

    local vehicle = vehicles[hash]
    if vehicle and isElement(vehicle) then
        destroyElement(vehicle)
    end
end)

function isCourierVehicle(vehicle)
    for k,v in pairs(vehicles) do
        if v == vehicle then
            return true
        end
    end

    return false
end

function getJobVehicle(player)
    return getElementData(player, 'player:jobVehicle')
end

addEventHandler('onVehicleEnter', root, function()
    local vehicle = source
    if not isCourierVehicle(vehicle) then return end

    setVehicleDoorOpenRatio(vehicle, 4, 0, 1000)
    setVehicleDoorOpenRatio(vehicle, 5, 0, 1000)
end)

addEventHandler('onVehicleEnter', root, function(player, seat)
    local vehicle = source
    if seat ~= 0 then return end

    local jobData = getElementData(vehicle, 'vehicle:job')
    if not jobData then return end

    local job = getElementData(player, 'player:job')
    if job ~= 'courier' then return end

    local upgrades = getElementData(player, 'player:job-upgrades-cache') or {}
    local modelHandling = getModelHandling(getElementModel(vehicle))
    local multiplier = table.find(upgrades, 'kierowca') and 1.15 or 1

    setVehicleHandling(vehicle, 'maxVelocity', modelHandling['maxVelocity'] * multiplier)
    setVehicleHandling(vehicle, 'engineAcceleration', modelHandling['engineAcceleration'] * multiplier)
    setVehicleHandling(vehicle, 'steeringLock', modelHandling['steeringLock'] * multiplier)
end)

addEventHandler('onVehicleExit', root, function()
    local vehicle = source
    if not isCourierVehicle(vehicle) then return end

    setVehicleDoorOpenRatio(vehicle, 4, 1, 1000)
    setVehicleDoorOpenRatio(vehicle, 5, 1, 1000)
end)

addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    if seat ~= 0 then return end
    if not isCourierVehicle(source) then return end

    if getElementData(player, 'player:job') ~= 'courier' then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Nie jesteś zatrudniony jako kurier')
    end

    local jobVehicle = getElementData(player, 'player:jobVehicle')
    if jobVehicle ~= source then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Nie możesz wsiąść do tego pojazdu')
    end

    local vehicleLoaded = exports['m-jobs']:getLobbyData(player, 'vehicle:loaded')
    if not vehicleLoaded then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Musisz załadować wszystkie paczki aby wsiąść do pojazdu')
    end
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end

    if getElementData(source, 'player:job') == 'courier' then
        triggerEvent('jobs:endJobI', root, false, source)
    end
end)