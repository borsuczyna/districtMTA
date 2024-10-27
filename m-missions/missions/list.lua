addEvent('missions:updateMission', true)

missionList = {
    [1] = {'prolog', 'Prolog', 'Tu wszystko się zaczęło...', '1.png?2'},
    [2] = {'package', 'Przechwyt', 'Przechwycenie dziwnej paczki', '2.png'},
    [3] = {'long-road', 'Długa droga', 'Długa droga do Los Santos i podkładanie podsłuchu', '3.png'},
    [4] = {'investigation', 'Dochodzenie', 'Musimy się dowiedzieć prawdy', '4.png'},
}

function getMissionList()
    return missionList
end

function getMissionIndex(mission)
    for i, v in pairs(missionList) do
        if v[1] == mission then
            return i
        end
    end
end

function getMissionDataByName(mission)
    return missionList[getMissionIndex(mission)]
end

function getMissionByIndex(index)
    return missionList[index]
end

function getPlayerMission(player)
    player = player or localPlayer
    return getElementData(player, 'player:mission')
end

function setPlayerMission(player, mission)
    mission = mission or ((getPlayerMission(player) or 1) + 1)
    setElementData(player, 'player:mission', mission)

    triggerClientEvent(player, 'missions:updateMission', resourceRoot, mission)
end

addEventHandler('missions:updateMission', resourceRoot, function(mission)
    local mission = missionList[mission]
    if not mission then
        exports['m-notis']:addNotification('info', 'Misje', 'Aktualnie wykonałeś wszystkie misje, ciągle pracujemy nad nowymi - wróć później!')
        return
    end

    startMission(mission[1])
end)