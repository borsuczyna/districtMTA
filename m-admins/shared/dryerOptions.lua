dryerOptions = {
    vehicle = {
        {
            name = 'Zniszcz pojazd',
            action = function(player, element)
                local uid = getElementData(element, 'vehicle:uid')
                if uid then
                    exports['m-notis']:addNotification(player, 'error', 'Suszarka', 'Nie możesz zniszczyć prywatnego pojazdu.')
                    return
                end

                destroyElement(element)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Pojazd został zniszczony.')
            end
        },
        {
            name = 'Zaciągnij/spuść ręczny',
            action = function(player, element)
                local handbrake = not isElementFrozen(element)
                setElementFrozen(element, handbrake)

                local text = handbrake and 'Zaciągnieto' or 'Spuszczono'
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', ('%s ręczny w pojeździe.'):format(text))
            end
        },
        -- {
        --     name = 'Zatankuj pojazd',
        --     action = function(player, element)
        --         local uid = getElementData(element, 'vehicle:uid')
        --         if not uid then
        --             exports['m-notis']:addNotification(player, 'error', 'Suszarka', 'Tylko prywatne pojazdy można zatankować.')
        --             return
        --         end

        --         local maxFuel = getElementData(element, 'vehicle:maxFuel')
        --         setElementData(element, 'vehicle:fuel', maxFuel)
        --         exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Pojazd został zatankowany.')
        --     end
        -- },
        {
            name = 'Przenieś do siebie',
            action = function(player, element)
                local x, y, z = getElementPosition(player)
                setElementPosition(element, x, y, z)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Pojazd został przeniesiony do Ciebie.')
            end
        },
        {
            name = 'Przenieś do pojazdu',
            action = function(player, element)
                local x, y, z = getElementPosition(element)
                setElementPosition(player, x, y, z + 2)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Zostałeś przeniesiony do pojazdu.')
            end
        },
        {
            name = 'Wyślij do przechowalni',
            action = function(player, element)
                local uid = getElementData(element, 'vehicle:uid')
                if not uid then
                    exports['m-notis']:addNotification(player, 'error', 'Suszarka', 'Tylko prywatne pojazdy można chować.')
                    return
                end

                removeElementData(element, 'vehicle:carExchange')
                local success, message = exports['m-core']:putVehicleIntoParking(element)
                if success then
                    exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Pojazd został przeniesiony do przechowalni.')
                else
                    exports['m-notis']:addNotification(player, 'error', 'Suszarka', message)
                end
            end
        },
    },
    player = {
        {
            name = 'Ulecz gracza',
            action = function(player, element)
                setElementHealth(element, 100)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Gracz został uleczony.')
            end
        },
        {
            name = 'Przenieś do siebie',
            action = function(player, element)
                local x, y, z = getElementPosition(player)
                setElementPosition(element, x, y, z)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Gracz został przeniesiony do Ciebie.')
            end
        },
        {
            name = 'Przenieś do gracza',
            action = function(player, element)
                local x, y, z = getElementPosition(element)
                setElementPosition(player, x, y, z)
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Zostałeś przeniesiony do gracza.')
            end
        },
        {
            name = 'Despawnuj gracza',
            action = function(player, element)
                local position = getElementData(element, 'player:spawn')
                setElementPosition(element, Vector3(position))
                exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Gracz został zdespawnowany.')
            end
        },
    }
}

dryerTexts = {
    vehicle = function(element)
        local uid = getElementData(element, 'vehicle:uid') or 'Brak'
        local owner = getElementData(element, 'vehicle:ownerName') or 'Brak'
        local lastDriver = getElementData(element, 'vehicle:lastDriverName') or 'Brak'
        local model = exports['m-models']:getVehicleName(element)

        return ('ID: %s\nWłaściciel: %s\nOstatni kierowca: %s\nModel: %s'):format(uid, owner, lastDriver, model)
    end,
    player = function(element)
        local uid = getElementData(element, 'player:uid') or 'Brak'
        local level = getElementData(element, 'player:level') or 0
        local duty = getElementData(element, 'player:duty') or 'Brak'

        local job = getElementData(element, 'player:job')
        job = job and exports['m-jobs']:getJobName(job) or 'Brak'

        return ('UID: %s\nPoziom: %s\nSłużba: %s\nPraca: %s'):format(uid, level, duty, job)
    end,
}