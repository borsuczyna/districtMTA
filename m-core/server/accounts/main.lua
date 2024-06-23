addEvent('onAccountResponse', true)

function sendAccountResponse(hash, response)
    triggerEvent('onAccountResponse', root, hash, response)
end

function encodePassword(password)
    return teaEncode(md5(password), 'm-core|' .. password .. '|hash')
end