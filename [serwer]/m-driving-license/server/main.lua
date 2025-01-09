addEvent('drivingLicense:start')
addEvent('drivingLicense:finish')

local playersThatPaid = {}
local licenseCosts = {
    A = 1000,
    B = 100,
    C = 2000,
    L1 = 5000,
}

addEventHandler('drivingLicense:start', root, function(hash, player, category)
    if not licenseCosts[category] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa kategoria prawa jazdy.'})
        return
    end

    if exports['m-core']:doesPlayerHaveLicense(player, category) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Posiadasz już prawo jazdy kategorii ' .. category .. '.'})
        return
    end

    if getPlayerMoney(player) < licenseCosts[category] * 100 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczającej ilości gotówki.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'license', 'Egzamin na prawo jazdy kategorii ' .. category, -licenseCosts[category] * 100)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Rozpoczęto egzamin na prawo jazdy kategorii ' .. category .. '.'})
    playersThatPaid[player] = category
end)

addEventHandler('drivingLicense:finish', root, function(hash, player, passed)
    if not playersThatPaid[player] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz aktywnego egzaminu na prawo jazdy.'})
        return
    end

    local category = playersThatPaid[player]
    playersThatPaid[player] = nil

    if not passed then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie zdałeś egzaminu na prawo jazdy kategorii ' .. category .. '.'})
        return
    end

    startExam(player, category)
end)