addCommandHandler('dim', function(plr, cmd, dim)
    if doesPlayerHavePermission(plr, 'command:dim') then
        if not dim then
            return exports['m-notis']:addNotification(plr, 'info', 'Informacja', 'Znajdujesz się w dimension: '..getElementDimension(plr))
        end

        dim = tonumber(dim)
        if not dim then
            return exports['m-notis']:addNotification(plr, 'error', 'Błąd', 'Niepoprawny format, użycie: /dim (dimension)')
        end

        setElementDimension(plr, dim)
        exports['m-notis']:addNotification(plr, 'success', 'Sukces', 'Zmieniono dimension')
    end
end)

addCommandHandler('int', function(plr, cmd, int)
    if doesPlayerHavePermission(plr, 'command:int') then
        if not int then
            return exports['m-notis']:addNotification(plr, 'info', 'Informacja', 'Znajdujesz się w interiorze: '..getElementInterior(plr))
        end

        int = tonumber(int)
        if not int then
            return exports['m-notis']:addNotification(plr, 'error', 'Błąd', 'Niepoprawny format, użycie: /int (interior)')
        end

        setElementInterior(plr, int)
        exports['m-notis']:addNotification(plr, 'success', 'Sukces', 'Zmieniono interior')
    end
end)