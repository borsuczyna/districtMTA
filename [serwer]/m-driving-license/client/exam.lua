addEvent('drivingLicense:startExam', true)
addEvent('drivingLicense:finishExam', true)

local examVehicle = false
local examData = false
local examCheckpoint = 0
local examMarker = false
local examBlip = false

local function insideMarkerCheck()
    if not examMarker or not isElement(examMarker) then return end
    if not examVehicle or not isElement(examVehicle) then return end
    
    local currentCheckpoint = examData.checkpoints[examCheckpoint]
    if not currentCheckpoint then return end

    local x, y, z = getElementPosition(examVehicle)
    local mx, my, mz = getElementPosition(examMarker)
    local distance = getDistanceBetweenPoints3D(x, y, z, mx, my, mz)
    local maxDistance = currentCheckpoint[5] or 3.5

    if distance < maxDistance then
        local wantedAngle = currentCheckpoint[6]
        if wantedAngle then
            local rx, ry, rz = getElementRotation(examVehicle)
            local diff = angleDifference(rz, wantedAngle)
            local maxDiff = currentCheckpoint[7] or 10

            if math.abs(diff) < maxDiff then
                nextCheckpoint()
            end
        else
            nextCheckpoint()
        end
    end
end

function nextCheckpoint()
    if examMarker and isElement(examMarker) then
        destroyElement(examMarker)
    end

    if examBlip and isElement(examBlip) then
        destroyElement(examBlip)
    end
    
    examCheckpoint = examCheckpoint + 1

    local checkpoint = examData.checkpoints[examCheckpoint]
    if not checkpoint then
        finishExam(true)
        return
    end

    local callback = examData.callbacks[examCheckpoint]
    if callback then
        callback()
    end

    local text, x, y, z = unpack(checkpoint)
    local vehicleType = getVehicleType(examVehicle)
    local marker = createMarker(x, y, z - 0.8, vehicleType == 'Plane' and 'ring' or 'cylinder', 3.5, 255, 0, 0, vehicleType == 'Plane' and 255 or 0)
    examBlip = createBlipAttachedTo(marker, 41, 2, 255, 0, 0, 255, 0, 99999, localPlayer)
    setElementData(marker, 'marker:icon', 'none')
    setElementData(marker, 'marker:title', '')
    setElementData(marker, 'marker:desc', '')

    if text and #text > 0 then
        setSmallText(text)
    else
        setSmallInfoUIVisible(false)
    end

    examMarker = marker
end

addEventHandler('drivingLicense:startExam', resourceRoot, function(exam, vehicle)
    examData = examsData[exam]
    examVehicle = vehicle
    examCheckpoint = 0
    
    addEventHandler('onClientRender', root, insideMarkerCheck)
    nextCheckpoint()
end)

function finishExam(success, fromServer)
    if examMarker and isElement(examMarker) then
        destroyElement(examMarker)
    end

    if examBlip and isElement(examBlip) then
        destroyElement(examBlip)
    end

    if examVehicle and isElement(examVehicle) then
        destroyElement(examVehicle)
    end

    if not fromServer then
        triggerServerEvent('drivingLicense:finishExam', resourceRoot, success)
    end
    
    setSmallInfoUIVisible(false)
    destroyAllExamElements()
    removeEventHandler('onClientRender', root, insideMarkerCheck)
end

addEventHandler('drivingLicense:finishExam', resourceRoot, finishExam)