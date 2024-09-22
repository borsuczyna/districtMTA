local destroyOnRestartElements = {}

function addDestroyOnRestartElement(element, resource)
    local resourceName = getResourceName(resource)
    if not destroyOnRestartElements[resourceName] then
        destroyOnRestartElements[resourceName] = {}
    end

    table.insert(destroyOnRestartElements[resourceName], element)
end

addEventHandler('onResourceStop', root, function(resource)
    local resourceName = getResourceName(resource)

    if destroyOnRestartElements[resourceName] then
        for _, element in ipairs(destroyOnRestartElements[resourceName]) do
            if isElement(element) then
                destroyElement(element)
            end
        end
    end
end)