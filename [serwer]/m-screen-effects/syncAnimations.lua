-- SERVER SYNC VIA CLIENT

-- drunkAnimation

applyPlayerDrunkAnimation = function(player, animationBlock, animationName, aEndTime)
    if isElement(player) then
        if (type(animationBlock) ~= 'string' or type(animationName) ~= 'string' or type(aEndTime) ~= 'number') then
            return
        end;

        setPedAnimation(player, animationBlock, animationName, 0, true, true, false, true)
    end;
end;

deletePlayerDrunkAnimation = function(player)
    if isElement(player) then
        setPedAnimation(player, 'PED', 'walk_drunk', 0, true, true, false, false)
    end;
end;


addEvent('onServerApplyDrunkAnimation', true)
addEventHandler('onServerApplyDrunkAnimation', root,
    function(animationBlock, animationTime, aEndTime)
        applyPlayerDrunkAnimation(client, animationBlock, animationTime, aEndTime)
    end
);

addEvent('onServerDeleteDrunkAnimation', true)
addEventHandler('onServerDeleteDrunkAnimation', root,
    function()
        deletePlayerDrunkAnimation(client)
    end
);
