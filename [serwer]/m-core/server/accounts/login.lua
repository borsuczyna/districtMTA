local function loginResult(queryResult, hash, data, player)
    local result = dbPoll(queryResult, 0)
    if not result then
        sendAccountResponse(hash, {'login', false, 'Błąd podczas logowania'})
        return
    end

    if #result ~= 1 then
        sendAccountResponse(hash, {'login', false, 'Konto nie istnieje'})
        return
    end

    local accountData = result[1]
    if data.password ~= accountData.password then
        sendAccountResponse(hash, {'login', false, 'Nieprawidłowe dane logowania'})
        return
    end

    if getPlayerByUid(accountData.uid) then
        sendAccountResponse(hash, {'login', false, 'Konto jest już zalogowane'})
        return
    end

    sendAccountResponse(hash, {'login', true, 'Zalogowano pomyślnie', accountData})
    exports['m-core']:addUserLog(player, 'ACCOUNT', 'Zalogowano na konto', ('Serial: ||%s||\nIP: ||%s||'):format(getPlayerSerial(player), getPlayerIP(player)))
end

local function loginInternal(data, hash, player)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        sendAccountResponse(hash, {'login', false, 'Brak połączenia z bazą danych'})
        return
    end

    dbQuery(loginResult, {hash, data, player}, connection, 'SELECT *, UNIX_TIMESTAMP(`premiumDate`) AS `premiumEnd`, UNIX_TIMESTAMP(`lastActive`) AS `lastActiveUnix`, UNIX_TIMESTAMP(`dailyRewardRedeem`) AS `dailyRewardRedeemDate` FROM `m-users` WHERE username = ? OR email = ?', data.usernameOrEmail, data.usernameOrEmail)
end

function loginToAccount(hash, data, player)
    assert(type(data) == 'table', 'createAccount: data is not a table')
    assert(type(data.usernameOrEmail) == 'string', 'createAccount: data.usernameOrEmail is not a string')
    assert(type(data.password) == 'string', 'createAccount: data.password is not a string')

    if #data.usernameOrEmail < 3 then return 'Nieprawidłowy login lub email' end
    if #data.usernameOrEmail > 18 then return 'Nieprawidłowy login lub email' end
    if #data.password < 3 then return 'Nieprawidłowe hasło' end
    if #data.password > 18 then return 'Nieprawidłowe hasło' end

    data.password = encodePassword(data.password)
    loginInternal(data, hash, player)
end

-- TEST - login
-- addEventHandler('onResourceStart', resourceRoot, function()
--     addEvent('onAccountResponse', true)
--     addEventHandler('onAccountResponse', root, function(hash, response)
--         outputChatBox('Response for hash ' .. hash .. ': ' .. inspect(response))
--     end)

--     local hash = loginToAccount({usernameOrEmail = 'testezz', password = 'test'})
-- end)