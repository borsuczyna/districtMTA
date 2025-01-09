local fonts = {
    [1] = exports['m-ui']:getFont('Inter-SemiBold', 11),
    [2] = exports['m-ui']:getFont('Inter-Regular', 9),
    [3] = exports['m-ui']:getFont('Inter-Black', 12),
}

local rankColors = {}

function getPlayerColor(player)
    local color = '#cccccc'
    local premium = getElementData(player, 'player:premium-end')
    local rank = getElementData(player, 'player:rank')

    if premium then
        color = '#ffcc00'
    end
    
    if rank then
        local r, g, b = exports['m-admins']:getRankColor(rank)
        color = string.format('#%02x%02x%02x', r, g, b)
    end

    return color
end

function getRankColor(rank)
    if not rankColors[rank] then
        local r, g, b = exports['m-admins']:getRankColor(rank)
        rankColors[rank] = tocolor(r, g, b, 200)
    end

    return rankColors[rank]
end

function renderNametag(player)
    if not getElementData(player, 'player:spawn') then return end
    if getElementAlpha(player) == 0 then return end
    
    local playerID = getElementData(player, 'player:id')
    if not playerID then return end

    local x, y, z = getPedBonePosition(player, 8)
    local dist = math.max(getDistanceBetweenPoints3D(Vector3(getCameraMatrix()), Vector3(x, y, z)) - 5, 0)
    local x, y = getScreenFromWorldPosition(x, y, z + 0.25)
    if not x or not y then return end

    local scale = 1 - dist / 20
    if scale < 0.2 then return end

    local rank = getElementData(player, 'player:rank')
    local organization = getElementData(player, 'player:organization')
    local premium = getElementData(player, 'player:premium-end')
    local rp = getElementData(player, 'player:statusRP')
    local afk = getElementData(player, 'player:afk')
    local mute = getElementData(player, 'player:mute')
    local color = getPlayerColor(player)

    local icons = {}

    if rank then
        table.insert(icons, {'rank', getRankColor(rank)})
    end

    if premium then
        table.insert(icons, {'premium', tocolor(255, 200, 0, 225)})
    end

    if rp then
        table.insert(icons, {'rp', tocolor(125, 255, 125, 225)})
    end

    if afk then
        table.insert(icons, {'afk', tocolor(155, 155, 155, 225)})
    end

    if mute then
        table.insert(icons, {'mute', tocolor(255, 55, 55, 225)})
    end

    local iconsWidth = #icons * 32*scale + (#icons - 1) * 1*scale

    for i, icon in ipairs(icons) do
        dxDrawImage(x - iconsWidth/2 + (i-1) * (32*scale + 1*scale), y - 55*scale, 32*scale, 32*scale, 'img/'..icon[1]..'.png', 0, 0, 0, icon[2])
    end
    
    if organization then
        dxDrawText(organization, x + 1, y + 1, nil, nil, tocolor(0,0,0,155), scale, fonts[2], 'center', 'top', false, false, false, false, true)
        dxDrawText(organization, x, y, nil, nil, tocolor(200,200,200,225), scale, fonts[2], 'center', 'top', false, false, false, true, true)
    end

    dxDrawText('('..playerID..') '..getPlayerName(player), x + 1, y + 1, nil, nil, tocolor(0,0,0,155), scale, fonts[1], 'center', 'bottom', false, false, false, false, true)
    dxDrawText(color .. '(' .. playerID ..') #ffffff'..getPlayerName(player), x, y, nil, nil, tocolor(255,215,125,225), scale, fonts[1], 'center', 'bottom', false, false, false, true, true)
end

function renderNametags()
    if getElementData(localPlayer, 'player:hiddenNametags') then return end

    local x, y, z = getElementPosition(getCamera())
    for _,player in pairs(getElementsWithinRange(x, y, z, 20, 'player')) do
        if player ~= localPlayer then
            renderNametag(player)
        end
    end

    for k,v in pairs(getElementsByType('player')) do
        setPlayerNametagShowing(v, false)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setPedTargetingMarkerEnabled(false)
    addEventHandler('onClientRender', root, renderNametags, true, 'high+9999')
end)