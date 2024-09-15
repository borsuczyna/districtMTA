local playingVoiceLines = {}

local function updatePedVoice(ped, fft)
    local openMouthValue = math.sqrt(fft[15]) * 256
    local boneId = 8
    local x, y, z = getElementBonePosition(ped, boneId)
    if not x or not y or not z then return end
    
    -- setElementBonePosition(ped, boneId, x, y, tonumber(z - openMouthValue / 3000))
    local rx, ry, rz = getElementBoneRotation(ped, boneId)
    setElementBoneRotation(ped, boneId, rx, ry + openMouthValue * 4, rz)
    updateElementRpHAnim(ped)
end

function renderVoiceLines()
    if #playingVoiceLines == 0 then
        removeEventHandler('onClientPedsProcessed', root, renderVoiceLines)
        return
    end

    for i, line in ipairs(playingVoiceLines) do
        if not isElement(line.ped) or not isElement(line.sound) then
            table.remove(playingVoiceLines, i)
            return
        end

        local fft = getSoundFFTData(line.sound, 2048, 256)
        if fft then
            updatePedVoice(line.ped, fft)
        end
    end
end

function pedTellVoiceLine(ped, line, text)
    local path = ('data/voice/%s.wav'):format(line)
    if not fileExists(path) then
        outputConsole(('[missions:voice] File not found: %s'):format(path))
        return
    end

    local sound = playSound(path)
    attachElements(sound, ped)
    setElementDimension(sound, getElementDimension(ped))

    table.insert(playingVoiceLines, {
        ped = ped,
        sound = sound,
        path = path
    })

    if not isEventHandlerAdded('onClientPedsProcessed', root, renderVoiceLines) then
        addEventHandler('onClientPedsProcessed', root, renderVoiceLines)
    end
end

local testPed = createPed(0, 2090.305, -1276.982, 31.62, 180)
setElementFrozen(testPed, true)
setElementDimension(testPed, getElementDimension(localPlayer))
pedTellVoiceLine(testPed, 'oblakany')
exports['m-anim']:setPedAnimation(testPed, 'gada', true)


exports['m-anim']:setPedAnimation(localPlayer, 'sluchawka', true)
pedTellVoiceLine(localPlayer, 'oblakany')
-- local testPed = createPed(134, 2090.499, -1274.967, 32.424, 180)
-- setElementFrozen(testPed, true)
-- setElementDimension(testPed, getElementDimension(localPlayer))
-- exports['m-anim']:setPedAnimation(testPed, 'strzela', true)
-- givePedWeapon(testPed, 24, 1000, true)

-- bindKey('z', 'down', function()
--     setPedControlState(testPed, 'fire', true)
--     setTimer(function()
--         setPedControlState(testPed, 'fire', false)
--     end, 100, 1)
-- end)

-- setCameraMatrix(2090.159, -1276.19, 33.024, 2092.159, -1270.619, 33.78, 0, 100)