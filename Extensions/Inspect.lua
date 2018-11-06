local toc, lib = ...

local playerAvailabilityIsFull = false

local callbacks = {}
local Inspect_meta = { __index = Inspect }

lib.Inspect = {}

setmetatable(lib.Inspect,Inspect_meta)

local function didFullAvailability(handle, units)
    -- sometimes units is nil
--    if not units then return end
    -- search units to see if player is involved.
    for id, name in pairs(units) do
        if name == 'player' then
            -- call the pending callbacks
            playerAvailabilityIsFull = true
            if callbacks then 
                for callback in pairs(callbacks) do
                    callback()
                end
                callbacks = nil
            end
        end
    end
end

Command.Event.Attach(Event.Unit.Availability.Full,didFullAvailability,'didFullAvailability')

-- expose a utility function that can be used to ensure various datas are available.
function lib.Inspect.WhenPlayerAvailabilityFull(callback)
    if playerAvailabilityIsFull then
        callback()
    else
        callbacks[callback] = true
    end
end
