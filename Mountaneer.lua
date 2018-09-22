-- Add our command to Igor.
Igor.Command['mount'] = function()
    local mounts = Inspect.Item.Mount.List()

    -- turn the mount ids {id,true} into a proper array
    local mountIds = {}
    for mountId in pairs(mounts) do
        table.insert(mountIds, mountId)
    end

    -- choose a mount. And mount it.
    if #mountIds then
        local chosenMountId = mountIds[math.random(#mountIds)];
        Command.Item.Mount.Use(chosenMountId)
    else
        print("Igor cannot find any mounts!")
    end
end
