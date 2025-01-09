addEvent('jail:setUIVisible', true)

local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local fonts = {
    dxCreateFont(':m-ui/data/css/fonts/Inter-Bold.ttf', 30, false, 'proof'),
    dxCreateFont(':m-ui/data/css/fonts/Inter-Medium.ttf', 22, false, 'proof'),
}

local function toHumanTime(time)
    local times = {}

    local days = math.floor(time / 86400)
    if days > 0 then
        table.insert(times, ('%d dni'):format(days))
        time = time - days * 86400
    end

    local hours = math.floor(time / 3600)
    if hours > 0 then
        table.insert(times, ('%d godzin'):format(hours))
        time = time - hours * 3600
    end

    local minutes = math.floor(time / 60)
    if minutes > 0 then
        table.insert(times, ('%d minut'):format(minutes))
        time = time - minutes * 60
    end

    local seconds = time
    if seconds > 0 then
        table.insert(times, ('%d sekund'):format(seconds))
    end

    return table.concat(times, ', ')
end

local function renderJail()
    local interfaceSize = getElementData(localPlayer, 'player:interfaceSize')
    local zoom = zoomOriginal * ( 25 / interfaceSize )

    dxDrawRoundedRectangle(sx/2 - 400/zoom, sy - 290/zoom, 800/zoom, 260/zoom, tocolor(25, 25, 25, 200), 10)
    dxDrawText('Więzienie', sx/2, sy - 275/zoom, nil, nil, tocolor(255, 255, 255, 255), 1/zoom, fonts[1], 'center', 'top')

    local jailedBy = getElementData(localPlayer, 'player:jailedBy')
    local jailEndTime = getElementData(localPlayer, 'player:jail')
    local reason = getElementData(localPlayer, 'player:jailReason')
    local currentTime = getRealTime().timestamp
    local timeLeft = jailEndTime - currentTime
    
    dxDrawText(('Zostałeś uwięziony przez %s\nPozostały czas: %s\nPowód: %s'):format(jailedBy, toHumanTime(timeLeft), reason), sx/2 - 380/zoom, sy - 210/zoom, sx/2 + 380/zoom, sy - 30/zoom, tocolor(255, 255, 255, 200), 1/zoom, fonts[2], 'center', 'top', true, true)
end

addEventHandler('jail:setUIVisible', resourceRoot, function(visible)
    if visible then
        addEventHandler('onClientRender', root, renderJail)
    else
        removeEventHandler('onClientRender', root, renderJail)
    end
end)