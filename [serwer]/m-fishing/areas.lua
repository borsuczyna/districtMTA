local fishingAreas = {}
local element = createElement('fishing-areas')

local function isPointInsideFishingArea(x, y, dist)
    for i, area in ipairs(fishingAreas) do
        local rx, ry = getElementPosition(area)
        local distance = getDistanceBetweenPoints2D(x, y, rx + 75, ry + 75)
        if distance < (dist or 75) then
            return true
        end
    end
end

function isPlayerInFishingArea(player)
    local x, y, z = getElementPosition(player)
    return isPointInsideFishingArea(x, y)
end

local function getRandomPosition()
    -- local x = math.random(-3000, 3000)
    -- local y = math.random(-3750, -3004)
    -- if x > 145 and x < 857 then
    --     y = math.random(-3750, -2204)
    -- end

    -- {3153.860, -2080.200, 16.109},
    local x = math.random(3150, 3800)
    local y = math.random(-3000, 3000)

    if isPointInsideFishingArea(x, y, 160) then
        return getRandomPosition()
    end

    return x, y
end

local function createRandomArea()
    local x, y = getRandomPosition()
    local area = createRadarArea(x - 75, y - 75, 150, 150, 50, 100, 255, 150)
    setElementData(area, 'area:hoverText', 'Łowisko')
    setElementData(area, 'area:className', 'fishing-area')
    addEventHandler('onRadarAreaHitByElement', area, function(hitElement)
        if getElementType(hitElement) == 'player' then
            triggerClientEvent(hitElement, 'onClientShowFishingAreaInfo', resourceRoot, area)
        end
    end)

    setElementParent(area, element)
    return area
end

for i = 1, 50 do
    table.insert(fishingAreas, createRandomArea())
end