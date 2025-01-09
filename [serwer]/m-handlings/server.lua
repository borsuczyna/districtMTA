local handlings = {
    [413] = {
        engineInertia = 10,
        suspensionHighSpeedDamping = 0,
        collisionDamageMultiplier = 0.3,
        suspensionDamping = 0.1,
        seatOffsetDistance = 0.2,
        headLight = long,
        dragCoeff = 1.8,
        steeringLock = 30,
        suspensionLowerLimit = -0.05,
        suspensionUpperLimit = 0.55,
        suspensionAntiDiveMultiplier = 0.3,
        turnMass = 5000,
        brakeBias = 0.55,
        tractionLoss = 0.8,
        monetary = 35000,
        ABS = false,
        suspensionFrontRearBias = 0.5,
        percentSubmerged = 75,
        tractionBias = 0.46,
        numberOfGears = 5,
        suspensionForceLevel = 1,
        animGroup = 0,
        engineAcceleration = 4,
        maxVelocity = 145,
        mass = 4200,
        driveType = 'fwd',
        modelFlags = 1073741824,
        brakeDeceleration = 6,
        handlingFlags = 272629760,
        tractionMultiplier = 0.7,
        engineType = petrol,
        tailLight = small,
    },
    [403] = {
        engineInertia = 30,
        suspensionHighSpeedDamping = 0,
        collisionDamageMultiplier = 0.25,
        suspensionDamping = 0.06,
        seatOffsetDistance = 0.65,
        headLight = 0,
        dragCoeff = 5,
        steeringLock = 25,
        suspensionLowerLimit = -0.2,
        suspensionUpperLimit = 0.4,
        suspensionAntiDiveMultiplier = 0,
        turnMass = 19953.199,
        brakeBias = 0.3,
        tractionLoss = 0.68,
        monetary = 35000,
        ABS = false,
        suspensionFrontRearBias = 0.5,
        percentSubmerged = 90,
        tractionBias = 0.4,
        numberOfGears = 5,
        suspensionForceLevel = 1.6,
        animGroup = 2,
        engineAcceleration = 10,
        maxVelocity = 110,
        mass = 3800,
        driveType = 'r',
        modelFlags = 6008,
        brakeDeceleration = 9,
        handlingFlags = 200,
        tractionMultiplier = 0.99,
        engineType = 'd',
        tailLight = 1,
    },
}

for modelID, settings in pairs(handlings) do
    for handlingName, value in pairs(settings) do
        setModelHandling(modelID, handlingName, value, true)
    end
end

-- handling.xml:
-- <saves>
--     <save model='522' name='NRG-500' description='description'>
--         <handling suspensionLowerLimit='-0.16' engineInertia='5' suspensionHighSpeedDamping='0' centerOfMassY='0.08' collisionDamageMultiplier='0.15' suspensionDamping='0.15' seatOffsetDistance='0' headLight='1' dragCoeff='4' steeringLock='35' suspensionUpperLimit='0.15' suspensionAntiDiveMultiplier='0' turnMass='200' brakeBias='0.5' tractionLoss='0.9' monetary='10000' ABS='false' suspensionFrontRearBias='0.5' percentSubmerged='103' tractionBias='0.49' centerOfMassZ='-0.09' identifier='NRG500' centerOfMassX='0' numberOfGears='5' suspensionForceLevel='0.85' animGroup='4' engineAcceleration='18' maxVelocity='190' mass='400' driveType='r' modelFlags='1002000' brakeDeceleration='15' handlingFlags='2' tractionMultiplier='1.92' engineType='p' tailLight='1'></handling>
--     </save>
--     <save model='468' name='Sanchez' description='description'>
--         <handling suspensionLowerLimit='-0.16' engineInertia='5' suspensionHighSpeedDamping='0' centerOfMassY='0.05' collisionDamageMultiplier='0.15' suspensionDamping='0.15' seatOffsetDistance='0' headLight='1' dragCoeff='5' steeringLock='35' suspensionUpperLimit='0.15' suspensionAntiDiveMultiplier='0' turnMass='195' brakeBias='0.5' tractionLoss='0.9' monetary='10000' ABS='false' suspensionFrontRearBias='0.5' percentSubmerged='103' tractionBias='0.48' centerOfMassZ='-0.09' identifier='DIRTBIKE' centerOfMassX='0' numberOfGears='5' suspensionForceLevel='0.85' animGroup='7' engineAcceleration='18' maxVelocity='170' mass='500' driveType='r' modelFlags='1000000' brakeDeceleration='14' handlingFlags='0' tractionMultiplier='1.6' engineType='p' tailLight='1'></handling>
--     </save>
-- </saves>

local correctedValues = {
    ['f'] = 'fwd', ['r'] = 'rwd', ['4'] = 'awd',
    ['p'] = 'petrol', ['d'] = 'diesel', ['e'] = 'electric',
    ['0'] = 'long', ['1'] = 'small', ['3'] = 'big',
}

local function isHandlingPropertyCorrectable(property )
    local props ={ 
        ['driveType']=true, ['engineType']=true,
        ['headLight']=true, ['tailLight']=true
    }
    
    return props[property] or false
end

local function getCorrectedHandlingValue(value )
    return correctedValues[string.lower(value)] or 'big' -- as 3 cant be converted to 'tall', we use 'big'
end

local function isHandlingPropertyHexadecimal(property )
    if property == 'modelFlags' or property == 'handlingFlags' then
        return true 
    end
    
    return false
end

local function isHandlingPropertyCenterOfMass(property )
    local props = {
        ['centerOfMassX']=true, ['centerOfMassY']=true,
        ['centerOfMassZ']=true
    }
    
    return props[property] or false
end

local function setHandling(model, property, value )
    if isHandlingPropertyCorrectable(property)then
        value = getCorrectedHandlingValue(value )
    elseif isHandlingPropertyHexadecimal(property)then
        value = tonumber('0x' .. value )
    else
        value = tonumber(value )
        if isHandlingPropertyCenterOfMass(property)then
            local com = getModelHandling(model )['centerOfMass']
            local axis = property
            property = 'centerOfMass'
            if axis == 'centerOfMassX' then
                value = { value, com[2], com[3] }
            elseif axis == 'centerOfMassY' then
                value = { com[1], value, com[3] }
            elseif axis == 'centerOfMassZ' then
                value = { com[1], com[2], value }
            end
        end
    end

    if not setModelHandling(model, property, value)then
        -- outputDebugString(tostring(property) )
    end

    return true
end

local function loadHandlingFile()
    local xml = xmlLoadFile('handling.xml')
    if not xml then
        outputDebugString('Failed to load handling.xml')
        return
    end

    local handlingXML = xmlLoadFile('handling.xml' )
    
    for _,node in ipairs(xmlNodeGetChildren(handlingXML)) do
        local model = tonumber(xmlNodeGetAttribute(node, 'model'))
        local handling = xmlNodeGetChildren(node)[1]
        for property,value in pairs(xmlNodeGetAttributes(handling)) do
            setHandling(model, property, value )
        end
    end
    
    return true
end

addEventHandler('onResourceStart', resourceRoot, loadHandlingFile)