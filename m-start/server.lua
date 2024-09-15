function startResources()
    local resources = getResources()
    local thisName = getResourceName(getThisResource())

    for _, resource in ipairs(resources) do
        local resourceName = getResourceName(resource)

        if resourceName and resourceName ~= 'm-boilerplate' then
            if string.find(resourceName, '^m%-') and resourceName ~= thisName then
                if getResourceState(resource) == 'running' then
                    restartResource(resource)
                else
                    startResource(resource)
                end
            end
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, startResources)