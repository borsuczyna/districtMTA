function setElementGhostMode(element, state)
    if state then
        setElementData(element, 'element:ghostmode', true)
    else
        removeElementData(element, 'element:ghostmode')
    end
end