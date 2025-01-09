local vehicleNames = {
    'Landstalker', 'Bravura', 'Buffalo', 'Linerunner', 'Perrenial', 'Sentinel', 'Dumper',
	'Firetruck', 'Trashmaster', 'Stretch', 'Manana', 'Infernus', 'Voodoo', 'Pony', 'Mule',
	'Cheetah', 'Ambulance', 'Leviathan', 'Moonbeam', 'Esperanto', 'Taxi', 'Washington',
	'Bobcat', 'Mr Whoopee', 'BF Injection', 'Hunter', 'Premier', 'Enforcer', 'Securicar',
	'Banshee', 'Predator', 'Bus', 'Rhino', 'Barracks', 'Hotknife', 'Trailer 1', 'Previon',
	'Coach', 'Cabbie', 'Stallion', 'Rumpo', 'RC Bandit', 'Romero', 'Packer', 'Monster',
	'Admiral', 'Squalo', 'Seasparrow', 'Pizzaboy', 'Tram', 'Trailer 2', 'Turismo',
	'Speeder', 'Reefer', 'Tropic', 'Flatbed', 'Yankee', 'Caddy', 'Solair', 'Berkley\'s RC Van',
	'Skimmer', 'PCJ-600', 'Faggio', 'Freeway', 'RC Baron', 'RC Raider', 'Glendale', 'Oceanic',
	'Sanchez', 'Sparrow', 'Patriot', 'Quad', 'Coastguard', 'Dinghy', 'Hermes', 'Sabre',
	'Rustler', 'ZR-350', 'Walton', 'Regina', 'Comet', 'BMX', 'Burrito', 'Camper', 'Marquis',
	'Baggage', 'Dozer', 'Maverick', 'News Chopper', 'Rancher', 'FBI Rancher', 'Virgo', 'Greenwood',
	'Jetmax', 'Hotring', 'Sandking', 'Blista Compact', 'Police Maverick', 'Boxville', 'Benson',
	'Mesa', 'RC Goblin', 'Hotring Racer A', 'Hotring Racer B', 'Bloodring Banger', 'Rancher',
	'Super GT', 'Elegant', 'Journey', 'Bike', 'Mountain Bike', 'Beagle', 'Cropdust', 'Stunt',
	'Tanker', 'Roadtrain', 'Nebula', 'Majestic', 'Buccaneer', 'Shamal', 'Hydra', 'FCR-900',
	'NRG-500', 'HPV1000', 'Cement Truck', 'Tow Truck', 'Fortune', 'Cadrona', 'FBI Truck',
	'Willard', 'Forklift', 'Tractor', 'Combine', 'Feltzer', 'Remington', 'Slamvan',
	'Blade', 'Freight', 'Streak', 'Vortex', 'Vincent', 'Bullet', 'Clover', 'Sadler',
	'Firetruck LA', 'Hustler', 'Intruder', 'Primo', 'Cargobob', 'Tampa', 'Sunrise', 'Merit',
	'Utility', 'Nevada', 'Yosemite', 'Windsor', 'Monster A', 'Monster B', 'Uranus', 'Jester',
	'Sultan', 'Stratum', 'Elegy', 'Raindance', 'RC Tiger', 'Flash', 'Tahoma', 'Savanna',
	'Bandito', 'Freight Flat', 'Streak Carriage', 'Kart', 'Mower', 'Duneride', 'Sweeper',
	'Broadway', 'Tornado', 'AT-400', 'DFT-30', 'Huntley', 'Stafford', 'BF-400', 'Newsvan',
	'Tug', 'Trailer 3', 'Emperor', 'Wayfarer', 'Euros', 'Hotdog', 'Club', 'Freight Carriage',
	'Trailer 3', 'Andromada', 'Dodo', 'RC Cam', 'Launch', 'Police Car (LSPD)', 'Police Car (SFPD)',
	'Police Car (LVPD)', 'Police Ranger', 'Picador', 'S.W.A.T. Van', 'Alpha', 'Phoenix', 'Glendale',
	'Sadler', 'Luggage Trailer A', 'Luggage Trailer B', 'Stair Trailer', 'Boxville', 'Farm Plow',
	'Utility Trailer'
}

local blockedVehicleIDs = {
    592, 577, 511, 548, 512, 593, 425, 417, 487, 553,
	488, 497, 563, 476, 447, 519, 460, 469, 513, 520,
	441, 464, 465, 501, 432
}

local function getVehicleIdByPartialName(partialName)
    for i, name in ipairs(vehicleNames) do
        if name:lower():find(partialName:lower()) then
            return i + 400 - 1
        end
    end
    return false
end

addCommandHandler('cv', function(player, cmd, model)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:cv') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not model then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /cv (model lub ID)')
        return
    end
    
    model = not tonumber(model) and getVehicleIdByPartialName(model) or math.floor(tonumber(model) or 0)

    if model and table.find(blockedVehicleIDs, model) and not doesPlayerHavePermission(player, 'command:cv.bypass') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz utworzyć tego pojazdu')
        return
    end
    
    if model and model >= 400 and model <= 611 then
        local x, y, z = getElementPosition(player)
        local rx, ry, rz = getElementRotation(player)
        local vehicle = createVehicle(model, x, y + 2, z, rx, ry, rz)
        setElementInterior(vehicle, getElementInterior(player))
        setElementDimension(vehicle, getElementDimension(player))

        warpPedIntoVehicle(player, vehicle)
    else
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono takiego pojazdu')
        return
    end

    exports['m-notis']:addNotification(player, 'success', 'Pojazd', ('Utworzono pojazd %s'):format(getVehicleNameFromModel(model)))
end)

addCommandHandler('dv', function(player, cmd)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:cv') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie jesteś w pojeździe')
        return
    end

    local isSpawned = not getElementData(vehicle, 'vehicle:uid')
    local isJob = getElementData(vehicle, 'vehicle:job')
    local isScooter = getElementData(vehicle, 'scooter:owner')
    if not isSpawned or isJob or isScooter then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz usunąć tego pojazdu')
        return
    end

    exports['m-notis']:addNotification(player, 'success', 'Pojazd', ('Usunięto pojazd %s'):format(exports['m-models']:getVehicleName(vehicle)))
    destroyElement(vehicle)
end)