addEvent('payment:onPaymentCreated')
addEvent('payment:onPaymentFinished')

local items = {
    seasonPass = 'price_1Q2xLQGHfWrlrYnpY651jLRt',
}

function handlePaymentCreatedMessage(data)
    triggerEvent('payment:onPaymentCreated', root, data.uid, data.item, data.url)
end

function handlePaymentFinishedMessage(data)
    data.uid = tonumber(data.uid)
    local player = exports['m-core']:getPlayerByUid(data.uid)

    iprint(data)
    iprint(player)
    triggerEvent('payment:onPaymentFinished', root, data.uid, player, data.itemId)
end

function createPayment(player, item)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    sendSocketMessage('createPayment', {uid = uid, item = item, itemId = items[item]})
end