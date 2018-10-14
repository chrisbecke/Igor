-- Igors Minion Manager

-- Command.Minion.Send
-- Command.Minion.Claim

-- Inspect.Minion.Adventure.List
-- Inspect.Minion.Adventure.Detail
-- Inspect.Minion.Minion.Detail
-- Inspect.Minion.Minion.List
-- Inspect.Minion.Minion.Slot

-- Event.Minion.Adventure.Change
-- Event.Minion.Minion.Change

local Minion = {}


-- 'available'
-- 'working'
local function countOfAdventuresInMode(mode, adventures)
    local count = 0
    if not adventures then
        adventures = Inspect.Minion.Adventure.List()
    end

    for key in pairs(adventures) do
        if key then
            local adventure = Inspect.Minion.Adventure.Detail(key)
            if adventure.mode == mode then
                count = count + 1
            end
        end
    end
    return count
end

local function print_adventures()
    local adventures = Inspect.Minion.Adventure.List()
    -- can be dead
    if not adventures then return; end
    for key in pairs(adventures) do
        local adventure = Inspect.Minion.Adventure.Detail(key)
        print(adventure.id..' - '..tostring(adventure.mode)..' - '..adventure.name)
    end
end


local finished = {}
local available = {}
local working = {}

local function InitAdventures()
    local adventures = Inspect.Minion.Adventure.List()

    for key in pairs(adventures) do
        local detail = Inspect.Minion.Adventure.Detail(key)
        if detail.mode == 'finished' then
            finished[key] = detail
        elseif detail.mode == 'working' then
            working[key] = detail
        elseif detail.mode == 'available' then
            available[key] = detail
        end
    end

    local slots = Inspect.Minion.Slot()
    
    print("Adventures Finished: "..tostring(#finished))
    print("Adventures Working: "..tostring(#working))
    print("Adventures Available: "..tostring(#available))
    print("Active Slots: "..tostring(#finished+#working).."/"..slots)
end

-- Textures
-- minion_adventures_xxx(x,y).png.dds

local function OnAdventureChange(handle, adventures)
    for key in pairs(adventures) do
        local adventure = Inspect.Minion.Adventure.Detail(key);
        if adventure then
            print('>'..adventure.id..' - '..tostring(adventure.mode)..' - '..adventure.name)
        else
            print('>'..key..' deleted')
        end
    end
end

Command.Event.Attach(Event.Minion.Adventure.Change,OnAdventureChange,"OnAdventureChange")

local function WaitForAdventure()
    while Inspect.Minion.Slot()==nil do
        Task.Yield()
    end
end

Task.Run(
    function()
        WaitForAdventure()
        InitAdventures()
    end
)
