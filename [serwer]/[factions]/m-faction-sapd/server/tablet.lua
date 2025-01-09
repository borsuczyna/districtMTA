addEvent('sapd:searchUser')
addEvent('sapd:getUserInfo')
addEvent('sapd:addUserLog')
addEvent('sapd:searchVehicle')
addEvent('sapd:getVehicleInfo')
addEvent('sapd:addVehicleLog')
addEvent('sapd:issueTicket')

function openTablet(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local faction = getElementData(vehicle, 'vehicle:faction')
    if faction ~= 'SAPD' then return end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then return end

    triggerClientEvent(player, 'tablet:open', player)
end

addEventHandler('onPlayerVehicleEnter', root, function(vehicle, seat, jacked)
    local faction = getElementData(vehicle, 'vehicle:faction')
    if faction ~= 'SAPD' then return end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(source, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then return end

    exports['m-notis']:addNotification(source, 'info', 'Komputer pokładowy', 'Naciśnij <kbd class="keycap keycap-sm">K</kbd> aby otworzyć komputer pokładowy.')
    bindKey(source, 'K', 'down', openTablet)
end)

local timeouts = {}

local function isPlayerTimedOut(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 1000 then
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

local function searchUserResult(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then return end

    if #result == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono użytkownika o podanym nicku.'})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', users = result, message = ('Znaleziono %d użytkowników.'):format(#result)})
end

addEventHandler('sapd:searchUser', root, function(hash, player, search)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    if #search < 1 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wyszukiwana fraza musi zawierać przynajmniej 2 znaki.'})
        return
    end

    dbQuery(searchUserResult, {hash, player}, connection, 'SELECT `uid`, `username`, `lastActive` FROM `m-users` WHERE `username` LIKE ?', '%' .. search .. '%')
end)

local function getUserLogsResult(query, hash, player, user)
    local result = dbPoll(query, 0)
    if not result then return end

    user.logs = result
    exports['m-ui']:respondToRequest(hash, {status = 'success', user = user, message = 'Pomyślnie pobrano informacje o użytkowniku.'})
end

local function getUserInfoResult(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then return end

    if #result == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono użytkownika o podanym identyfikatorze.'})
        return
    end

    local user = result[1]
    user.online = exports['m-core']:getPlayerByUid(user.uid) and true or false

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        SELECT `m-sapd-logs`.*, `m-users`.`username` AS `addedByUsername`
        FROM `m-sapd-logs`
        LEFT JOIN `m-users` ON `m-sapd-logs`.`addedBy` = `m-users`.`uid`
        WHERE `m-sapd-logs`.`key` = ?
        ORDER BY `m-sapd-logs`.`added`
    ]]

    dbQuery(getUserLogsResult, {hash, player, user}, connection, query, 'user-' .. user.uid)
end

addEventHandler('sapd:getUserInfo', root, function(hash, player, uid)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    dbQuery(getUserInfoResult, {hash, player}, connection, 'SELECT `uid`, `username`, `lastActive`, `licenses` FROM `m-users` WHERE `uid` = ?', uid)
end)

addEventHandler('sapd:addUserLog', root, function(hash, player, uid, log)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        INSERT INTO `m-sapd-logs` (`key`, `addedBy`, `info`)
        VALUES (?, ?, ?)
    ]]

    dbExec(connection, query, 'user-' .. uid, getElementData(player, 'player:uid'), log)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie dodano wpis do historii użytkownika.'})
end)

local function searchVehicleResult(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then return end

    if #result == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono pojazdu o podanym numerze rejestracyjnym.'})
        return
    end

    for i, vehicle in ipairs(result) do
        vehicle.modelName = exports['m-models']:getVehicleNameFromModel(vehicle.model)
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', vehicles = result, message = ('Znaleziono %d pojazdów.'):format(#result)})
end

addEventHandler('sapd:searchVehicle', root, function(hash, player, search)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    if #search < 1 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wyszukiwana fraza musi zawierać przynajmniej 2 znaki.'})
        return
    end

    dbQuery(searchVehicleResult, {hash, player}, connection, 'SELECT `uid`, `model`, `plate` FROM `m-vehicles` WHERE `plate` LIKE ?', '%' .. search .. '%')
end)

local function getVehicleLogsResult(query, hash, player, vehicle)
    local result = dbPoll(query, 0)
    if not result then return end

    vehicle.logs = result
    exports['m-ui']:respondToRequest(hash, {status = 'success', vehicle = vehicle, message = 'Pomyślnie pobrano informacje o pojeździe.'})
end

local function getVehicleInfoResult(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then return end

    if #result == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono pojazdu o podanym identyfikatorze.'})
        return
    end

    local vehicle = result[1]
    vehicle.modelName = exports['m-models']:getVehicleNameFromModel(vehicle.model)

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        SELECT `m-sapd-logs`.*, `m-users`.`username` AS `addedByUsername`
        FROM `m-sapd-logs`
        LEFT JOIN `m-users` ON `m-sapd-logs`.`addedBy` = `m-users`.`uid`
        WHERE `m-sapd-logs`.`key` = ?
        ORDER BY `m-sapd-logs`.`added`
    ]]

    dbQuery(getVehicleLogsResult, {hash, player, vehicle}, connection, query, 'vehicle-' .. vehicle.uid)
end

addEventHandler('sapd:getVehicleInfo', root, function(hash, player, id)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        SELECT `m-vehicles`.`uid`, `m-vehicles`.`owner`, `m-vehicles`.`model`, `m-vehicles`.`plate`, `m-users`.`username` AS `ownerName`
        FROM `m-vehicles`
        LEFT JOIN `m-users` ON `m-vehicles`.`owner` = `m-users`.`uid`
        WHERE `m-vehicles`.`uid` = ?
    ]]

    dbQuery(getVehicleInfoResult, {hash, player}, connection, query, id)
end)

addEventHandler('sapd:addVehicleLog', root, function(hash, player, uid, log)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        INSERT INTO `m-sapd-logs` (`key`, `addedBy`, `info`)
        VALUES (?, ?, ?)
    ]]

    dbExec(connection, query, 'vehicle-' .. uid, getElementData(player, 'player:uid'), log)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie dodano wpis do historii pojazdu.'})
end)

addEventHandler('sapd:issueTicket', root, function(hash, player, targetPlayer, amount, reason)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'tablet', 'manageFaction'})
    if not hasPermission then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz uprawnień do korzystania z tej funkcji.'})
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(targetPlayer)
    if not foundPlayer then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono gracza o podanej nazwie.'})
        return
    end

    if not getElementData(foundPlayer, 'player:uid') then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Gracz nie jest zalogowany.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local query = [[
        INSERT INTO `m-sapd-tickets` (`user`, `issuer`, `amount`, `reason`)
        VALUES (?, ?, ?, ?)
    ]]

    dbExec(connection, query, getElementData(foundPlayer, 'player:uid'), getElementData(player, 'player:uid'), amount, reason)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie wystawiono mandat.'})
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Mandat', ('Otrzymałeś mandat w wysokości $%d od %s z powodem: %s.'):format(amount, htmlEscape(getPlayerName(player)), htmlEscape(reason)))
    setPlayerWantedLevel(foundPlayer, math.min(getPlayerWantedLevel(foundPlayer) + 1, 6))
end)

function htmlEscape(s)
    return s:gsub('[<>&"]', function(c)
        return c == '<' and '&lt;' or c == '>' and '&gt;' or c == '&' and '&amp;' or '&quot;'
    end)
end