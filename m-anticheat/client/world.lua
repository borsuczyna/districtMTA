local blockedProperties = {
    'aircars', 'hovercars', 'extrabunny', 'extrajump', 'burnflippedcars'
}

function checkWorldSpecialProperties()
    for _, property in pairs(blockedProperties) do
        if isWorldSpecialPropertyEnabled(property) then
            ban(localPlayer, 'World special properties')
        end
    end
end

setTimer(checkWorldSpecialProperties, 15000, 0)

function getRandomPlayers()
    return 1
end