function checkSpeedHack()
    if getGameSpeed() ~= 1 then
        setElementData(localPlayer, 'player:gameTime', 7)
        crashPlayer()
    end
end

setTimer(checkSpeedHack, 10000, 0)

addEventHandler('onClientRender', root, function()    
    setPedAnimationSpeed(localPlayer, 'sprint_civi', 1)
    setPedAnimationSpeed(localPlayer, 'sprint_panic', 1)
    setPedAnimationSpeed(localPlayer, 'sprint_wuzi', 1)
end, false, 'low+5')

function setPlayerNametags()
    return 1
end