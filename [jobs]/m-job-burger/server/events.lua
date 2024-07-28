addEvent('jobs:burger:clickElement', true)
addEventHandler('jobs:burger:clickElement', resourceRoot, function(event, objectHash)
    if event == 'trash' then
        stopPlayerCarryObject(client)
    elseif event == 'meat' then
        local carrying = getPlayerCarryObject(client)
        if carrying then return end

        makePlayerCarryObject(client, 'burger/meat')
    end
end)