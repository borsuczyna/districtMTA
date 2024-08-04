
addEvent('onVehicleDirtLevelChange', true)

addEvent('setVehicleGrungeServer', true)
addEvent('setVehicleDirtProgressServer', true)
addEvent('loadVehicleDirtServer', true)

local grungeLimit = 5

local changeParameter = {}

local currentProgress = {}
local doNotChangeMore = {}
local addGrungeTimer = {}

function setVehicleDirtLevel(vehicle, level)
	level = tonumber(level)

	if isValidDirtVehicle(vehicle) then
		if not level then level = 1 end
		
		triggerClientEvent(root, 'handleDirtShader', vehicle, vehicle, level)
		
		local oldDirtLevel = getElementData(vehicle, 'vehicle:dirtLevel') or 1
		local newDirtLevel = level

		triggerEvent('onVehicleDirtLevelChange', vehicle, oldDirtLevel, newDirtLevel)
		setElementData(vehicle, 'vehicle:dirtLevel', newDirtLevel)
		
		local controller = getVehicleController(vehicle)
		if controller and newDirtLevel > 1 then
			exports['m-notis']:addNotification(controller, 'info', 'Brud', 'Twoj pojazd jest brudny, udaj się do najbliższej myjni aby go umyć')
		end
	end

	return false
end

addEventHandler('setVehicleGrungeServer', root, setVehicleDirtLevel)

function setVehicleDirtProgress(vehicle, progress)
	progress = tonumber(progress)

	if isValidDirtVehicle(vehicle) then
		if not progress then progress = 0 end
		
		currentProgress[vehicle] = progress
		setElementData(vehicle, 'vehicle:dirtProgress', currentProgress[vehicle])
	end

	return false
end

addEventHandler('setVehicleDirtProgressServer', root, setVehicleDirtProgress)

function setVehicleDirtTime(vehicle, theTime)
	theTime = tonumber(theTime)

	if isValidDirtVehicle(vehicle) then
		if not theTime then theTime = 0 end
		
		addGrungeTimer[vehicle] = theTime
		setElementData(vehicle, 'vehicle:dirtTime', addGrungeTimer[vehicle])
	end

	return false
end

function isElementUnderSomething(element)
--
end

function startVehicleGrunge()
	setTimer(function()
		for k, vehicle in pairs(getElementsByType('vehicle')) do
			if isValidDirtVehicle(vehicle) then
				local grungeLevel = getVehicleDirtLevel(vehicle)
				
				changeParameter[vehicle] = {
					['regular'] = false,
					['water'] = false,
					['rain'] = false,
					['offroad'] = getElementData(vehicle, 'vehicle:onOffroad') or false
				}
				
				if not isElementInWater(vehicle) then
					changeParameter[vehicle]['regular'] = true

					if rainyWeathers[getWeather()] then
						if not isElementUnderSomething(vehicle) then
							changeParameter[vehicle]['rain'] = true
							changeParameter[vehicle]['regular'] = false
						else
							changeParameter[vehicle]['rain'] = false
						end
					end
				else
					changeParameter[vehicle]['water'] = true
				end
				
				if changeParameter[vehicle]['water'] then
					if grungeLevel ~= 1 then
						doNotChangeMore[vehicle] = false
					else
						doNotChangeMore[vehicle] = true
						currentProgress[vehicle] = math.max(currentProgress[vehicle] - removeGrungeInWaterSpeed, 0)
					end
					
					if not doNotChangeMore[vehicle] then
						currentProgress[vehicle] = currentProgress[vehicle] + removeGrungeInWaterSpeed
						setVehicleDirtTime(vehicle, removeGrungeInWater)
						
						if debugEnabled then
							setVehicleDirtTime(vehicle, debugGrungeTimer)
						end
					
						if currentProgress[vehicle] >= addGrungeTimer[vehicle] then
							currentProgress[vehicle] = 0

							if grungeLevel ~= 1 then
								grungeLevel = grungeLevel-1
							else
								grungeLevel = 1
							end
							
							setVehicleDirtLevel(vehicle, grungeLevel)
						end
					end
				end

                if changeParameter[vehicle]['regular'] then
					if isVehicleOnGround(vehicle) then
						if getVehicleSpeed(vehicle) >= vehicleSpeedLimit then
							if grungeLevel >= 1 and grungeLevel < grungeLimit then
								doNotChangeMore[vehicle] = false
							else
								doNotChangeMore[vehicle] = true
								currentProgress[vehicle] = 0
							end
							
							if not doNotChangeMore[vehicle] then
								currentProgress[vehicle] = currentProgress[vehicle] + addGrungeOnRegularSpeed
								setVehicleDirtTime(vehicle, addGrungeOnRegular)
								
								if debugEnabled then
									setVehicleDirtTime(vehicle, debugGrungeTimer)
								end
								
								if grungeLevel == 1 then
									setVehicleDirtTime(vehicle, addGrungeTimer[vehicle]*2)
								end
								
								if currentProgress[vehicle] >= addGrungeTimer[vehicle] then
									currentProgress[vehicle] = 0
									if grungeLevel < grungeLimit then
										grungeLevel = grungeLevel+1
									else
										if debugEnabled then
											grungeLevel = 1
										else
											grungeLevel = grungeLimit
										end
									end
									
									setVehicleDirtLevel(vehicle, grungeLevel)
								end
							end
						else
							currentProgress[vehicle] = currentProgress[vehicle]
						end
					end
				end
				
				if changeParameter[vehicle]['rain'] then
					if grungeLevel > 2 then
						doNotChangeMore[vehicle] = false
					else
						doNotChangeMore[vehicle] = true
						currentProgress[vehicle] = math.max(currentProgress[vehicle] - removeGrungeInWaterSpeed, 0)
					end
					
					if not doNotChangeMore[vehicle] then
						currentProgress[vehicle] = currentProgress[vehicle] + removeGrungeInRainSpeed
						setVehicleDirtTime(vehicle, removeGrungeInRain)
						
						if currentProgress[vehicle] >= addGrungeTimer[vehicle] then	
							currentProgress[vehicle] = 0

							if grungeLevel > 2 then
								grungeLevel = grungeLevel-1
							elseif grungeLevel < 2 then
								grungeLevel = 1
							else
								grungeLevel = 2
							end
							
							setVehicleDirtLevel(vehicle, grungeLevel)
						end
					end
				end

				-- add dirt when driving on offroad
				if changeParameter[vehicle]['offroad'] then
					if grungeLevel >= 1 and grungeLevel < grungeLimit then
						doNotChangeMore[vehicle] = false
					else
						doNotChangeMore[vehicle] = true
						currentProgress[vehicle] = 0
					end
					
					if not doNotChangeMore[vehicle] then
						currentProgress[vehicle] = currentProgress[vehicle] + addGrungeOnOffroadSpeed
						setVehicleDirtTime(vehicle, addGrungeOnOffroad)
						
						if currentProgress[vehicle] >= addGrungeTimer[vehicle] then
							currentProgress[vehicle] = 0
							if grungeLevel < grungeLimit then
								grungeLevel = grungeLevel+1
							else
								grungeLevel = grungeLimit
							end
							
							setVehicleDirtLevel(vehicle, grungeLevel)
						end
					end
				end
				
				setVehicleDirtProgress(vehicle, currentProgress[vehicle])
			end
		end
	end, dirtRefreshFrequency, 0)
end

function loadVehicleDirt(vehicle)
	if isValidDirtVehicle(vehicle) then
		currentProgress[vehicle] = getVehicleDirtProgress(vehicle)

		setVehicleDirtProgress(vehicle, currentProgress[vehicle])
		setVehicleDirtTime(vehicle, 0)
		
		local grungeValue = getVehicleDirtLevel(vehicle)

		if not grungeValue or grungeValue < 1 then
			grungeValue = 1
		elseif grungeValue > grungeLimit then
			grungeValue = grungeLimit
		end
		
		setVehicleDirtLevel(vehicle, grungeValue)
	end
end

addEventHandler('loadVehicleDirtServer', root, loadVehicleDirt)

addEventHandler('onResourceStart', resourceRoot, function()
	setTimer(function()
		startVehicleGrunge()
			
		for k, vehicle in pairs(getElementsByType('vehicle')) do
			loadVehicleDirt(vehicle)
		end
	end, 100, 1)
end)