addEvent("vehicle:sirens:start", true)
addEventHandler("vehicle:sirens:start", root, function(siren)
    triggerClientEvent(root, "vehicle:sirens:start", source, siren)
end)

addEvent("vehicle:sirens:stop", true)
addEventHandler("vehicle:sirens:stop", root, function(siren)
    triggerClientEvent(root, "vehicle:sirens:stop", source, siren)
end)

addEvent("vehicle:horn:start", true)
addEventHandler("vehicle:horn:start", root, function(horn)
    triggerClientEvent(root, "vehicle:horn:start", source, horn)
end)

addEvent("vehicle:horn:stop", true)
addEventHandler("vehicle:horn:stop", root, function()
    triggerClientEvent(root, "vehicle:horn:stop", source)
end)

addEvent("vehicle:siren-pause:start", true)
addEventHandler("vehicle:siren-pause:start", root, function()
    triggerClientEvent(root, "vehicle:siren-pause:start", source)
end)

addEvent("vehicle:siren-pause:stop", true)
addEventHandler("vehicle:siren-pause:stop", root, function()
    triggerClientEvent(root, "vehicle:siren-pause:stop", source)
end)