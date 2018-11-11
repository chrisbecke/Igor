local addon, lib = ...
local Inspect = lib.Inspect
local UI = lib.UI

local available = {}
local finished = {}
local working = {}

local function unexpected(adventure)
    local from = 'undefined'
    if available[adventure.id] then from = 'available' end
    if working[adventure.id] then from = 'working' end
    if finished[adventure.id] then from = 'finished' end
    local to = adventure.mode
    if not to then to = 'undefined' end
    print('Unexpected "'..adventure.name..'" mode from '..from..' to '..to)
end

local context = UI.CreateContext('MinionContext')
local smallWindow = UI.CreateFrame("SmallWindow","SmallWindow",context)
smallWindow:EnableDrag()
local closeButton = UI.CreateFrame("RiftButton","CloseButton",smallWindow)
closeButton:SetText('Scan')
local content = smallWindow:GetContent()
closeButton:SetPoint(0.5,1,content,0.5,1,0,-4)
closeButton:SetLayer(100)

local layout = {}

local nextAction = nil

layout.minionName = UI.CreateFrame("Text","MinionName",content)


local function closeMinionWindow(frame,handle)
    if nextAction then nextAction() end
end

local function showFinished()
    local id,adventure = next(finished)
    if not adventure then return false end

    nextAction = function()
        print('Claiming '..adventure.name)
        Command.Minion.Claim(adventure.id)
    end

    closeButton:SetText('Claim')
    return true
end

local function showAvailable()
    local slots = Inspect.Minion.Slot()
    for id,test in pairs(working) do
        -- print('Counting a working... '..test.name)
        slots = slots -1
    end

    if slots <= 0 then 
--        print('Giving up. '..tostring(slots)..'/'..tostring(Inspect.Minion.Slot())..' slots')
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
        --fulldump(available, 'available')
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
    local mode = adventure.mode
    local id = adventure.id

    if available[id] then
        if mode == 'working' then
            working[id] = adventure
        else
            unexpected(adventure)
        end
        available[id] = nil
    elseif working[id] then
        if mode == 'finished' then
            finished[id] = adventure
        else
            unexpected(adventure)
        end
        working[id] = nil
    elseif finished[id] then
        if mode then
            unexpected(adventure)
        end
        finished[id] = nil
    else
        if mode == 'working' then
            working[id] = adventure
        elseif mode == 'available' then
            available[id] = adventure
        elseif mode == 'finished' then
            finished[id] = adventure
        else
            unexpected(adventure)
        end
    end
end

local function deleteAdventure(id)
    if available[id] then
        print('Unexpected. Deleting available adventure! '..available[id].name)
        available[id]=nil
    end
    
    if working[id] then
        print('Unexpected. Deleting working adventure! '..working[id].name)
        working[id] = nil
    end

    if finished[id] then
        print('Unexpected. Deleting finished adventure! '..finished[id].name)
        finished[id] = nil
    end
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
end

local function listMinions(frame,handle)
    local minions = Inspect.Minion.Minion.List()
    fulldump(minions)
    for key in pairs(minions) do
        local minion = Inspect.Minion.Minion.Detail(key)
        fulldump(minion)
    end
end

nextAction = function()
    local adventures = Inspect.Minion.Adventure.List()
    adventureDidChange(handle,adventures)    
end

-- Attach event listeners to the UI
closeButton:EventAttach(Event.UI.Button.Left.Press,closeMinionWindow,"MinionClose")
-- Attach an Adventure Change listener. This drives our GUI
Command.Event.Attach(Event.Minion.Adventure.Change,adventureDidChange,"OnAdventureChange")


--[[
local listAdventuresButton = UI.CreateFrame("RiftButton","ListAdventures",smallWindow)
listAdventuresButton:SetText('Adventures')
listAdventuresButton:SetPoint("CENTERLEFT",smallWindow,"CENTERRIGHT",0,0)
listAdventuresButton:EventAttach(Event.UI.Button.Left.Press,listAdventures,"AdventureList")

local listMinionsButton = UI.CreateFrame("RiftButton","ListMinions",smallWindow)
listMinionsButton:SetText('Minions')
listMinionsButton:SetPoint("CENTERTOP",listAdventuresButton,"CENTERBOTTOM",0,0)
listMinionsButton:EventAttach(Event.UI.Button.Left.Press,listMinions,"MinionsList")
]]