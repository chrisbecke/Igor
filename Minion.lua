local addon, lib = ...
local Inspect = lib.Inspect
local UI = lib.UI


local available = {}
local finished = {}
local working = {}

local minion = {}

function minion.available(adventure)
--    print('Available: '..adventure.name)
--    fulldump(adventure,'adventure')

    available[adventure.id] = adventure
    print('Adventure: '..adventure.name..' is now available.')
end

function minion.finished(adventure)
--    print('Finished: '..adventure.name)
    --fulldump(adventure,'adventure')
    working[adventure.id] = nil
    finished[adventure.id] = adventure
    local minion = Inspect.Minion.Minion.Detail(adventure.minion)
    print('Minion '..minion.name..'has finished: '..adventure.name )
end

function minion.working(adventure)
--    print('Working: '..adventure.name)
    --fulldump(adventure,'adventure')
    available[adventure.id] = nil
    working[adventure.id] = adventure
    local minion = Inspect.Minion.Minion.Detail(adventure.minion)
    print('Minion '..minion.name..' is working on: '..adventure.name )
end

function minion.remove(adventure)
--    print('Remove: '..adventure.name)
    --fulldump(adventure,'adventure')

    if finished[adventure.id] then
        finished[adventure.id] = nil
        print('Adventure: '..adventure.name..' claimed.')
    elseif working[adventure.id] then
        working[adventure.id] = nil
        print('Adventure: '..adventure.name..' claimed. (was reset to working!?)')
    else
        print('Adventure: '..adventure.name..' being removed!? (without being finished!?)')
    end
end



local context = UI.CreateContext('MinionContext')
local smallWindow = UI.CreateFrame("SmallWindow","SmallWindow",context)
smallWindow:EnableDrag()
local closeButton = UI.CreateFrame("RiftButton","CloseButton",smallWindow)
closeButton:SetText('Close')
local content = smallWindow:GetContent()
closeButton:SetPoint(0.5,1,content,0.5,1,0,-4)
closeButton:SetLayer(100)

local listAdventuresButton = UI.CreateFrame("RiftButton","ListAdventures",smallWindow)
listAdventuresButton:SetText('Adventures')
listAdventuresButton:SetPoint("CENTERLEFT",smallWindow,"CENTERRIGHT",0,0)

local listMinionsButton = UI.CreateFrame("RiftButton","ListMinions",smallWindow)
listMinionsButton:SetText('Minions')
listMinionsButton:SetPoint("CENTERTOP",listAdventuresButton,"CENTERBOTTOM",0,0)

local layout = {}

local nextAction = nil

layout.minionName = UI.CreateFrame("Text","MinionName",content)



local function closeMinionWindow(frame,handle)
    if nextAction then nextAction() end
    -- smallWindow:SetVisible(false)
end

local function showFinished()
    local id,adventure = next(finished)
    if not adventure then return false end

    nextAction = function()
        print('Claiming... '..adventure.name)
        Command.Minion.Claim(adventure.id)
    end

    closeButton:SetText('Claim')
    return true
end

local function showAvailable()
    local slots = Inspect.Minion.Slot()
    for id,test in pairs(working) do
        print('Counting a working... '..test.name)
        slots = slots -1
    end

    if slots <= 0 then 
        print('Giving up. '..tostring(slots)..'/'..tostring(Inspect.Minion.Slot())..' slots')
        return false
    end

    local adventure = nil
    for id, test in pairs(available) do
        if test.duration >= 300 and test.duration <= 900 then
        -- if test.duration < 300 then
            adventure = test
            print('found adventure '..adventure.name)
            break
        end
    end

    if not adventure then
        print('Giving up. No 5/15 minute adventures are available!?')
        fulldump(available, 'available')
        return false
    end

    print('Finding minions for: '..adventure.name)

    -- get the list of stats so we can compare minions for matches
    local stats = {}
    for key in pairs(adventure) do
        if key:match('^stat.*$') then
            stats[key] = adventure
        end
    end

    local minions = Inspect.Minion.Minion.List()

    local matches = {}
    for key in pairs(stats) do
        for id in pairs(minions) do
            local minion = Inspect.Minion.Minion.Detail(id)
            if minion[key] and
                minion.stamina >= adventure.costStamina then
                matches[minion] = true
            end
        end
    end

    local minion = next(matches)
    for test in pairs(matches) do
        if test.level < minion.level then minion = test end
    end

    print('Selected '..minion.name)

    nextAction = function()
        print('Sending '..minion.name..' on '..adventure.name)

        Command.Minion.Send(minion.id,adventure.id)
    end

    closeButton:SetText('Send')
    return true
end

local function updateMinionUI()
    local haveUI = showFinished() or showAvailable()
    smallWindow:SetVisible(haveUI)
end



local function checkAdventure(adventure)
    if minion[adventure.mode] then
        minion[adventure.mode](adventure)
    elseif adventure.mode == nil then
        minion.remove(adventure)
    else
        print('Strange mode'..adventure.mode..' for '..adventure.name)
    end
end

local function deleteAdventure(key)
end

local function adventureDidChange(handle,adventures)
    for key in pairs(adventures) do
        local adventure = Inspect.Minion.Adventure.Detail(key);
        if adventure then
            checkAdventure(adventure)
        else
            deleteAdventure(key)
        end
    end
    updateMinionUI()
end

local function listAdventures(frame,handle)
    local slot = Inspect.Minion.Slot()
    print('Slots:'..tostring(slot))
    local adventures = Inspect.Minion.Adventure.List()
    adventureDidChange(handle,adventures)
--[[
--    fulldump(adventures)
--    for key in pairs(adventures) do
--        local adventure = Inspect.Minion.Adventure.Detail(key)
--        fulldump(adventure)
--    end
]]
end

local function listMinions(frame,handle)
    local minions = Inspect.Minion.Minion.List()
    fulldump(minions)
    for key in pairs(minions) do
        local minion = Inspect.Minion.Minion.Detail(key)
        fulldump(minion)
    end
end


listMinionsButton:EventAttach(Event.UI.Button.Left.Press,listMinions,"MinionsList")
listAdventuresButton:EventAttach(Event.UI.Button.Left.Press,listAdventures,"AdventureList")
closeButton:EventAttach(Event.UI.Button.Left.Press,closeMinionWindow,"MinionClose")
Command.Event.Attach(Event.Minion.Adventure.Change,adventureDidChange,"OnAdventureChange")