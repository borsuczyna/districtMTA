local camera

function getModelBoundingBox(element)
	local type = getElementType(element)
	local model = getElementModel(element)
	local element;

	if type == "vehicle" then
		element = createVehicle(model, 0, 0, 0)
	elseif type == "object" then
		element = createObject(model, 0, 0, 0)
	else
		return false
	end

	local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(element)
	destroyElement(element)

	return x1, y1, z1, x2, y2, z2
end

function getElementSize(element)
	local x1, y1, z1, x2, y2, z2 = getModelBoundingBox(element)
	if not x1 then return end

	return x2 - x1, y2 - y1, z2 - z1
end

function zoomToComponent(vehicle, component)
	local sx, sy, sz = getElementSize(vehicle)
	local wx, wy, wz = getPositionFromElementOffset(vehicle, component[1] * sx, component[2] * sy, component[3] * sz)
	local wlx, wly, wlz = getPositionFromElementOffset(vehicle, component[4] * sx, component[5] * sy, component[6] * sz)
	if not wx then return end

	moveCamera(wx, wy, wz, wlx, wly, wlz, 1000)
end

function restoreCamera()
	if not camera then return end

	local cx, cy, cz, lx, ly, lz = unpack(camera.from)
	setCameraMatrix(cx, cy, cz, lx, ly, lz)
	camera = nil
end

function applyInverseRotation ( x,y,z, rx,ry,rz )
    -- Degress to radians
    local DEG2RAD = (math.pi * 2) / 360
    rx = rx * DEG2RAD
    ry = ry * DEG2RAD
    rz = rz * DEG2RAD

    -- unrotate each axis
    local tempY = y
    y =  math.cos ( rx ) * tempY + math.sin ( rx ) * z
    z = -math.sin ( rx ) * tempY + math.cos ( rx ) * z

    local tempX = x
    x =  math.cos ( ry ) * tempX - math.sin ( ry ) * z
    z =  math.sin ( ry ) * tempX + math.cos ( ry ) * z

    tempX = x
    x =  math.cos ( rz ) * tempX + math.sin ( rz ) * y
    y = -math.sin ( rz ) * tempX + math.cos ( rz ) * y

    return x, y, z
end

function moveCamera(x, y, z, tlx, tly, tlz, duration)
	local cx, cy, cz, lx, ly, lz = getCameraMatrix()
	camera = {
		from = {cx, cy, cz, lx, ly, lz},
		to = {x, y, z, tlx, tly, tlz},
		start = getTickCount(),
		duration = duration,
	}
end

function updateCamera()
	if not camera then return end

	local now = getTickCount()
	local progress = (now - camera.start) / camera.duration
	if progress >= 1 then
		camera = nil
		return
	end

	local x, y, z = interpolateBetween(
		camera.from[1], camera.from[2], camera.from[3],
		camera.to[1], camera.to[2], camera.to[3],
		progress, 'InOutQuad'
	)

	local lx, ly, lz = interpolateBetween(
		camera.from[4], camera.from[5], camera.from[6],
		camera.to[4], camera.to[5], camera.to[6],
		progress, 'InOutQuad'
	)

	setCameraMatrix(x, y, z, lx, ly, lz)
end

addEventHandler('onClientRender', root, updateCamera)

function mechanicUpgrades(vehicle, upgrades)
	local outUpgrades = {}
	local vehicleUpgrades = exports['m-upgrades']:getVehicleUpgrades(vehicle)

	for i, upgrade in ipairs(upgrades) do
		local installed = getElementData(vehicle, upgrade)
		local price = getUpgradePrice(upgrade)

		table.insert(outUpgrades, {
			name = tonumber(upgrade) and ('(%d) %s'):format(upgrade, exports['m-upgrades']:getUpgradeName(upgrade)) or exports['m-upgrades']:getUpgradeName(upgrade),
			upgrade = upgrade,
			installed = installed,
			price = installed and math.floor(price * 0.6) or price,
			preview = function(vehicle)
				
			end,
			install = function(player, vehicle)
				setElementData(vehicle, upgrade, true)
			end,
			uninstall = function(player, vehicle)
				removeElementData(vehicle, upgrade)
			end,
			canInstall = function(vehicle)
				return true
			end,
		})
	end

	return outUpgrades
end

function visualUpgrades(vehicle, id, zoomTo, compatible)
	local upgrades = compatible or exports['m-upgrades']:getVehicleCompatibleUpgrades(vehicle, id)
	local outUpgrades = {}
	local vehicleUpgrades = exports['m-upgrades']:getVehicleUpgrades(vehicle)

	for i, upgrade in ipairs(upgrades) do
		local installed = not not table.find(vehicleUpgrades, upgrade)
		local price = getUpgradePrice(upgrade)
		local itemUpgrade = exports['m-upgrades']:isItemUpgrade(upgrade)

		table.insert(outUpgrades, {
			name = tonumber(upgrade) and ('(%d) %s'):format(upgrade, exports['m-upgrades']:getUpgradeName(upgrade)) or exports['m-upgrades']:getUpgradeName(upgrade),
			upgrade = upgrade,
			installed = installed,
			price = installed and math.floor(price * 0.6) or price,
			preview = function(vehicle)
				exports['m-upgrades']:forceVehicleUpgrade(vehicle, upgrade)
				zoomToComponent(vehicle, zoomTo)
			end,
			install = function(player, vehicle)
				if itemUpgrade then
					if not exports['m-inventory']:doesPlayerHaveItem(player, itemUpgrade) then
						exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz przedmiotu do montażu tego tuningu.')
						return
					end
				end

				exports['m-upgrades']:forceVehicleUpgrade(vehicle, upgrade)

				if itemUpgrade then
					exports['m-inventory']:removePlayerItem(player, itemUpgrade, 1)
				end
			end,
			uninstall = function(player, vehicle)
				exports['m-upgrades']:removeVehicleUpgrade(vehicle, upgrade)

				if itemUpgrade then
					exports['m-inventory']:addPlayerItem(player, itemUpgrade, 1)
				end
			end,
			canInstall = function(vehicle)
				local current = exports['m-upgrades']:getVehicleUpgradeOnSlot(vehicle, id)
				return (not current or current == 0), 'Posiadasz już inny tuning tego typu, pierw go zdemontuj.'
			end,
		})
	end

	return outUpgrades
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

categories = {
	-- hood = 0,
    -- vent = 1,
    -- spoiler = 2,
    -- sideskirt = 3,
    -- frontBullbars = 4,
    -- rearBullbars = 5,
    -- headlights = 6,
    -- roof = 7,
    -- nitro = 8,
    -- Hydraulics = 9,
    -- stereo = 10,
    -- wheels = 12,
    -- exhaust = 13,
    -- frontBumper = 14,
    -- rearBumper = 15,
    -- misc = 16,
	{
		name = 'Tuning mechaniczny',
		icon = 'wheel',
		key = 'mechanic',
		items = function(vehicle) 
			return mechanicUpgrades(vehicle, {'vehicle:mk1', 'vehicle:mk2', 'vehicle:mk3', 'vehicle:rwd'})
		end,
		remove = function(vehicle)
		end,
	},
	{
		name = 'Koła',
		icon = 'wheel',
		key = 'wheels',
		items = function(vehicle) 
			return visualUpgrades(vehicle, 'wheels', {-2, 0.6, 0.5, -1, 0.4, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'wheels')
		end,
	},
	{
		name = 'Maska',
		icon = 'hood',
		key = 'hood',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'hood', {-0.4, 1, 1.3, -0.15, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'hood')
		end,
	},
		{
		name = 'Wloty',
		icon = 'vent',
		key = 'vent',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'vent', {-0.4, 1, 1.3, -0.15, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'vent')
		end,
	},
	{
		name = 'Spoilery',
		icon = 'spoiler',
		key = 'spoiler',
		items = function(vehicle, compatible)
			return visualUpgrades(vehicle, 'spoiler', {-0.7, -1, 0.9, -0.15, -0.5, 0.3}, compatible and compatible.spoiler)
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'spoiler')
		end,
	},
	{
		name = 'Tylne spoilery',
		icon = 'spoiler',
		key = 'backSpoiler',
		items = function(vehicle, compatible)
			return visualUpgrades(vehicle, 'backSpoiler', {-0.7, -1, 0.9, -0.15, -0.5, 0.3}, compatible and compatible.backSpoiler)
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'backSpoiler')
		end,
	},
	{
		name = 'Progi',
		icon = 'sideskirt',
		key = 'sideskirt',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'sideskirt', {-1.5, -0.1, 0.3, 0.9, -0.23, -0.1})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'sideskirt')
		end,
	},
	{
		name = 'Lampy',
		icon = 'lights',
		key = 'lights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'frontBullbars', {0, 1.5, 0.5, 0, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'frontBullbars')
		end,
	},
	{
		name = 'Przednie lampy',
		icon = 'lights',
		key = 'frontlights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'headlights', {0, 1.1, 0.5, 0, 0.5, 0.2})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'headlights')
		end,
	},
	{
		name = 'Tylne lampy',
		icon = 'lights',
		key = 'rearlights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'rearBullbars', {0, -1.1, 0.5, 0, -0.5, 0.2})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'rearBullbars')
		end,
	},
	{
		name = 'Dach',
		icon = 'roof',
		key = 'roof',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'roof', {-0.3, 0.4, 1.5, 0, 0, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'roof')
		end,
	},
	{
		name = 'Wydechy',
		icon = 'exhaust',
		key = 'exhaust',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'exhaust', {-0.7, -1.1, 0.5, -0.2, -0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'exhaust')
		end,
	},
	{
		name = 'Przedni zderzak',
		icon = 'bumper',
		key = 'frontbumper',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'frontBumper', {-0.6, 1.1, 0.5, -0.1, 0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'frontBumper')
		end,
	},
	{
		name = 'Tylny zderzak',
		icon = 'bumper',
		key = 'rearbumper',
		items = function(vehicle)
			return visualUpgrades(vehicle, 'rearBumper', {-0.6, -1.1, 0.5, -0.1, -0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 'rearBumper')
		end,
	},
}

function getUpgradePrice(upgradeID)
	return exports['m-upgrades']:getUpgradePrice(upgradeID)
end

function getVehicleUpgradeCategories(vehicle, compatible)
	local outCategories = {}

	for i, category in ipairs(categories) do
		local items = category.items(vehicle, compatible)
		if #items > 0 then
			table.insert(outCategories, {
				name = category.name,
				icon = category.icon,
				key = category.key,
				items = items,
				remove = category.remove,
			})
		end
	end

	return outCategories
end

function getVehicleOriginalUpgrades(vehicle)
	local data = {
		upgrades = {}
	}

	-- for i = 0, 16 do
	-- 	local upgrade = getVehicleUpgradeOnSlot(vehicle, i)
	-- 	if upgrade then
	-- 		data.upgrades[i] = upgrade
	-- 	end
	-- end
	for i, slot in ipairs(exports['m-upgrades']:getUpgradeSlots()) do
		local upgrade = exports['m-upgrades']:getVehicleUpgradeOnSlot(vehicle, slot)
		if upgrade then
			data.upgrades[slot] = upgrade
		end
	end

	return data
end

function restoreVehicleUpgrade(vehicle, slot)
	if not originalTuning then return end

	local upgrade = originalTuning.upgrades[slot]
	-- local currentUpgrade = getVehicleUpgradeOnSlot(vehicle, slot)
	-- if currentUpgrade then
	-- 	removeVehicleUpgrade(vehicle, currentUpgrade)
	-- end
	exports['m-upgrades']:removeVehicleUpgradeOnSlot(vehicle, slot)

	if upgrade then
		exports['m-upgrades']:addVehicleUpgrade(vehicle, upgrade)
	end

	return upgrade
end

function table.find(t, value)
	for i, v in ipairs(t) do
		if v == value then
			return v, i
		end
	end
	return false
end

function table.findCallback(t, callback)
	for i, v in ipairs(t) do
		if callback(v) then
			return v, i
		end
	end
	return false
end