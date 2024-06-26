function loginResult(queryResult, hash, data)
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
end

function loginInternal(data, hash)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        sendAccountResponse(hash, {'login', false, 'Brak połączenia z bazą danych'})
        return
    end

    dbQuery(loginResult, {hash, data}, connection, 'SELECT * FROM `m-users` WHERE username = ? OR email = ?', data.usernameOrEmail, data.usernameOrEmail)
end

function loginToAccount(data)
    assert(type(data) == 'table', 'createAccount: data is not a table')
    assert(type(data.usernameOrEmail) == 'string', 'createAccount: data.usernameOrEmail is not a string')
    assert(type(data.password) == 'string', 'createAccount: data.password is not a string')

    if #data.usernameOrEmail < 3 then return false, 'Nieprawidłowa nazwa użytkownika lub email' end
    if #data.usernameOrEmail > 18 then return false, 'Nieprawidłowa nazwa użytkownika lub email' end
    if #data.password < 3 then return false, 'Nieprawidłowe hasło' end
    if #data.password > 18 then return false, 'Nieprawidłowe hasło' end

    data.password = encodePassword(data.password)
    local hash = createHash()
    loginInternal(data, hash)

    return hash
end

-- TEST - login
-- addEventHandler('onResourceStart', resourceRoot, function()
--     addEvent('onAccountResponse', true)
--     addEventHandler('onAccountResponse', root, function(hash, response)
--         outputChatBox('Response for hash ' .. hash .. ': ' .. inspect(response))
--     end)

--     local hash = loginToAccount({usernameOrEmail = 'testezz', password = 'test'})
-- end)