function renderCableCar(position, cableCar)
    local start = cableCar.start
    local finish = cableCar.finish
    local middle = (start + finish) / 2

    local distance = getDistanceBetweenPoints3D(position, middle)
    if distance > cableCar.drawDistance then return end

    dxDrawLine3D(start, finish, tocolor(0, 0, 0), 2)
end

function renderCableCars()
    local position = Vector3(getCameraMatrix())
    for i, cableCar in ipairs(cableCars) do
        renderCableCar(position, cableCar)
    end
end

addEventHandler('onClientRender', root, renderCableCars)