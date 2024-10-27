if getPlayerSerial(localPlayer) ~= "358E4F7B5E59A23E09720E8486FB59A4" and getPlayerSerial(localPlayer) ~= "A5DA400F286807C1B887128888954ED2" then return end

local range = 150
local vehiclesInRange = {}

function onPlayerEnterHeli(heli)
    local playerVehicle = getPedOccupiedVehicle(localPlayer) -- Pobranie pojazdu gracza

    addEventHandler("onClientRender", root, function()
        local posX, posY, posZ = getElementPosition(heli)

        -- Sprawdzanie pojazdów w obrębie 150m
        vehiclesInRange = {}
        local vehicles = getElementsByType("vehicle")

        for _, vehicle in ipairs(vehicles) do
            -- Sprawdzenie, czy pojazd nie jest pojazdem gracza
            if vehicle ~= playerVehicle then
                local driver = getVehicleOccupant(vehicle) -- Pobranie kierowcy pojazdu
                if driver then -- Sprawdzanie, czy pojazd ma kierowcę
                    local vPosX, vPosY, vPosZ = getElementPosition(vehicle)
                    if getDistanceBetweenPoints3D(posX, posY, posZ, vPosX, vPosY, vPosZ) <= range then
                        table.insert(vehiclesInRange, vehicle)
                    end
                end
            end
        end

        -- Rysowanie linii i wyświetlanie nazw pojazdów
        for _, vehicle in ipairs(vehiclesInRange) do
            local vehicleName = getVehicleName(vehicle)
            local vPosX, vPosY, vPosZ = getElementPosition(vehicle)
            local driver = getVehicleOccupant(vehicle) -- Pobranie kierowcy pojazdu
            local driverName = driver and getPlayerName(driver) or "Brak kierowcy" -- Uzyskanie nazwy kierowcy

            -- Ustawienie końca linii nad pojazdem
            local lineEndZ = vPosZ + 6  -- Zmiana wysokości końca linii

            -- Przekształcanie pozycji 3D na 2D
            local screenXStart, screenYStart = getScreenFromWorldPosition(vPosX, vPosY, vPosZ)
            local screenXEnd, screenYEnd = getScreenFromWorldPosition(vPosX - 4, vPosY, lineEndZ)  -- Przesunięcie w prawo

            if screenXStart and screenYStart and screenXEnd and screenYEnd then
                -- Rysowanie linii z antialiasingiem
                dxDrawLine(screenXStart, screenYStart, screenXEnd, screenYEnd, tocolor(255, 255, 255, 200), 2)

                -- Rysowanie poziomej linii na końcu
                local lineLength = 40  -- Długość poziomej linii
                local horizontalLineOffset = 15  -- Przesunięcie poziomej linii w prawo

                -- Rysowanie poziomej linii z antialiasingiem
                dxDrawLine(screenXEnd - lineLength / 2 + horizontalLineOffset, screenYEnd, screenXEnd + lineLength / 2 + horizontalLineOffset, screenYEnd, tocolor(255, 255, 255, 180), 2)

                -- Wyświetlanie nazwy gracza nad nazwą pojazdu
                dxDrawText("Kierowca: " .. driverName, screenXEnd + horizontalLineOffset, screenYEnd - 45, screenXEnd + horizontalLineOffset, screenYEnd, tocolor(255, 255, 255, 200), 1, exports['m-ui']:getFont('Inter-Regular', 9), "center", "center")
                -- Wyświetlanie nazwy pojazdu poniżej nazwy gracza
                dxDrawText("Pojazd: " .. vehicleName, screenXEnd + horizontalLineOffset, screenYEnd - 20, screenXEnd + horizontalLineOffset, screenYEnd, tocolor(255, 255, 255, 200), 1, exports['m-ui']:getFont('Inter-Regular', 9), "center", "center")
            end
        end
    end)
end
addEventHandler("onClientVehicleEnter", root, onPlayerEnterHeli)

function onPlayerExitHeli(heli)
    removeEventHandler("onClientRender", root, function() end)
end
addEventHandler("onClientVehicleExit", root, onPlayerExitHeli)
