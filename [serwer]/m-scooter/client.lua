_getElementModel = getElementModel
local function getElementModel(vehicle)
	local hasCustomModel = getElementData(vehicle, "vehicleID")
	if not hasCustomModel then
		return _getElementModel(vehicle)
	else
		return hasCustomModel
	end
end

local playersWithAnimations = {}
local animations = {
	["_Back"] = true,
	["_drivebyFT"] = true,
	["_drivebyLHS"] = true,
	["_drivebyRHS"] = true,
	["_Fwd"] = true,
	["_getoffBACK"] = true,
	["_getoffLHS"] = true,
	["_getoffRHS"] = true,
	["_hit"] = true,
	["_jumponL"] = true,
	["_jumponR"] = true,
	["_kick"] = true,
	["_Left"] = true,
	["_passenger"] = true,
	["_pushes"] = true,
	["_Ride"] = true,
	["_Right"] = true,
	["_Still"] = true,
}

-- [model] = { animfile, animgroup, custom group }
local customAnims = {
	[448] = { "data/bike.ifp", "BIKEV", "scooter" },
}

local function restoreAnimations(player)
	for animation, _ in pairs(animations) do
		engineRestoreAnimation(player, "BIKEV", "BIKEV" .. animation)
	end
	playersWithAnimations[player] = nil
end

local function loadAnimations(player, model)
	for animation, _ in pairs(animations) do
		engineReplaceAnimation(player, customAnims[model][2], customAnims[model][2] .. animation, customAnims[model][3], customAnims[model][2] .. animation)
		playersWithAnimations[player] = true
	end
end

addEventHandler("onClientVehicleStartEnter", root, function(player,seat,door)
	-- if playersWithAnimations[player] and getElementModel(source) ~= 448 then
	if playersWithAnimations[player] and not customAnims[getElementModel(source)] then
		restoreAnimations(player)
		return
	end
	-- if getElementModel(source) == 448 then
	if customAnims[getElementModel(source)] then
		loadAnimations(player, getElementModel(source))
	end
end)

addEventHandler("onClientVehicleExit", root, function(player,seat,door)
	-- if getElementModel(source) == 448 then
	if customAnims[getElementModel(source)] then
		restoreAnimations(player)
	end
end)

addEventHandler( "onClientElementStreamIn", root, function()
	if getElementType(source) ~= "player" then
		return
	end
	local vehicle = getPedOccupiedVehicle(source)
	if not vehicle then
		return
	end
	-- if getElementModel(vehicle) == 448 and not playersWithAnimations[source] then
	if customAnims[getElementModel(vehicle)] and not playersWithAnimations[source] then
		loadAnimations(source, getElementModel(vehicle))
	elseif not customAnims[getElementModel(vehicle)] and playersWithAnimations[source] then
		restoreAnimations(source)
	end
end)

local ifp

addEventHandler("onClientResourceStart", resourceRoot, function()
	local txd = engineLoadTXD("data/448.txd")
	local dff = engineLoadDFF("data/448.dff")
	for _, animInfo in pairs(customAnims) do
		ifp = engineLoadIFP(animInfo[1], animInfo[3])
	end

	engineImportTXD(txd, 448)
	engineReplaceModel(dff, 448, true)
	setVehicleModelWheelSize(448, "all_wheels", 0.29)

	local txd = engineLoadTXD ( "data/escooterrental.txd")
	engineImportTXD ( txd, 1874 )
	
	local dff = engineLoadDFF("data/escooterrental.dff", 1874 )
	engineReplaceModel(dff, 1874)
	
	local col = engineLoadCOL ( "data/escooterrental.col")
	engineReplaceCOL ( col, 1874 )

	local dff = engineLoadDFF("data/foldedscooter.dff", 1867 )
	engineReplaceModel(dff, 1867)
	
	local col = engineLoadCOL ( "data/foldedscooter.col")
	engineReplaceCOL ( col, 1867 )
end)

setTimer(function()
    for _, plr in ipairs(getElementsByType("player", root, true)) do
        local vehicle = getPedOccupiedVehicle(plr)
       -- if vehicle and getElementModel(vehicle) == 448 and not playersWithAnimations[plr] then
		if vehicle and customAnims[getElementModel(vehicle)] and not playersWithAnimations[plr] then
            loadAnimations(plr, getElementModel(vehicle))
        end
    end
end, 1000, 0)

addEventHandler('onClientVehicleEnter', root, function(player, seat)
	if customAnims[getElementModel(source)] and not playersWithAnimations[player] then
		loadAnimations(player, getElementModel(source))
	end

	setPedCanBeKnockedOffBike(player, not (getElementModel(source) == 448))
end)

addEventHandler('onClientVehicleExit', root, function(player, seat)
	if customAnims[getElementModel(source)] and playersWithAnimations[player] then
		restoreAnimations(player)
	end

	setPedCanBeKnockedOffBike(player, true)
end)

addEventHandler('onClientVehicleStartEnter', root, function(player, seat)
	if getElementData(source, 'scooter:owner') and getElementData(source, 'scooter:owner') ~= localPlayer and player == localPlayer then
		cancelEvent()
	end
end)

addEventHandler("onClientWorldSound", root, function()
    if getElementType(source) == "vehicle" then
		if getElementModel(source) == 448 then
       	 	cancelEvent()
		end
    end
end)

local jumping = false

function toggleScooterJump(key, state)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle or getElementModel(vehicle) ~= 448 then return end

	if state == 'down' then
		if not jumping then
			jumping = getTickCount()
		end
	elseif state == 'up' then
		local x, y, z = getElementPosition(vehicle)
		local groundZ = getGroundPosition(x, y, z)
		if math.abs(z - groundZ) > 0.8 then return end
		
		local timeElapsed = getTickCount() - jumping
		local jump = timeElapsed / 500
		jump = math.min(jump, 1)

		local vx, vy, vz = getElementVelocity(vehicle)
		setElementVelocity(vehicle, vx, vy, vz + jump/8)
		jumping = false
	end
end

bindKey('lctrl', 'both', toggleScooterJump)