local toc, Igor = ...

-- Mounts are not immediately available
function Inspect.Item.Mount.ListAsync()
    if Inspect.Item.Mount.List() then return Igor.Task.Result() end

    return Igor.Task.Run(function() 
        while not Inspect.Item.Mount.List() do
            Igor.Task.Yield()
        end
    end)
end

-- Minions are not immediately available
function Inspect.Minion.SlotAsync()
    local slot = Inspect.Minion.Slot()
    if slot then return Igor.Task.Result() end

    return Igor.Task.Run(function()
        while Inspect.Minion.Slot() do
            Igor.Task.Yield()
        end
    end)
end
