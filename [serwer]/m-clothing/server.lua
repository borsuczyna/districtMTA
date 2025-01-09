addEvent('clothing:setClothes')
addEventHandler('clothing:setClothes', root, function(hash, player, model)
    for i, v in ipairs(clothes) do
        if v.model == model then
            setElementModel(player, model)
            setElementData(player, 'player:skin', model)
            exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zmieniono ubranie na: '..v.name})
            return
        end
    end

    exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono takiego ubrania'})
end)