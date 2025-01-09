addEvent('missions:onCameraInterpolationFinished')

local camera = false

addEventHandler('onClientRender', root, function()
    if not camera then return end

    if camera.mode == 'attached' then
        if not isElement(camera.element) then
            camera = false
            return
        end

        local x, y, z = getPositionFromElementOffset(camera.element, camera.offset.x, camera.offset.y, camera.offset.z)
        local lx, ly, lz = getPositionFromElementOffset(camera.element, camera.lookAt.x, camera.lookAt.y, camera.lookAt.z)

        setCameraMatrix(x, y, z, lx, ly, lz, camera.roll, camera.fov)
    elseif camera.mode == 'interpolating' then
        local now = getTickCount()
        local progress = (now - camera.startTime) / (camera.endTime - camera.startTime)
        if progress >= 1 then
            setCameraMatrix(camera.endPos.x, camera.endPos.y, camera.endPos.z, camera.endLookAt.x, camera.endLookAt.y, camera.endLookAt.z)

            if camera.reset then
                setCameraTarget(localPlayer)
            end

            camera = false

            triggerEvent('missions:onCameraInterpolationFinished', resourceRoot)
            return
        end

        local easing = camera.easing
        local x, y, z = interpolateBetween(camera.startPos.x, camera.startPos.y, camera.startPos.z, camera.endPos.x, camera.endPos.y, camera.endPos.z, progress, easing)
        local lx, ly, lz = interpolateBetween(camera.startLookAt.x, camera.startLookAt.y, camera.startLookAt.z, camera.endLookAt.x, camera.endLookAt.y, camera.endLookAt.z, progress, easing)
        local roll, fov = interpolateBetween(camera.roll, camera.fov, 0, camera.endRoll, camera.endFov, 0, progress, easing)

        setCameraMatrix(x, y, z, lx, ly, lz, roll, fov)
    end
end)

function resetCamera()
    setCameraTarget(localPlayer)
    camera = false
end

defineMissionAction({
    name = 'resetCamera',
    editorName = 'Zresetuj kamerę',
    arguments = {},
    callback = function()
        resetCamera()
    end
})

defineMissionAction({
    name = 'fadeCamera',
    editorName = 'Ściemnij kamerę',
    arguments = {
        Checkbox('Ściemnij'),
        Number('Czas', 1),
        Checkbox('Poczekaj na zakończenie')
    },
    callback = function(shouldFade, time, wait)
        fadeCamera(not shouldFade, time)

        if wait then
            await(sleep(time * 1000))
        end
    end,
})

defineMissionAction({
    name = 'setCameraPosition',
    editorName = 'Ustaw kamerę',
    arguments = {
        Position('Pozycja'),
        Position('Patrz na')
    },
    callback = function(position, lookAt)
        setCameraMatrix(position.x, position.y, position.z, lookAt.x, lookAt.y, lookAt.z)
    end
})

defineMissionAction({
    name = 'setAttachedCamera',
    editorName = 'Ustaw kamerę na elemencie',
    arguments = {
        String('Element', ''),
        Position('Offset'),
        Position('Patrz na'),
        Number('Roll', 0),
        Number('Fov', 80)
    },
    callback = function(element, offset, lookAt, roll, fov)
        local element = getMissionElement(element)
        if not isElement(element) then return end

        camera = {
            element = element,
            offset = offset,
            lookAt = lookAt,
            roll = roll,
            fov = fov,
            mode = 'attached'
        }
    end
})

defineMissionAction({
    name = 'interpolateCamera',
    editorName = 'Przesuń kamerę',
    arguments = {
        Position('Pozycja'),
        Position('Patrz na'),
        Position('Pozycja końcowa'),
        Position('Patrz na końcowe'),
        Number('Czas (ms)', 1000),
        Number('Poczatkowy roll', 0),
        Number('Końcowy roll', 0),
        Number('Początkowy FOV', 80),
        Number('Końcowy FOV', 80),
        Select('Easing', { "Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve" }, 'Linear'),
        Checkbox('Zresetuj na koniec'),
        Checkbox('Poczekaj na zakończenie')
    },
    callback = function(startPos, startLookAt, endPos, endLookAt, time, startRoll, endRoll, startFov, endFov, easing, reset, wait)
        camera = {
            startPos = startPos,
            startLookAt = startLookAt,
            endPos = endPos,
            endLookAt = endLookAt,
            startTime = getTickCount(),
            endTime = getTickCount() + time,
            roll = startRoll,
            endRoll = endRoll,
            fov = startFov,
            endFov = endFov,
            easing = easing,
            reset = reset,
            mode = 'interpolating'
        }

        if wait then
            await(waitForCameraInterpolationFinish())
        end
    end,
})

function waitForCameraInterpolationFinish()
    return Promise:new(function(resolve, _)
        addEventHandler('missions:onCameraInterpolationFinished', resourceRoot, resolve)
    end)
end