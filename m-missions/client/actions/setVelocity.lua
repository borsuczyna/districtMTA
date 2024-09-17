defineMissionAction({
    name = 'setVelocity',
    editorName = 'Ustaw prędkość elementu',
    arguments = {
        String('ID elementu', ''),
        Position('Prędkość')
    },
    callback = function(specialId, velocity)
        local element = getMissionElement(specialId)
        if not element then return end

        local vx, vy, vz = getRealtivePositionFromElementOffset(element, velocity.x, velocity.y, velocity.z)
        setElementVelocity(element, vx, vy, vz)
    end
})