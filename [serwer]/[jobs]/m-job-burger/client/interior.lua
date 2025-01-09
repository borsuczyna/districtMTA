function updateCamera()
    if not isElement(interiorObject) then return end

    local x, y, z = getPositionFromElementOffset(interiorObject, unpack(settings.camera))
    local lx, ly, lz = getPositionFromElementOffset(interiorObject, unpack(settings.cameraLookAt))

    setCameraMatrix(x, y, z, lx, ly, lz, 0, settings.cameraFov)
end

function setBurgerInteriorVisible(state)
    local removeFunction = state and removeWorldModel or restoreWorldModel

    for i, object in ipairs(settings.removeObjects) do
        removeFunction(object[1], object[2], object[3], object[4], object[5])
    end

    if state then
        interiorObject = createObject(1337, unpack(settings.interior))
        setElementDimension(interiorObject, getElementDimension(localPlayer))
        setElementData(interiorObject, 'element:model', 'burger-interior')
        
        updateCamera()
        loadFryers(interiorObject)
        createColaObject(interiorObject)
        toggleMovement(true)
        
        addEventHandler('onClientRender', root, updateMovement, true, 'high+999')
        addEventHandler('onClientRender', root, updateGrillsCook, true, 'high+999')
        addEventHandler('onClientClick', root, goToPositionClick)
        addEventHandler('onClientClick', root, clickPed)
        addEventHandler('onClientClick', root, onClickObjectInteraction, true, 'low')
        showCursor(true, false)
    else
        clearBoards()
        clearGrills()
        clearFryers()
        destroyColaObject()
        
        if isElement(interiorObject) then
            destroyElement(interiorObject)
        end

        setCameraTarget(localPlayer)
        setElementPosition(localPlayer, unpack(settings.interiorExit))
        setElementRotation(localPlayer, 0, 0, 180)
        showCursor(false)

        removeEventHandler('onClientRender', root, updateMovement)
        removeEventHandler('onClientRender', root, updateGrillsCook)
        removeEventHandler('onClientClick', root, goToPositionClick)
        removeEventHandler('onClientClick', root, clickPed)
        removeEventHandler('onClientClick', root, onClickObjectInteraction)
    end
end

function showInteriorLoading(visible)
    exports['m-loading']:setLoadingVisible(true, visible and 'Ładowanie interioru...' or 'Ładowanie...', 1000)
    setTimer(setBurgerInteriorVisible, 600, 1, visible)
end