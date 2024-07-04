function startResources()
    local resources = getResources()

    for _, resource in ipairs(resources) do
        local resourceName = getResourceName(resource)
        if resourceName then
            if string.find(resourceName, '^m%-') then
                startResource(resource)
            end
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, startResources)