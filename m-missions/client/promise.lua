Promise = {}
Promise.__index = Promise

-- Table to track all active promises
local activePromises = {}
local activePromisesChannel = 'default'

function Promise:new(executor)
    local obj = {
        state = 'pending',
        value = nil,
        callbacks = {},
        canceled = false -- Add a flag to check if the promise is canceled
    }
    setmetatable(obj, self)

    -- Add to the active promises table
    activePromises[activePromisesChannel] = activePromises[activePromisesChannel] or {}
    table.insert(activePromises[activePromisesChannel], obj)

    local function resolve(value)
        -- Only resolve if the promise hasn't been canceled
        if obj.state == 'pending' and not obj.canceled then
            obj.state = 'fulfilled'
            obj.value = value
            for _, callback in ipairs(obj.callbacks) do
                callback(value)
            end
        end
    end

    local function reject(reason)
        if obj.state == 'pending' and not obj.canceled then
            obj.state = 'rejected'
            obj.value = reason
        end
    end

    executor(resolve, reject)
    return obj
end

function Promise:next(onFulfilled)
    if self.state == 'fulfilled' then
        onFulfilled(self.value)
    elseif not self.canceled then
        table.insert(self.callbacks, onFulfilled)
    end
    return self
end

function await(promise)
    return coroutine.yield(promise)
end

function async(func)
    return function(...)
        local co = coroutine.create(func)

        local function step(...)
            local ok, promise = coroutine.resume(co, ...)
            if not ok or coroutine.status(co) == 'dead' then
                return
            end
            promise:next(function(result)
                step(result)
            end)
        end

        step(...)
    end
end

-- Function to cancel all current promises
function killAllPromises(channel)
    if channel then
        for _, promise in ipairs(activePromises[channel] or {}) do
            promise.canceled = true
        end
    else
        for _, promises in pairs(activePromises) do
            for _, promise in ipairs(promises) do
                promise.canceled = true
            end
        end
    end
end

function sleep(ms)
    return Promise:new(function(resolve, _)
        setTimer(resolve, ms, 1)
    end)
end

function setPromiseChannel(channel)
    activePromisesChannel = channel
end

-- -- Test example
-- local test = async(function()
--     print("hello 5")
--     await(sleep(3000))
--     print("world 5")
-- end)

-- test()

-- bindKey('o', 'down', function()
--     killAllPromises()
-- end)