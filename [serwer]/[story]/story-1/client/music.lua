local music, musicStartTime, musicTargetVolume;

function fadeInMusic()
    local progress = (getTickCount() - musicStartTime) / 9000
    setSoundVolume(music, (progress * 0.1) * musicTargetVolume)

    if progress >= 1 then
        removeEventHandler('onClientRender', root, fadeInMusic)
    end
end

function playMusic(path, volume)
    if music then
        stopSound(music)
        music = nil
    end

    music = playSound(path and 'data/sounds/'..path..'.mp3' or 'data/sounds/music.mp3', false)
    setSoundVolume(music, 0)
    musicTargetVolume = volume or 1
    musicStartTime = getTickCount()
    addEventHandler('onClientRender', root, fadeInMusic)
end