Task = { }

local running = {}
local canYield = false

local function TaskDispatcher(handle)
    canYield=true
    for task in pairs(running) do
        if not coroutine.resume(task) then 
            running[task] = nil
            if table.isempty(running) then
                Command.Event.Detach(Event.System.Update.Begin, TaskDispatcher)
            end
        end
    end
    canYield=false
end

-- This does the work of starting the coroutine and attaching our frame event.
function Task.Run(action)
    if table.isempty(running) then
        Command.Event.Attach(Event.System.Update.Begin, TaskDispatcher, "TaskDispatcher")
    end
    running[coroutine.create(action)] = true
end

-- it should be safe to call Task.Yield from non task functions
-- it becomes a no-op
function Task.Yield()
    if canYield and Inspect.System.Watchdog() < 0.02 then
        coroutine.yield()
    end
end
