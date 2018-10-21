local toc, Igor = ...

Igor.Task = { }

local running = {}
local canYield = false

--
local function TaskDispatcher(handle)
    canYield=true
    for task in pairs(running) do
        if not coroutine.resume(task) then 
            running[task].done = true
            running[task] = nil
            if table.isempty(running) then
                Command.Event.Detach(Event.System.Update.Begin, TaskDispatcher)
            end
        end
    end
    canYield=false
end

-- This does the work of starting the coroutine and attaching our frame event.
function Igor.Task.Run(action)
    if table.isempty(running) then
        Command.Event.Attach(Event.System.Update.Begin, TaskDispatcher, "TaskDispatcher")
    end
    local task = { done = false }
    function task.Wait()
        while not task.done do coroutine.yield() end
    end
    function task.Then(callback)
        if false and coroutine.running() then
            while not task.done do coroutine.yield() end
            callback()
        else
            running[coroutine.create(function() 
                while not task.done do coroutine.yield() end
                callback()
            end)] = { done = false }
        end
    end

    running[coroutine.create(action)] = task
    return task
end

--
function Igor.Task.Result()
    local task = { done = true }
    function task.Wait()
    end
    function task.Then(callback)
        callback()
    end
    return task
end

-- it should be safe to call Task.Yield from non task functions
-- it becomes a no-op
function Igor.Task.Yield()
    coroutine.yield()
end
