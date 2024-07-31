local cache = {}

function getNpcElement(hash)
    if not cache[hash] then
        cache[hash] = exports['m-jobs']:getPedByHash(hash)
    end

    return cache[hash]
end

local function drawOutlinedText(text, x, y, x2, y2, color, ...)
    dxDrawText(text, x - 1, y - 1, x - 1, y - 1, tocolor(0, 0, 0, 90), ...)
    dxDrawText(text, x + 1, y - 1, x + 1, y - 1, tocolor(0, 0, 0, 90), ...)
    dxDrawText(text, x - 1, y + 1, x - 1, y + 1, tocolor(0, 0, 0, 90), ...)
    dxDrawText(text, x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 90), ...)
    dxDrawText(text, x, y, x, y, color, ...)
end

local function renderNpcOrder(npcElement, order)
    local x, y, z = getElementPosition(npcElement)
    local x, y, z = x, y, z + 1.5

    local sx, sy = getScreenFromWorldPosition(x, y, z)
    if not sx or not sy then return end

    local size = 50/zoom
    local width = #order * size + 8/zoom * (#order - 1)

    local x = -width/2

    dxDrawImage(sx - width/2 - size * 0.2, sy - size * 0.3, width + size * 0.4, size * 1.85, 'data/cloud.png', 0, 0, 0, tocolor(255, 255, 255), false)

    for _, item in pairs(order) do
        dxDrawImage(sx + x - size * 0.2, sy - size * 0.2, size * 1.4, size * 1.4, 'data/' .. item[2] .. '.png', 0, 0, 0, tocolor(255, 255, 255), false)
        drawOutlinedText('x' .. item[1], sx + x + size * 1.05, sy + size * 0.85, nil, nil, tocolor(255, 255, 255), 1.3, 'default-bold', 'right', 'center')

        x = x + size + 8/zoom
    end
end

function renderNpcOrders()
    local npcs = exports['m-jobs']:getJobData('npcs')
    if not npcs then return end

    for _, npc in pairs(npcs) do
        local npcElement = getNpcElement(npc.hash)
        if not isElement(npcElement) then return end

        renderNpcOrder(npcElement, npc.order)
    end
end

function clickPed(button, state, _, _, _, _, _, element)
    if button ~= 'left' or state ~= 'down' then return end
    if not isElement(element) or getElementType(element) ~= 'ped' then return end

    local hash = exports['m-jobs']:getPedHash(element)
    if not hash then return end

    local px, py, pz = getElementPosition(localPlayer)
    local x, y, z = getElementPosition(element)
    local hit, hx, hy, hz = processLineOfSight(px, py, pz, x, y, z, true, false, false, true, false, false, false, false, localPlayer, true)
    local rot = findRotation(px, py, x, y)
    setGoToPosition(hx or x, hy or y, hz or z, rot)
    goToAction = {hash, {
        type = 'server',
        event = 'jobs:burger:clickNpc',
    }}
end