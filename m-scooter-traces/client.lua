local traces = {}
local traceTextures = {}
local traceSize = 0.4
local maxTraces = 20
local cx, cy, cz = 0, 0, 0

local function getPlayerTrace(player)
    return getElementData(player, 'player:scooter-trace')
end

local function getTraceTexture(trace)
    if not traceTextures[trace] then
        traceTextures[trace] = dxCreateTexture('data/' .. trace .. '.png')
    end
    return traceTextures[trace]
end

local function renderPlayerTraces(player)
    local trace = getPlayerTrace(player)
    if not trace then return end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle or getElementModel(vehicle) ~= 448 then return end

    local ptraces = traces[player]
    if not ptraces then
        ptraces = {}
        traces[player] = ptraces
    end
    
    local traceTexture = getTraceTexture(trace)
    local lx, ly, lz = getPositionFromElementOffset(player, 0, -0.5, -0.9)
    local px, py, pz = lx, ly, lz
    local fx, fy, fz = false

    local distance = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)
    if distance > 100 then return end

    -- for i, trace in ipairs(ptraces) do
    for i = #ptraces, 1, -1 do
        local alpha = (255 / #ptraces) * i
        local trace = ptraces[i]
        local x, y, z = unpack(trace)

        -- dxDrawLine3D(lx, ly, lz, x, y, z, tocolor(255, 255, 255, 255), traceSize)
        dxDrawMaterialLine3D(lx, ly, lz, x, y, z, true, traceTexture, 0.3, tocolor(255, 255, 255, alpha), 'prefx')
        lx, ly, lz = x, y, z
        if not fx then
            fx, fy, fz = x, y, z
        end
    end

    if #ptraces == 0 or getDistanceBetweenPoints3D(fx, fy, fz, px, py, pz) > traceSize then
        table.insert(ptraces, {px, py, pz})

        while #ptraces > maxTraces do
            table.remove(ptraces, 1)
        end
    end
end

addEventHandler('onClientPreRender', root, function()
    cx, cy, cz = getCameraMatrix()

    for i, player in ipairs(getElementsByType('player', root, true)) do
        renderPlayerTraces(player)
    end
end)

-- remove trace every 100ms
setTimer(function()
    for player, ptraces in pairs(traces) do
        if #ptraces > 0 then
            table.remove(ptraces, 1)
        end
    end
end, 100, 0)

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end