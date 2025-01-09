function angularDamping()
	local vehicle = getPedOccupiedVehicle(localPlayer)

    if vehicle then
		if getVehicleType(vehicle) == 'Automobile' then
			local mult = 1
			if getCurrentFPS() then
				mult = 35/getCurrentFPS()
			end
				
			local rx, ry, rz = getVehicleTurnVelocity(vehicle)
			setVehicleTurnVelocity(vehicle, rx-(rx*0.2*mult), ry-(ry*0.2*mult), rz)
		end
    end
end

addEventHandler('onClientPreRender', root, angularDamping)

local fps = false
function getCurrentFPS()
    return fps
end
 
local function updateFPS(msSinceLastFrame)
    fps = (1 / msSinceLastFrame) * 1000
end

addEventHandler('onClientPreRender', root, updateFPS)