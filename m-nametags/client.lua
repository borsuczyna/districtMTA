local fonts = {
    [1] = exports['m-ui']:getFont('Inter-Medium', 12),
    [2] = exports['m-ui']:getFont('Inter-Regular', 9),
    [3] = exports['m-ui']:getFont('Inter-Black', 12),
}

local rankColors = {}

function getPlayerColor(player)
    local color = '#cccccc'
    local premium = getElementData(player, 'player:premium')

    if premium then
        color = '#ffcc00'
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
    local x, y = getScreenFromWorldPosition(x, y, z + 0.4)
    if not x or not y then return end

    local scale = 1 - dist / 20
    if scale < 0.2 then return end

    local rank = getElementData(player, 'player:rank')
    local organization = getElementData(player, 'player:organization')
    local premium = getElementData(player, 'player:premium')
    local afk = getElementData(player, 'player:afk')
    local color = getPlayerColor(player)

    local icons = {}

    if rank then
        table.insert(icons, {rank, getRankColor(rank)})
    end

    if premium then
        table.insert(icons, {'premium'})
    end

    if afk then
        table.insert(icons, {'afk', tocolor(255, 0, 0, 200)})
    end

    local iconsWidth = #icons * 25*scale + (#icons - 1) * 5*scale

    for i, icon in ipairs(icons) do
        dxDrawImage(x - iconsWidth/2 + (i-1) * (25*scale + 5*scale), y - 48*scale, 25*scale, 25*scale, 'img/'..icon[1]..'.png', 0, 0, 0, icon[2])
    end
    
    if organization then
        dxDrawText(organization, x + 1, y + 1, nil, nil, tocolor(0,0,0,155), scale, fonts[2], 'center', 'top', false, false, false, false, true)
        dxDrawText(organization, x, y, nil, nil, tocolor(200,200,200,225), scale, fonts[2], 'center', 'top', false, false, false, true, true)
    end

    dxDrawText('('..playerID..') '..getPlayerName(player), x + 1, y + 1, nil, nil, tocolor(0,0,0,155), scale, fonts[1], 'center', 'bottom', false, false, false, false, true)
    dxDrawText(color .. '(' .. playerID ..') #ffffff'..getPlayerName(player), x, y, nil, nil, tocolor(255,215,125,225), scale, fonts[1], 'center', 'bottom', false, false, false, true, true)
end


function renderNametags()
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
    addEventHandler('onClientRender', root, renderNametags, true, 'high+9999')
end)