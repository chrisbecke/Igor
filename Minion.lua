local addon, lib = ...
local Inspect = lib.Inspect
local UI = lib.UI
local table = lib.table

local settings = {

}

lib.Settings.Minion = settings

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

local function filterAdventures(details,filter)
    local list = {}
    for key,detail in pairs(details) do
        local match = true
        for filterKey,filterVal in pairs(filter) do
            if detail[filterKey] ~= filterVal then
                match = false
            end
        end
        if match then
            list[key] = detail
        end
    end
    return list
end

local function filterMinions(minions,adventure)
    local stats = {}
    for key,value in pairs(adventure) do
        local stat = key:match('^stat.*$')
        if stat ~= nil then
            stats[#stats+1] = stat
        end
    end

    local list = {}
    local details = Inspect.Minion.Minion.Detail(minions)
    for k,minion in pairs(details) do
        local hasStamina = minion.stamina >= adventure.costStamina
        local hasStat = false
        for i,stat in ipairs(stats) do
            if minion[stat] then hasStat = true end
        end
        local canLevel = minion.level < 25
        if hasStamina and hasStat and canLevel then
            list[#list+1] = minion
        end
    end
    return list
end

local function updateAdventureUI()
    local adventurelist = Inspect.Minion.Adventure.List()
    -- First, see if there are adventures to claim
    local adventures = Inspect.Minion.Adventure.Detail(adventurelist)
    local list = filterAdventures(adventures,{mode='finished'})
    local id,adventure = next(list)
    if id ~= nil then
        nextAction = function()
            print('Claiming '..adventure.name)
            Command.Minion.Claim(adventure.id)
        end
        print('Found finished adventure: '..adventure.name)
        closeButton:SetText('Claim')
        smallWindow:SetVisible(true)
        return
    end

    -- Next, check if there are slots available.
    local slots = Inspect.Minion.Slot()
    local list = filterAdventures(adventures,{mode='working'})
    local working = table.count(list)
    if working == slots then
        print('Returning. '..tostring(working).."/"..tostring(slots).." minions all working.")
        smallWindow:SetVisible(false)
        return
    end

    -- prepare the minion list
    local minions = Inspect.Minion.Minion.List()
    for key,value in pairs(adventures) do
        if value.minion then
            minions[value.minion] = nil
        end
    end

    -- try for experience missions?
    list = filterAdventures(adventures,{mode='available',duration=60})
    local id,adventure = next(list)
    if id ~= nil then
        local minions = filterMinions(minions,adventure)
        if #minions then
            table.sort(minions,function(a,b) return b.level > a.level end)
            local minion = minions[1]
            nextAction = function()
                print('Sending '..minion.name..' on '..adventure.name)
                Command.Minion.Send(minion.id,adventure.id,"none")
            end
            print('Found available adventure '..adventure.name)
            closeButton:SetText('Send')
            smallWindow:SetVisible(true)
            return
        end
    end    
    smallWindow:SetVisible(false)
end

local function adventureDidChange(handle,adventures)
    updateAdventureUI()
end

nextAction = updateAdventureUI

-- Attach event listeners to the UI
closeButton:EventAttach(Event.UI.Button.Left.Press,closeMinionWindow,"MinionClose")
-- Attach an Adventure Change listener. This drives our GUI
Command.Event.Attach(Event.Minion.Adventure.Change,adventureDidChange,"OnAdventureChange")
