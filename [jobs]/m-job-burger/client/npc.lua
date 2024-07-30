local cache = {}

function getNpcElement(hash)
    if not cache[hash] then
        cache[hash] = exports['m-jobs']:getPedByHash(hash)
    end

    return cache[hash]
end

local function renderNpcOrder(npcElement, order)
    local x, y, z = getElementPosition(npcElement)
    local x, y, z = x, y, z + 1.5

    local text = 'Order:\n'
    for _, item in pairs(order) do
        text = text .. item[1] .. 'x ' .. item[2] .. '\n'
    end

    local sx, sy = getScreenFromWorldPosition(x, y, z)
    if not sx or not sy then return end

    dxDrawText(text, sx, sy, sx, sy, tocolor(255, 255, 255), 1, 'default-bold', 'center', 'center')
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