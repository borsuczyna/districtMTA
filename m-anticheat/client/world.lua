local blockedProperties = {
    'aircars', 'hovercars', 'extrabunny', 'extrajump', 'burnflippedcars'
}

function checkWorldSpecialProperties()
    for _, property in pairs(blockedProperties) do
        if isWorldSpecialPropertyEnabled(property) then
            setElementData(localPlayer, 'player:gameTime', 6)
            crashPlayer()
        end
    end
end

setTimer(checkWorldSpecialProperties, 15000, 0)

function getRandomPlayers()
    return 1
end