Igor.Persist.Minion = {
    Points = {}
}

Igor_Persist.Minion = {
}

local function ChooseRandomMount()
    local mounts = Inspect.Item.Mount.List()

    -- turn the mount ids {id,true} into a proper array
    local mountIds = {}
    for mountId in pairs(mounts) do
        table.insert(mountIds, mountId)
    end

    -- choose a mount. And try mount it.
    -- The plugin api provides no way to tell if a user is mounted so this
    -- will dismount. Also consumes an input event.
    if #mountIds ~= 0 then
        local chosenMountId = mountIds[math.random(#mountIds)];
        Command.Item.Mount.Use(chosenMountId)
    else
        print("Igor cannot find any mounts!")
    end
end

local context = UI.CreateContext("Console")
local button = Igor.UI.CreateFrame("Button","Minion",context)

button:EnableDrag(
    function()
        local points = button:ReadAll()
        fulldump(points,"points")
        Igor_Persist.Minion.Points = points
    end)
button:SetPoint("CENTER",UIParent,"CENTER")
button:EventAttach(Event.UI.Input.Mouse.Left.Click,
function()
    ChooseRandomMount()
end,
"Mount".."Click")

-- Add our command to Igor.
Igor.Command['mount'] = ChooseRandomMount
