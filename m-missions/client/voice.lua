local playingVoiceLines = {}
local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1

local function updatePedVoice(ped, fft)
    local openMouthValue = math.sqrt(fft[15]) * 256
    local boneId = 8
    local x, y, z = getElementBonePosition(ped, boneId)
    if not x or not y or not z then return end
    
    local rx, ry, rz = getElementBoneRotation(ped, boneId)
    setElementBoneRotation(ped, boneId, rx, ry + openMouthValue / 4, rz)
    updateElementRpHAnim(ped)
end

function renderVoiceLines()
    if #playingVoiceLines == 0 then
        removeEventHandler('onClientPedsProcessed', root, renderVoiceLines)
        return
    end

    local zoom = zoomOriginal * ( 25 / interfaceSize )
    local y = sy - 25/zoom

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
        text = text,
        path = path
    })

    if not isEventHandlerAdded('onClientPedsProcessed', root, renderVoiceLines) then
        addEventHandler('onClientPedsProcessed', root, renderVoiceLines)
    end
end

pedTellVoiceLine(localPlayer, 'oblakany', 'Dzień dobry tutaj obłąkany człowiek prosze pani')