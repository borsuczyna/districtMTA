local function generateDiscordConnectionCode()
    local code = ''
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for i = 1, 8 do
        local charPos = math.random(1, #chars)
        code = code .. string.sub(chars, charPos, charPos)
    end
    return code
end

local function createAccountResult(queryResult, hash)
    local result = dbPoll(queryResult, 0)
    if result then
        sendAccountResponse(hash, {'register', true, 'Konto zostało utworzone'})
    else
        sendAccountResponse(hash, {'register', false, 'Wystąpił błąd podczas tworzenia konta, spróbuj ponownie'})
    end
end

local function checkAccountExistsResult(queryResult, hash, data)
    local result = dbPoll(queryResult, 0)
    
    if #result > 0 then
        local sameSerial = 0
        for i, row in ipairs(result) do
            if row.serial == data.serial then
                sameSerial = sameSerial + 1
            end
            if row.username == data.username then
                sendAccountResponse(hash, {'register', false, 'Login jest już zajęty'})
                return
            end
            if row.email == data.email then
                sendAccountResponse(hash, {'register', false, 'Email jest już zajęty'})
                return
            end
        end

        if sameSerial >= 3 then
            sendAccountResponse(hash, {'register', false, 'Osiągnięto limit kont'})
            return
        end
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        sendAccountResponse(hash, {'register', false, 'Brak połączenia z bazą danych'})
        return
    end

    dbQuery(createAccountResult, {hash}, connection,
    'INSERT INTO `m-users` (username, password, email, ip, serial, detectedDiscordID, discordCode) VALUES (?, ?, ?, ?, ?, ?, ?)',
    data.username, data.password, data.email, data.ip, data.serial, data.detectedDiscordID, generateDiscordConnectionCode())
end

local function createAccountInternal(data, hash)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        sendAccountResponse(hash, {'register', false, 'Brak połączenia z bazą danych'})
        return
    end

    dbQuery(checkAccountExistsResult, {hash, data}, connection, 'SELECT * FROM `m-users` WHERE username = ? OR email = ? OR serial = ? OR detectedDiscordID = ?', data.username, data.email, data.serial, data.detectedDiscordID)
end

function createAccount(hash, data)
    assert(type(data) == 'table', 'createAccount: data is not a table')
    assert(type(data.username) == 'string', 'createAccount: data.username is not a string')
    assert(type(data.password) == 'string', 'createAccount: data.password is not a string')
    assert(type(data.email) == 'string', 'createAccount: data.email is not a string')
    assert(type(data.ip) == 'string', 'createAccount: data.ip is not a string')
    assert(type(data.serial) == 'string', 'createAccount: data.serial is not a string')

    if #data.username < 3 then return 'Login jest za krótki' end
    if #data.username > 18 then return 'Login jest za długi' end
    if string.match(data.username, '[ąćęłńóśźż]') then return 'Login nie może zawierać polskich znaków' end
    if string.match(data.username, '[^%w_]') then return 'Login może zawierać tylko litery, cyfry i znak _' end
    if string.match(data.username, '%s') then return 'Login nie może zawierać spacji' end
    if #data.password < 3 then return 'Hasło jest za krótkie' end
    if #data.password > 18 then return 'Hasło jest za długie' end
    if #data.email < 3 then return 'Email jest za krótki' end
    if #data.email > 50 then return 'Email jest za długi' end

    data.password = encodePassword(data.password)
    createAccountInternal(data, hash)
end

-- TEST - create account
-- addEventHandler('onResourceStart', resourceRoot, function()
--     addEvent('onAccountResponse', true)
--     addEventHandler('onAccountResponse', root, function(hash, response)
--         outputChatBox('Response for hash ' .. hash .. ': ' .. inspect(response))
--     end)

--     local hash = createAccount({
--         username = 'testezz',
--         password = 'test',
--         email = 'testezz@gmail.com',
--         ip = '127.0.0.1',
--         serial = '1234567890'
--     })
-- end)