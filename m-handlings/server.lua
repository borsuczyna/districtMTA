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
    }
}

for modelID, settings in pairs(handlings) do
    for handlingName, value in pairs(settings) do
        setModelHandling(modelID, handlingName, value)
    end
end