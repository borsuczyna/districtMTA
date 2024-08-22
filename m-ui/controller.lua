addEvent('controller:buttonPressed', true)
addEvent('controller:buttonReleased', true)

local lastAxes = {
    al = {x = 0, y = 0},
    ar = {x = 0, y = 0}
}
local lastButtons = {}

local controller = {
    axes = {
        al = {x = 0, y = 0},
        ar = {x = 0, y = 0}
    },
    buttons = {}
}

function updateController(leftAxis, rightAxis, buttons)
    controller.axes.al.x = leftAxis.x
    controller.axes.al.y = leftAxis.y
    controller.axes.ar.x = rightAxis.x
    controller.axes.ar.y = rightAxis.y

    for i, button in ipairs(buttons) do
        controller.buttons[i] = button

        if button == 1 and lastButtons[i] == 0 then
            triggerEvent('controller:buttonPressed', root, i)
        elseif button == 0 and lastButtons[i] == 1 then
            triggerEvent('controller:buttonReleased', root, i)
        end
    end

    lastAxes.al.x = leftAxis.x
    lastAxes.al.y = leftAxis.y
    lastAxes.ar.x = rightAxis.x
    lastAxes.ar.y = rightAxis.y

    for i, button in ipairs(buttons) do
        lastButtons[i] = button
    end

    updateMovement()
end

function isControllerButtonDown(button)
    return controller.buttons[button] >= 0.5
end

function getControllerButton(button)
    return controller.buttons[button] or 0
end

function updateMovement()
    if isCursorShowing() then return end

    local inVehicle = getPedOccupiedVehicle(localPlayer)

    if inVehicle then
        setAnalogControlState('accelerate', getControllerButton(8))
        setAnalogControlState('brake_reverse', getControllerButton(7))
        setControlState('handbrake', getControllerButton(2) >= 0.5)
    else
        -- jump on x
        setControlState('jump', getControllerButton(1) >= 0.5)

        -- sprint on circle
        setControlState('sprint', getControllerButton(2) >= 0.5)
        
        -- crouch on square
        setControlState('crouch', getControllerButton(3) >= 0.5)
    end

    -- entering vehicle on triangle
    setControlState('enter_exit', getControllerButton(4) >= 0.5)
end