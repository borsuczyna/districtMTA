function isValidDirtVehicle(vehicle)
	if vehicle and isElement(vehicle) and getElementType(vehicle) == 'vehicle' then
		if allowedVehicleTypes[getVehicleType(vehicle)] then
			return true
		end
	end
	return false
end

function getVehicleDirtLevel(vehicle)
	if isValidDirtVehicle(vehicle) then
		local dirtLevel = getElementData(vehicle, 'vehicle:dirtLevel') or 1
		return dirtLevel
	end
	return false
end

function getVehicleDirtProgress(vehicle)
	if isValidDirtVehicle(vehicle) then
		local dirtProgress = getElementData(vehicle, 'vehicle:dirtProgress') or 0
		return dirtProgress
	end
	return false
end

function getNextDirtTime(vehicle)
	if isValidDirtVehicle(vehicle) then
		local dirtTime = getElementData(vehicle, 'vehicle:dirtTime') or 0
		return dirtTime
	end
	return false
end

function getVehicleSpeed(vehicle)   
    if isElement(vehicle) then
        local vx, vy, vz = getElementVelocity(vehicle)
        
        if (vx) and (vy)and (vz) then
            return math.sqrt(vx^2 + vy^2 + vz^2) * 180 -- km/h
        else
            return 0
        end
    else
        return 0
    end
end

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function convertNumber(number)  
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1.%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end