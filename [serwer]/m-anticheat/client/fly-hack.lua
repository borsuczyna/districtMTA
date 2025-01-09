local lastContactElement = nil

function checkFlyHack()
    if not getElementData(localPlayer, 'player:spawn') then return end
    if exports['m-admins']:doesPlayerHavePermission(localPlayer, 'noclip') then return end
    
    if not getCameraTarget() or getCameraTarget() ~= localPlayer then return end 
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end  
    
    local playerPos = Vector3(getElementPosition(localPlayer))
    local gameType = getPedMoveState(localPlayer)
    local actualInterior = getElementInterior(localPlayer)
    local actualDimension = getElementDimension(localPlayer)
    local contactElement = getPedContactElement(localPlayer)

    if contactElement and contactElement ~= lastContactElement then
        print('new contact element')
        lastContactElement = contactElement
    end

    if isPedWearingJetpack(localPlayer) and not exports['m-admins']:doesPlayerHavePermission(localPlayer, 'command:jetpack') then
        setElementData(localPlayer, 'player:gameTime', 8)
        crashPlayer()
    end

    if contactElement and getElementType(contactElement) == 'vehicle' then
        local vehicleController = getVehicleController(contactElement)
        if vehicleController then return end

        local vehiclePos = Vector3(getElementPosition(contactElement))
        local groundPos = getGroundPosition(vehiclePos)
        local dist = vehiclePos.z - groundPos

        -- Sprawdzanie, czy pojazd nie jest zawieszony w powietrzu
        if dist > 10 and contactElement == lastContactElement then
            setElementData(localPlayer, 'player:gameTime', 8)
            crashPlayer()
        end
    end

    if gameType ~= 'fall' or (not lastPos or math.floor(playerPos.z) <= math.floor(lastPos.z)) 
        or (not lastInterior or lastInterior ~= actualInterior) 
        or (not lastDimension or lastDimension ~= actualDimension) then 

        lastPos = playerPos
        lastInterior = actualInterior
        lastDimension = actualDimension
    elseif gameType == 'fall' and not isPedOnGround(localPlayer) 
        and not isElementInWater(localPlayer) 
        and not isPedInVehicle(localPlayer) 
        and not isPedWearingJetpack(localPlayer) 
        and contactElement == nil then

        local groundPos = getGroundPosition(playerPos)
        local dist = (playerPos.z - groundPos)
        local distT = #(playerPos - lastPos)
        local pingPlayer = getPlayerPing(localPlayer)

        if dist > 10 and dist <= 1000 and distT <= 200 and pingPlayer <= 200 then 
            local x, y, z = playerPos.x, playerPos.y, playerPos.z
            local searchRadius = 2

            for i = 0, 360, 15 do
                local vx = x + math.cos(math.rad(i)) * searchRadius
                local vy = y + math.sin(math.rad(i)) * searchRadius
                local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(x, y, z + 2, vx, vy, z - 2, true, false, false, true, false, true, false)

                if hit then
                    return false
                end
            end

            setElementData(localPlayer, 'player:gameTime', 8)
            crashPlayer()
        end
    end
end

setTimer(checkFlyHack, 3000, 0)