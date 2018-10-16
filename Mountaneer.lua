Igor.Persist.Minion = { }

Igor_Persist.Minion = {
    Position = {
    }
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
        local chosen = math.random(#mountIds);
--        print("Choosing mount "..tostring(chosen).." of "..tostring(#mountIds))
        local chosenMountId = mountIds[chosen];
        Command.Item.Mount.Use(chosenMountId)
    else
        print("Igor cannot find any mounts!")
    end
end

local context = UI.CreateContext("Console")
local button = Igor.UI.CreateFrame("Button","Minion",context)

button:EnableDrag(
    function()
        local left, top, right, bottom = button:GetBounds()
        Igor_Persist.Minion.Points = nil
        Igor_Persist.Minion.Position = {
            x = (right+left)/2,
            y = (bottom+top)/2
        }
    end)
button:SetPoint("CENTER",UIParent,"CENTER")
button:EventAttach(Event.UI.Button.Left.Press,
function()
    ChooseRandomMount()
end,
"Mount".."press")

Command.Event.Attach(Event.Addon.SavedVariables.Load.End,function()
    if Igor_Persist.Minion.Position.x and Igor_Persist.Minion.Position.y then
        button:SetPoint("CENTER",UIParent,"TOPLEFT",Igor_Persist.Minion.Position.x,Igor_Persist.Minion.Position.y)
    end
end,
"MountaneerVariablesDidLoad")

-- Add our command to Igor.
Igor.Command['mount'] = ChooseRandomMount
