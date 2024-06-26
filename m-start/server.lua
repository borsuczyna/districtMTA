local resourceNames = {
    'm-models',
    'm-logs',
    'm-updates',
    'm-mysql',
    'm-core',
    'm-ui',
    'm-loading',
    'm-blur',
    'm-maps',
    'm-notis',
    'm-login',
    'm-hud',
}

function startResourcesInOrder()
    for i, resourceName in ipairs(resourceNames) do
        local resource = getResourceFromName(resourceName)
        if resource then
            startResource(resource)
        else
            outputDebugString('Failed to start resource: '..resourceName)
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, startResourcesInOrder)