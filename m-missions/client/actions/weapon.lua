addEvent('missions:receiveWeaponGiven', true)

defineMissionAction({
    name = 'giveWeapon',
    editorName = 'Daj broń',
    arguments = {
        String('Ped', ''),
        Number('Index'),
    },
    callback = function(ped, index)
        triggerServerEvent('missions:requestServerSideWeapon', resourceRoot, getCurrentMission(), ped, index)
        await(waitForWeaponGive(index))
    end,
})

function waitForWeaponGive(index)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:receiveWeaponGiven', resourceRoot, function(mission, weaponIndex)
            if weaponIndex == index then
                resolve()
            end
        end)
    end)
end