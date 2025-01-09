local messageTime = 8000
local messageDrawDistance = 25
local messageFadeDistance = messageDrawDistance * 0.75
local messageBaseAlpha = 170
local messageLimit = 4

local chatBubbles = {}

function renderChatBubbles()
    if getElementData(localPlayer, 'player:hiddenNametags') then return end

    for player, bubbleData in pairs(chatBubbles) do
        if isElement(player) then
            local boneX, boneY, boneZ = getPedBonePosition(player, 3)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ)

            if screenX and screenY then
                if getTickCount() > bubbleData.time + messageTime then
                    if utf8.find(bubbleData.text, '\n') then
                        bubbleData.time = getTickCount()
                        bubbleData.text = utf8.sub(bubbleData.text, utf8.find(bubbleData.text, '\n') + 1)
                        bubbleData.messages = bubbleData.messages - 1
                    else
                        chatBubbles[player] = nil
                    end
                end

                local camX, camY, camZ = getCameraMatrix()
                local distance = getDistanceBetweenPoints3D(camX, camY, camZ, boneX, boneY, boneZ)
                local alpha = math.max(0, math.min(messageBaseAlpha - (messageBaseAlpha * ((distance - messageFadeDistance) / (messageDrawDistance - messageFadeDistance))), messageBaseAlpha))
                local scale = math.max(0.7, 1 - distance * 0.02)

                dxDrawText(bubbleData.text:gsub('#%x%x%x%x%x%x', ''), screenX + 1, screenY + 1, screenX + 1, screenY + 1, tocolor(0, 0, 0, alpha), scale, exports['m-ui']:getFont('Inter-Bold', 10), 'center', 'center', false, false, false, false, true)
                dxDrawText(bubbleData.text, screenX, screenY, screenX, screenY, tocolor(255, 255, 255, alpha), scale, exports['m-ui']:getFont('Inter-Bold', 10), 'center', 'center', false, false, false, false, true)
            end
        end
    end
end

addEventHandler('onClientRender', root, renderChatBubbles, true, 'high+999')

addEvent('chat:addBubble', true)
addEventHandler('chat:addBubble', root, function(message)
    local player = source

    if player ~= localPlayer then     
        if not chatBubbles[player] then
            chatBubbles[player] = {
                text = message,
                time = getTickCount(),
                messages = 1
            }
        else
            chatBubbles[player].text = chatBubbles[player].text .. '\n' .. message
            chatBubbles[player].messages = chatBubbles[player].messages + 1

            if chatBubbles[player].messages > messageLimit and utf8.find(chatBubbles[player].text, '\n') then
                chatBubbles[player].text = utf8.sub(chatBubbles[player].text, utf8.find(chatBubbles[player].text, '\n') + 1)
                chatBubbles[player].messages = chatBubbles[player].messages - 1
            end
        end
    end
end)

addEventHandler('onClientPlayerQuit', root, function()
    local player = source

    if chatBubbles[player] then
        chatBubbles[player] = nil
    end
end)