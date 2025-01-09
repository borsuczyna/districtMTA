local blast = dxCreateTexture("data/blast.png")
assert(blast, "Anti-Cheat: Anti-replacement deteced!")
local sx, sy = guiGetScreenSize()
local blastRt = dxCreateRenderTarget(sx, sy, true)

local getMatrix = getElementMatrix
local screenFromWorldPosition = getScreenFromWorldPosition
local setRenderTarget = dxSetRenderTarget
local drawImage = dxDrawImage
local isClear = isLineOfSightClear

function isInAngle(current, angles)
    for k,v in pairs(angles) do
        if current >= v[1] and current <= v[2] then
            return true
        end
    end
end

function getOffset(m, offX, offY, offZ)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

function drawVisualLights(veh)
    local l = getVehicleLights(veh)
    if not l then return end

    local m = nil
    local m = getMatrix(veh)
    if not m then return end

    --if veh == getPedOccupiedVehicle(localPlayer) then return end
    local cx, cy, cz = getCameraMatrix()
    local rx, ry, rz = getElementRotation(veh)
    local _, _, crz = getElementRotation(getCamera())
    local a = angleDiff(crz, rz)
    local activeModes = getElementData(veh, "vehicle:els:modes") or {}
    local modes = getVehicleModes(veh)
    
    local drawn = {}
    
    local function drawLights(blasts)
        for k,v in pairs(modes) do
            if activeModes[k] then
                if (v.last or 0) < getTickCount() then
                    v.last = getTickCount() + v.delay
                    v.index = (v.index or 0) + 1
                    if v.index > #v then
                        v.index = 1
                    end
                end

                for e,d in pairs(blasts and l.blasts or l.lights) do
                    local group = d.group or d[4] or 1

                    if v[v.index][group] and not drawn[tostring(blasts)..tostring(e)] then
                        local pos = d.position or d[1]
                        local color = d.color or d[2]
                        local size = d.size or d[3]
                        local angle = d.angle or d[5] or {{0, 360},{-360,0}}
            
                        if isInAngle(a, angle) then
                            local x, y, z = getOffset(m, pos[1], pos[2], pos[3])
                            queueCorona(x, y, z, size, color)
                            drawn[tostring(blasts)..tostring(e)] = true
                        end
                    end
                end
            end
        end

        drawCoronas()
    end

    drawLights(true)
    drawLights(false)
end