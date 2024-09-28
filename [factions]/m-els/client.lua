addEventHandler("onClientPreRender", root, function()
    for k,v in pairs(getElementsByType("vehicle", root, true)) do
        --if v == getPedOccupiedVehicle(localPlayer) then 
            drawVisualLights(v)
        --end
    end

    drawCoronas()
end)