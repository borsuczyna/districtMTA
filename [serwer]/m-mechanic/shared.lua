local settings = {
    -- $1 - 100
    enginePrice = 200,
    doorPrice = 5000,
    panelPrice = 3000,
    lightPrice = 2000,
    wheelPrice = 4000,
}

function getAngleCosSin(angle)
    local angle = math.rad(angle)
    return {math.sin(angle), math.cos(angle)}
end

repairPositions = {
    {
        marker = {2063.229, -1821.451, 13.547},
        colShape = {2059.908, -1827.820, 13.617},
        rot = 0,
        render = {2060.256, -1821.3, 16.347, getAngleCosSin(0)},
        gate = {2059.929, -1822.516, 14.177},
    },
    {
        marker = {2063.229 + 6.57, -1821.451, 13.547},
        colShape = {2059.908 + 6.57, -1827.820, 13.617},
        rot = 0,
        render = {2060.256 + 6.4, -1821.3, 16.347, getAngleCosSin(0)},
        gate = {2059.929 + 6.57, -1822.516, 14.177},
    },
    {
        marker = {2063.229 - 6.57, -1821.451, 13.547},
        colShape = {2059.908 - 6.57, -1827.820, 13.617},
        rot = 0,
        render = {2060.256 - 6.57, -1821.3, 16.347, getAngleCosSin(0)},
        gate = {2059.929 - 6.57, -1822.516, 14.177},
    },
}

repairBlips = {
    {2059.331, -1828.631, 13.547},
}

local function createDoorRepairData(name, index)
    return {
        name = name,
        price = function(vehicle)
            return ((getVehicleDoorState(vehicle, index) == 4) and 2 or 1) * settings.doorPrice
        end,
        check = function(vehicle)
            return getVehicleDoorState(vehicle, index) >= 2
        end,
        time = function(vehicle)
            return 7
        end,
        repair = function(vehicle)
            setVehicleDoorState(vehicle, index, 0)
        end,
    }
end

local function createPanelRepairData(name, index)
    return {
        name = name,
        price = function(vehicle)
            return getVehiclePanelState(vehicle, index) * settings.panelPrice
        end,
        check = function(vehicle)
            return getVehiclePanelState(vehicle, index) >= 1
        end,
        time = function(vehicle)
            return 7
        end,
        repair = function(vehicle)
            setVehiclePanelState(vehicle, index, 0)
        end,
    }
end

local function createLightRepairData(name, index)
    return {
        name = name,
        price = function(vehicle)
            return settings.lightPrice
        end,
        check = function(vehicle)
            return getVehicleLightState(vehicle, index) >= 2
        end,
        time = function(vehicle)
            return 7
        end,
        repair = function(vehicle)
            setVehicleLightState(vehicle, index, 0)
        end,
    }
end

local function createWheelRepairData(name, index)
    return {
        name = name,
        price = function(vehicle)
            local state = ({getVehicleWheelStates(vehicle)})[index + 1]
            return ((state == 3 or state == 4) and 4 or 1) * settings.wheelPrice
        end,
        check = function(vehicle)
            return ({getVehicleWheelStates(vehicle)})[index + 1] >= 1
        end,
        time = function(vehicle)
            return 7
        end,
        repair = function(vehicle)
            local states = ({getVehicleWheelStates(vehicle)})
            states[index + 1] = 0
            setVehicleWheelStates(vehicle, unpack(states))
        end,
    }
end

mechanicData = {
    {
        name = 'Silnik',
        price = function(vehicle)
            local health = getElementHealth(vehicle)
            return math.floor((1000 - health) / 10) * settings.enginePrice
        end,
        check = function(vehicle)
            return getElementHealth(vehicle) < 1000
        end,
        time = function(vehicle)
            local health = getElementHealth(vehicle)
            return math.floor((1000 - health) / 60)
        end,
        repair = function(vehicle)
            setElementHealth(vehicle, 1000)
        end,
    },
    -- doors
    createDoorRepairData('Lewe przednie drzwi', 2),
    createDoorRepairData('Prawe przednie drzwi', 3),
    createDoorRepairData('Lewe tylne drzwi', 4),
    createDoorRepairData('Prawe tylne drzwi', 5),
    createDoorRepairData('Klapa bagażnika', 1),
    createDoorRepairData('Maska', 0),
    -- panels
    createPanelRepairData('Lewy przedni błotnik', 0),
    createPanelRepairData('Prawy przedni błotnik', 1),
    createPanelRepairData('Lewy tylny błotnik', 2),
    createPanelRepairData('Prawy tylny błotnik', 3),
    createPanelRepairData('Szyba', 4),
    createPanelRepairData('Przedni zderzak', 5),
    createPanelRepairData('Tylny zderzak', 6),
    -- lights
    createLightRepairData('Lewe przednie światło', 0),
    createLightRepairData('Prawe przednie światło', 1),
    createLightRepairData('Lewe tylne światło', 2),
    createLightRepairData('Prawe tylne światło', 3),
    -- wheels
    createWheelRepairData('Lewe przednie koło', 0),
    createWheelRepairData('Prawe przednie koło', 1),
    createWheelRepairData('Lewe tylne koło', 2),
    createWheelRepairData('Prawe tylne koło', 3),
}

function getRepairsByNames(repairs)
    local result = {}
    for i, data in ipairs(mechanicData) do
        for j, repair in ipairs(repairs) do
            if repair == data.name then
                table.insert(result, data)
            end
        end
    end
    return result
end

function getVehiclePossibleRepairs(vehicle)
    local repairs = {}
    for i, data in ipairs(mechanicData) do
        if data.check(vehicle) then
            table.insert(repairs, {
                name = data.name,
                price = data.price(vehicle),
                time = data.time(vehicle),
            })
        end
    end
    return repairs
end