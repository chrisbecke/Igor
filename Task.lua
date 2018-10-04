Task = { }

local hookEnabled = false

local running = {}
local canYield = false

-- This does the work of starting the coroutine and attaching our frame event.
function Task.Run(action)

    running[coroutine.create(action)] = true
      
    if not hookEnabled then
        hookEnabled = true
        Command.Event.Attach(
            Event.System.Update.Begin, 
            function (handle)
                canYield=true
                for task in pairs(running) do
                    if not coroutine.resume(task) then 
                        running[task] = nil 
                    end
                end
                canYield=false
            end, "Display")
    end
end

-- it should be safe to call Task.Yield from non task functions
-- it becomes a no-op
function Task.Yield()
    if canYield and Inspect.System.Watchdog() < 0.02 then
        coroutine.yield()
    end
end
