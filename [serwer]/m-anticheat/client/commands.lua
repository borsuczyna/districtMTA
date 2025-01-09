-- local allowedCommands = {
--     {'Admin', 'm-admins'},
--     {'aeditor', 'm-anim'},
--     {'logs', 'm-admins'},
--     {'reports', 'm-admins'},
--     {'gp', 'm-core'},
--     {'colsshow', 'm-jobs'},
--     {'browserdebug', 'm-ui'},
--     {'mobileview', 'm-ui'},
--     {'stat', 'rescpu'},
--     {'trade', 'm-inventory'},
--     {'createhouse', 'm-house-create'},
--     {'record', 'm-record'},
--     {'play', 'm-record'},
--     {'kuppojazd', 'm-carexchange'},
--     {'zakuj', 'm-faction-sapd'},
--     {'odkuj', 'm-faction-sapd'},
-- }

-- function checkCommandHandlers()
--     for _, subtable in pairs(getCommandHandlers()) do
--         local resourceName = getResourceName(subtable[2])
--         local found = false

--         for _, allowed in pairs(allowedCommands) do
--             if allowed[1] == subtable[1] and allowed[2] == resourceName then
--                 found = true
--                 break
--             end
--         end

--         if not found then
--             removeCommandHandler(subtable[1], subtable[2])

--             setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**, **%s**)'):format(subtable[1], resourceName), 'district')) 
--             setElementData(localPlayer, 'player:gameTime', 9)

--             crashPlayer()
--         end
--     end
-- end

-- setTimer(checkCommandHandlers, 5000, 0)