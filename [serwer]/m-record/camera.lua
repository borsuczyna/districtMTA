local interpolating = false
local interpolationTime = 3000
local cameraEasing = "InOutQuad"
local cameraInterpolation = {
    {2080.173, -1732.959, 14},
    {2070.120, -1734.485, 13.555},

    {2068.801, -1732.874, 13.876},
    {2069.147, -1731.308, 13.876},

    80,
    80,
}

local function interpolateCamera()
    local now = getTickCount()
    local elapsedTime = now - interpolating
    local progress = elapsedTime / interpolationTime

    if progress >= 1 then
        interpolating = false
        removeEventHandler("onClientPreRender", root, interpolateCamera)
        return
    end

    local x, y, z = interpolateBetween(
        cameraInterpolation[1][1], cameraInterpolation[1][2], cameraInterpolation[1][3],
        cameraInterpolation[2][1], cameraInterpolation[2][2], cameraInterpolation[2][3],
        progress,
        cameraEasing
    )

    local lx, ly, lz = interpolateBetween(
        cameraInterpolation[3][1], cameraInterpolation[3][2], cameraInterpolation[3][3],
        cameraInterpolation[4][1], cameraInterpolation[4][2], cameraInterpolation[4][3],
        progress,
        cameraEasing
    )

    local fov = interpolateBetween(
        cameraInterpolation[5],
        0,
        0,
        cameraInterpolation[6],
        0,
        0,
        progress,
        cameraEasing
    )

    setCameraMatrix(x, y, z, lx, ly, lz, 0, fov)
end

function startCameraInterpolation()
    interpolating = getTickCount()
    addEventHandler("onClientPreRender", root, interpolateCamera)

    -- startPlaybackCommand('', '')
end

-- bindKey("l", "down", startCameraInterpolation)
-- setCameraTarget(localPlayer)