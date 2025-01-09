local blockedProperties = {
    'aircars', 'hovercars', 'extrabunny', 'burnflippedcars'
}

function checkWorldSpecialProperties()
    local gravity = ('%.3f'):format(getGravity())
    if getGameSpeed() ~= 1 or gravity ~= '0.008' then
        setElementData(localPlayer, 'player:gameTime', 7)
        crashPlayer()
    end

    for _, property in pairs(blockedProperties) do
        if isWorldSpecialPropertyEnabled(property) then
            setElementData(localPlayer, 'player:gameTime', 6)
            crashPlayer()
        end
    end
end

setTimer(checkWorldSpecialProperties, 15000, 0)

addEventHandler('onClientRender', root, function()    
    setPedAnimationSpeed(localPlayer, 'sprint_civi', 1)
    setPedAnimationSpeed(localPlayer, 'sprint_panic', 1)
    setPedAnimationSpeed(localPlayer, 'sprint_wuzi', 1)
end, false, 'low+5')

function getRandomPlayers()
    return 1
end