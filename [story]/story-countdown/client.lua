local countdownData = false
-- local countdownPosition = {454.26398, 1528.14258, 51.98533}
-- local countdownLookAt = {450.26398, 1528.14258, 51.98533}
-- local countdownSize = 40

local countdowns = {
    {
        position = {454.26398, 1528.14258, 51.98533},
        lookAt = {450.26398, 1528.14258, 51.98533},
        size = 40
    },
    {
        position = {990.256, -1416.087, 20.734},
        lookAt = {990.157, -1435.247, 13.586},
        size = 6
    },
    {
        position = {1292.317, -1430.950, 21.086},
        lookAt = {1287.420, -1430.822, 21.086},
        size = 6
    },
    {
        position = {1479.870, -1685.055, 19.295},
        lookAt = {1479.850, -1690.553, 19.295},
        size = 6
    },
    {
        position = {69.012, 927.871, 50.523},
        lookAt = {68.310, 908.479, 40.523},
        size = 15
    },
    {
        position = {690.357, 1159.551, 49.154},
        lookAt = {724.020, 1149.972, 49.154},
        size = 25
    },
    {
        position = {-165.749, 872.363, 43.949},
        lookAt = {-190.350, 837.095, 43.949},
        size = 25
    }
}

function updateCountdown()
    local seconds = math.floor((countdownData.startClientTick - getTickCount()) / 1000)
    local left = tonumber(seconds)
    local days, hours, minutes;

    if left > 0 then
        days = math.floor(seconds / 86400)
        seconds = seconds % 86400
        hours = math.floor(seconds / 3600)
        seconds = seconds % 3600
        minutes = math.floor(seconds / 60)
        seconds = seconds % 60
    else
        days = 0
        hours = 0
        minutes = 0
        seconds = 0
    end

    local isAboutToStart = (left < 600) and (1 - (left / 600)) or 0

    local text = string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)

    dxSetRenderTarget(countdownData.renderTarget, true)
    
    for i = 1, 3 do
        dxDrawImage(-50, -30, 900, 460, 'data/stripes-' .. countdownData.stripe .. '.png')
        dxDrawImage(50, 0, 700, 400, 'data/hollo.png')
    end
    
    local x = (isAboutToStart > 0) and math.random(-10 * isAboutToStart, 10 * isAboutToStart) or 0
    dxDrawText('LIVE EVENT', -8 + x * 4, 0, 800, 150, 0xAA000000, 3, 'default-bold', 'center', 'bottom')
    dxDrawText('LIVE EVENT', 8 + x * 4, 0, 800, 150, 0xFFBD00FF, 3, 'default-bold', 'center', 'bottom')
    dxDrawText('LIVE EVENT', 0 + x * 4, 0, 800, 150, 0xFFFFFFFF, 3, 'default-bold', 'center', 'bottom')
    dxDrawText(text, -15 + x * 4, 0, 800, 400, 0xAA000000, 8, 'default-bold', 'center', 'center')
    dxDrawText(text, 15 + x * 2, 0, 800, 400, 0xFFBD00FF, 8, 'default-bold', 'center', 'center')
    dxDrawText(text, 0 + x, 0, 800, 400, 0xFFFFFFFF, 8, 'default-bold', 'center', 'center')
    dxDrawText('4 listopada 20:00', -8 + x * 4, 250, 800, 400, 0xAA000000, 3, 'default-bold', 'center', 'top')
    dxDrawText('4 listopada 20:00', 8 + x * 4, 250, 800, 400, 0xFFBD00FF, 3, 'default-bold', 'center', 'top')
    dxDrawText('4 listopada 20:00', 0 + x * 4, 250, 800, 400, 0xFFFFFFFF, 3, 'default-bold', 'center', 'top')
    dxSetRenderTarget()

    countdownData.stripe = countdownData.stripe + 1
    if countdownData.stripe > 4 then
        countdownData.stripe = 1
    end

    if left > 0 then
        setTimer(updateCountdown, 100, 1)
    end
end

function renderCountdown()
    -- local x, y, z = unpack(countdownPosition)
    -- local lx, ly, lz = unpack(countdownLookAt)
    -- local left = math.floor(countdownData.startClientTick - getTickCount())
    -- local isAboutToStart = (left < 0) and (1 - (left / -5000)) or 1

    -- dxDrawMaterialLine3D(x, y, z + countdownSize/2, x, y, z - countdownSize/2, countdownData.renderTarget, 800/400 * countdownSize, tocolor(255, 255, 255, 255 * isAboutToStart), lx, ly, lz)

    -- if isAboutToStart <= 0 then
    --     removeEventHandler('onClientRender', root, renderCountdown)
    -- end

    local left = math.floor(countdownData.startClientTick - getTickCount())
    local isAboutToStart = (left < 0) and (1 - (left / -5000)) or 1
    local cx, cy, cz = getCameraMatrix()

    for i, countdown in ipairs(countdowns) do
        local x, y, z = unpack(countdown.position)
        local lx, ly, lz = unpack(countdown.lookAt)
        if getDistanceBetweenPoints3D(cx, cy, cz, x, y, z) < 200 then
            dxDrawMaterialLine3D(x, y, z + countdown.size/2, x, y, z - countdown.size/2, countdownData.renderTarget, 800/400 * countdown.size, tocolor(255, 255, 255, 255 * isAboutToStart), lx, ly, lz)
        end

    end
    
    if isAboutToStart <= 0 then
        removeEventHandler('onClientRender', root, renderCountdown)
    end
end

function startCountdown(serverTick, startServerTick)
    countdownData = {
        serverTick = serverTick,
        startServerTick = startServerTick,
        clientTick = getTickCount(),
        startClientTick = getTickCount() + (startServerTick - serverTick),
        renderTarget = dxCreateRenderTarget(800, 400, true),
        stripe = 1
    }

    updateCountdown()
    addEventHandler('onClientRender', root, renderCountdown)
end

addEvent('onCountdownStart', true)
addEventHandler('onCountdownStart', resourceRoot, startCountdown)