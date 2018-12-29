local toc, lib = ...

local UI = lib.UI
local Inspect = lib.Inspect

local settings = {}

local function GetFilteredMountList()
    local mounts = Inspect.Item.Mount.List()

    -- turn the mount ids {id,true} into a proper array
    local mountIds = {}
    for mountId in pairs(mounts) do
        local detail = Inspect.Item.Detail(mountId)

        local validMount = true

        if settings.Filter.mountAutoscale and not detail.mountAutoscale then
            -- print(detail.name.." doesn't autoscale")
            validMount = false
        end
        if settings.Filter.mountAquatic and not detail.mountAquatic then
            -- print(detail.name.." can't swim")
            validMount = false
        end

        if validMount then
            table.insert(mountIds, mountId)
        end
    end
    return mountIds
end


local function ChooseRandomMount()
    local mountIds = GetFilteredMountList()

    -- choose a mount. And try mount it.
    -- The plugin api provides no way to tell if a user is mounted so this
    -- will dismount. Also consumes an input event.
    if #mountIds ~= 0 then
        local chosen = math.random(#mountIds);
--        print("Choosing mount "..tostring(chosen).." of "..tostring(#mountIds))
        local chosenMountId = mountIds[chosen];
        local result = Command.Item.Mount.Use(chosenMountId)
    else
        print("Igor cannot find any mounts!")
    end
end

local function createMountaneer() 
    local mountList = Inspect.Item.Mount.List()
    local mount = next(mountList)
    -- give up if the player has no mounts
    if not mount then return end

    local context = UI.CreateContext("Console")
    local button = UI.CreateFrame("Button","Minion",context)

    button:EnableDrag(
        function()
            local left, top, right, bottom = button:GetBounds()
            settings.Position = {
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

    local obutton = button

    -- docker windows provide an expanding child storage near the edge of the screen
    local docker = UI.CreateFrame("Docker","Docker",context)
    docker:SetPoint(0.5,nil,UIParent,0,nil,settings.Position.x,nil)

    local button = UI.CreateFrame("ActionIcon","Icon1",docker)
    local mountDetails = Inspect.Item.Detail(mount)

    button:SetTexture("Rift",mountDetails.icon)
    button:EventAttach(Event.UI.Button.Left.Press,
    function()
        ChooseRandomMount()
    end,
    "Mount".."press")

    obutton:SetPoint("CENTER",UIParent,"TOPLEFT",settings.Position.x,settings.Position.y)

end

-- Wait for AddonStartupEnd before creating Mountaneer interface to ensure all savedvariables
-- are restored.
Inspect.WhenPlayerAvailabilityFull(function()
    settings = lib.Settings.Mountaneer or {
        Position = { x=0, y = 0},
    }
    if not settings.Filter then
        settings.Filter = { mountAutoscale = true, mountAquatic = true }
    end
    -- are there legacy settings?
    if Igor_Persist and Igor_Persist.Minion then
        settings.Position.x = Igor_Persist.Minion.Position.x
        settings.Position.y = Igor_Persist.Minion.Position.y
    end

    createMountaneer()
end)

-- Add our command to Igor.
lib.Command['mount'] = ChooseRandomMount