-- function startResources()
--     local resources = getResources()

--     for _, resource in ipairs(resources) do
--         local resourceName = getResourceName(resource)
--         if resourceName then
--             if string.find(resourceName, '^m%-') then
--                 startResource(resource)
--             end
--         end
--     end
-- end

function startResources()
    local resources = getResources()

    for _, resource in ipairs(resources) do
        local organizationalPath = getResourceOrganizationalPath(resource)
        if organizationalPath == '[serwer]' then
            startResource(resource)
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, startResources)