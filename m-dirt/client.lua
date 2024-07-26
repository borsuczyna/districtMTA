
addEvent('handleDirtShader', true)

local sx, sy = guiGetScreenSize()

local grungeVehicles = {}
local grungeTextures = {}

grungeTextures[1] = dxCreateTexture('data/images/nogrunge.png')
grungeTextures[2] = dxCreateTexture('data/images/lowgrunge.png')
grungeTextures[3] = dxCreateTexture('data/images/defaultgrunge.png')
grungeTextures[4] = dxCreateTexture('data/images/biggrunge.png')
grungeTextures[5] = dxCreateTexture('data/images/megagrunge.png')

function handleDirtShader(vehicle, level)
	level = tonumber(level)

	if isValidDirtVehicle(vehicle) then
		if not level then level = 1 end
		
		if not grungeVehicles[vehicle] or grungeVehicles[vehicle] == nil then
			grungeVehicles[vehicle] = {}
			grungeVehicles[vehicle].shader = dxCreateShader('data/texreplace.fx', 0, shaderVisibleDistance, true, 'vehicle')
		else
			destroyElement(grungeVehicles[vehicle].shader)
			grungeVehicles[vehicle] = {}
			grungeVehicles[vehicle].shader = dxCreateShader('data/texreplace.fx', 0, shaderVisibleDistance, true, 'vehicle')
		end
		
		dxSetShaderValue(grungeVehicles[vehicle].shader, 'dirt', grungeTextures[level])
		for k, v in pairs(replaceTextures) do
			for i = 1, #v do
				engineApplyShaderToWorldTexture(grungeVehicles[vehicle].shader, v[i], vehicle)
			end
		end
		engineApplyShaderToWorldTexture(grungeVehicles[vehicle].shader, '?emap*', vehicle)
		
		local oldDirtLevel = getVehicleDirtLevel(vehicle)
		local newDirtLevel = level

		triggerEvent('onClientVehicleDirtLevelChange', vehicle, oldDirtLevel, newDirtLevel)
	end

	return false
end

addEventHandler('handleDirtShader', root, handleDirtShader)

function isDrivingOnGrass()
    local vehicle = getPedOccupiedVehicle(localPlayer)

    if vehicle then
        local controller = getVehicleController(vehicle)
        
        if controller == localPlayer then
		    local x, y, z = getElementPosition(vehicle)
		    local _, _, _, _, _, _, _, _, material = processLineOfSight(x, y, z, x, y, z - 5, true, false)
	
		    setElementData(vehicle, 'vehicle:onOffroad', getVehicleSpeed(vehicle) > 10 and (not not table.find(grassList, material)))
        end
    end
end

setTimer(isDrivingOnGrass, 5000, 0)

function setVehicleDirtLevel(vehicle, level)
	level = tonumber(level)

	if isValidDirtVehicle(vehicle) then
		if not level then level = 1 end
		handleDirtShader(vehicle, level)
	end

	return false
end

addEventHandler('onClientElementStreamIn', root, function()
    if getElementType(source) == 'vehicle' then
		if isValidDirtVehicle(source) then
			if not grungeVehicles[source] or grungeVehicles[source] == nil then
				triggerServerEvent('loadVehicleDirtServer', source, source)
			end
		end
	end
end)

addEventHandler('onClientElementStreamOut', root, function()
    if getElementType(source) == 'vehicle' then
		if isValidDirtVehicle(source) then
			if grungeVehicles[source] then
				destroyElement(grungeVehicles[source].shader)
                
				grungeVehicles[source].shader = nil
				grungeVehicles[source] = nil
			end
		end
	end
end)

addEventHandler('onClientElementDestroy', root, function ()
	if getElementType(source) == 'vehicle' then
		if grungeVehicles[source] then
			destroyElement(grungeVehicles[source].shader)
			grungeVehicles[source] = {}
		end
	end
end)