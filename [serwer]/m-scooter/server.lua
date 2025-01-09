local timers = {}
local rentals = {
	{691.0, -514.883, 16.336, 90},
	{1170.492, -1696.146, 13.547, 90},
	{1929.001, -1769.086, 13.547, 90},
	{1215.402, -908.572, 42.919, 8},
	{1421.092, 386.170, 19.210, 66.212},
	{2000.619, -1837.7, 13.547, 0},
	{1881.749, -1320.2, 14.062, 0},
	{986.226, -1471.489, 13.586, 90},
}

local handling = {
	['mass'] = 350,
	['turnMass'] = 50,
	['dragCoeff'] = 7,
	['centerOfMass'] = {[1] = 0, [2] = 0, [3] = 0},
	['percentSubmerged'] = 103,
	['tractionMultiplier'] = 1.8,
	['tractionLoss'] = 1,
	['tractionBias'] = 0.5,
	['numberOfGears'] = 1,
	['maxVelocity'] = 80,
	['engineAcceleration'] = 75,
	['engineInertia'] = 5,
	['driveType'] = 'awd',
	['engineType'] = 'electric',
	['brakeDeceleration'] = 20,
	['brakeBias'] = 0,
	['steeringLock'] = 40,
	['suspensionForceLevel'] = 1,
	['suspensionDamping'] = 0.15,
	['suspensionHighSpeedDamping'] = 0,
	['suspensionUpperLimit'] = 0.12,
	['suspensionLowerLimit'] = -0.17,
	['suspensionFrontRearBias'] = 0.15,
	['suspensionAntiDiveMultiplier'] = 0,
	['collisionDamageMultiplier'] = 0,
	['headLight'] = 'small',
	['tailLight'] = 'small',
	['animGroup'] = 5,
	['modelFlags'] = 0x1001100,
	['handlingFlags'] = 0x1000001,
}

for property, value in pairs(handling) do
	setModelHandling(448, property, value)
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

for k,v in pairs(rentals) do
	createObject(1874, v[1], v[2], v[3]-1, 0, 0, v[4])
	local colShape = createColSphere(v[1], v[2], v[3], 2)
	local blip = createBlipAttachedTo(colShape, 42, 2, 255, 255, 255, 255, 0, 9999)
	setElementData(colShape, 'scooter:rental', true)
	setElementData(blip, 'blip:hoverText', 'Wypożyczalnia hulajnóg')
end

addEvent('scooter:rent')
addEventHandler('scooter:rent', resourceRoot, function(hash, player)
    if getElementData(player, 'player:job') then
		exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz wypożyczyć hulajnogi będąc w pracy', renting = false})
		return
	end

	local rented = getElementData(player, 'scooter:rented')

	if rented then
		if isElement(rented) and getElementType(rented) ~= 'object' then
			exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Hulajnoga musi być złożona aby ją zwrócić', renting = true})
			return
		end

		destroyElement(rented)
		setElementData(player, 'scooter:rented', false)
		exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zwrócono hulajnogę elektryczną', renting = false})

		setElementData(player, 'player:animation', false)
		if timers[player] and isTimer(timers[player]) then
			killTimer(timers[player])
		end
	else
		local vehicle = createObject(1867, 0, 0, 0)
		exports['m-pattach']:attach(vehicle, player, 23, 0, 0, 0, 20, 0, 50)
		setElementData(player, 'scooter:rented', vehicle)
		setElementData(player, 'player:animation', 'scooter-carry')
		exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wypożyczono hulajnogę elektryczną, naciśnij <kbd class="keycap keycap-sm">H</kbd><div class="controller-button small circle"></div> aby ją rozłożyć', renting = true})
	end
end)

function foldVehicle(client, rented)
	destroyElement(rented)
	rented = createObject(1867, 0, 0, 0)
	exports['m-pattach']:attach(rented, client, 23, 0, 0, 0, 20, 0, 50)
	setElementData(client, 'scooter:rented', rented)
	setElementData(client, 'player:animation', 'scooter-carry')

	if timers[client] and isTimer(timers[client]) then
		killTimer(timers[client])
	end
end

addEvent('scooter:fold', true)
addEventHandler('scooter:fold', resourceRoot, function()
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `scooter:fold` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

	if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
	local rented = getElementData(client, 'scooter:rented')
	if not rented then return end

	if getElementType(rented) == 'object' then
		destroyElement(rented)
		local x, y, z = getElementPosition(client)
		local rx, ry, rz = getElementRotation(client)
		rented = createVehicle(448, x, y, z, rx, ry, rz)
		setVehicleColor(rented, 0, 0, 0, 0, 0, 0)
		warpPedIntoVehicle(client, rented)
		setElementData(client, 'scooter:rented', rented)
		setElementData(client, 'player:animation', false)
		setElementData(rented, 'element:ghostmode', true)
		setElementData(rented, 'scooter:owner', client)

		exports['m-notis']:addNotification(client, 'success', 'Hulajnoga elektryczna', 'Hulajnoga została rozłożona, aby ją złożyć - zsiądź i naciśnij <kbd class="keycap keycap-sm">H</kbd><div class="controller-button small circle"></div>')
	else
		foldVehicle(client, rented)
	end
end)

addEventHandler('onPlayerVehicleExit', root, function(vehicle)
	if not isElement(vehicle) then return end
    if getElementData(vehicle, 'scooter:owner') ~= source then return end
    exports['m-notis']:addNotification(source, 'info', 'Wynajem hulajnogi', 'Hulajnoga zostanie zwrócona po minucie nieaktywności, naciśnij <kbd class="keycap keycap-sm">H</kbd><div class="controller-button small circle"></div> aby ją złożyć')

	timers[source] = setTimer(destroyScooter, 60000, 1, source)
end)

addEventHandler('onPlayerVehicleEnter', root, function(vehicle)
	if getElementData(vehicle, 'scooter:owner') ~= source then return end
	if timers[source] and isTimer(timers[source]) then
		killTimer(timers[source])
	end
end)

function destroyScooter(player)
	local rented = getElementData(player, 'scooter:rented')
	if getElementType(rented) == 'vehicle' then
		destroyElement(rented)
		setElementData(player, 'scooter:rented', false)
		exports['m-notis']:addNotification(player, 'success', 'Wynajem hulajnogi', 'Hulajnoga została zwrócona')
		setElementData(player, 'player:animation', false)
		if timers[player] and isTimer(timers[player]) then
			killTimer(timers[player])
		end
	end
end

addEventHandler('onPlayerQuit', root, function()
	local rented = getElementData(source, 'scooter:rented')
	if rented then
		destroyElement(rented)
	end
	if timers[source] and isTimer(timers[source]) then
		killTimer(timers[source])
	end
end)