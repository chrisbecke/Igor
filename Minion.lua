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
local content = smallWindow:GetContent()
local closeButton = UI.CreateFrame("RiftButton","CloseButton",content)
closeButton:SetText('Scan')
closeButton:SetPoint(0.5,1,content,0.5,1,0,-4)
closeButton:SetLayer(100)

local layout = {}

local nextAction
local updateAdventureUI

layout.minion = UI.CreateFrame("Text","MinionName",content)
layout.minion:SetText("Name!")
layout.minion:SetPoint("CENTER",content,"CENTER",0,-40)
layout.adventure = UI.CreateFrame("Text","Adventure",content)
layout.adventure:SetPoint("TOPCENTER",layout.minion,"BOTTOMCENTER")
layout.adventure:SetText("Adventure!")

layout.checkExperience = UI.CreateFrame("RiftCheckbox","Selection",content)
layout.checkExperience:SetPoint("CENTERLEFT",content,"CENTERLEFT",10,40)
layout.textExperience = UI.CreateFrame("Text","SelText",content)
layout.textExperience:SetPoint("CENTERLEFT",layout.checkExperience,"CENTERRIGHT")
layout.textExperience:SetText("Experience")
layout.checkLoot = UI.CreateFrame("RiftCheckbox","LootCheck",content)
layout.checkLoot:SetPoint("CENTERTOP",layout.checkExperience,"CENTERBOTTOM")
layout.textLoot = UI.CreateFrame("Text","LootText",content)
layout.textLoot:SetPoint("CENTERLEFT",layout.checkLoot,"CENTERRIGHT")
layout.textLoot:SetText("Items")

local function OnToggleLoot(handle)
    local val = layout.checkLoot:GetChecked()
    --layout.checkLoot:SetChecked(val)
    settings.favorLoot = val
    updateAdventureUI()
end

local function OnToggleExperience(handle)
    local val = layout.checkExperience:GetChecked()
    --layout.checkExperience:SetChecked(val)
    settings.favorExperience = val
    updateAdventureUI()
end

layout.checkExperience:EventAttach(Event.UI.Checkbox.Change,OnToggleExperience,"OnToggleExperience")
layout.checkLoot:EventAttach(Event.UI.Checkbox.Change,OnToggleExperience,"OnToggleLoot")

local function closeMinionWindow(frame,handle)
    if nextAction then nextAction() end
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
        if hasStamina and hasStat then
            list[#list+1] = minion
        end
    end
    return list
end

local function bestMinionStat(minion,stats)
    local best = 0
    for i,stat in pairs(stats) do
        if minion[stat] then
            best = best + minion[stat]
        end
    end
    return best
end

updateAdventureUI = function()
    local adventurelist = Inspect.Minion.Adventure.List()
    -- First, see if there are adventures to claim
    local adventures = Inspect.Minion.Adventure.Detail(adventurelist)
    local list = table.filter(adventures,function (id,adventure) return adventure.mode=='finished' end)
    local id,adventure = next(list)
    if id ~= nil then
        nextAction = function()
            print('Claiming '..adventure.name)
            Command.Minion.Claim(adventure.id)
        end
        local minion = Inspect.Minion.Minion.Detail(adventure.minion)
        print('Found finished adventure: '..adventure.name)
        layout.adventure:SetText(adventure.name)
        layout.minion:SetText(minion.name)
        closeButton:SetText('Claim')
        smallWindow:SetVisible(true)
        return
    end

    -- Next, check if there are slots available.
    local slots = Inspect.Minion.Slot()
    local list = table.filter(adventures,function (id,adventure) return adventure.mode=='working' end)
    local working = table.count(list)
    if working == slots then
        print('Returning. '..tostring(working).."/"..tostring(slots).." minions all working.")
        smallWindow:SetVisible(false)
        return
    end

    local checkLoot = layout.checkLoot:GetChecked()
    local checkXp = layout.checkExperience:GetChecked()

    -- prepare the minion list
    -- remove all the working minions.
    local minions = Inspect.Minion.Minion.List()
    for key,value in pairs(adventures) do
        if value.minion then
            minions[value.minion] = nil
        end
    end
    -- load the minions as a map of objects
    minions = Inspect.Minion.Minion.Detail(minions)

    adventures = table.filter(adventures, function (id,adventure)
        -- only allow available adventures
        -- make sure theyre not too long and are not costing anything
        if adventure.mode ~= 'available' or
           (adventure.costAdventurine or 0)  > 0 or
           (adventure.costCredit or 0) > 0 or
           adventure.duration >= 1*60*60
        then 
           return false
        end

        if adventure.reward == 'experience' then
            if checkLoot or not checkXp then return false end
        else
            if checkXp and not checkLoot then return false end
        end
        return true
    end)
    local id,adventure = next(adventures)

    -- get the stats of the adventure
    local stats = {}
    for key,value in pairs(adventure) do
        local stat = key:match('^stat.*$')
        if stat ~= nil then
            stats[#stats+1] = stat
        end
    end    

    minions = table.filter(minions, function (id,minion)
        if minion.level == 25 then return false end
        if minion.stamina <= adventure.costStamina then return false end
        local hasStat = false
        for i,stat in ipairs(stats) do
            if minion[stat] then hasStat = true end
        end
        return hasStat
    end)

    -- reduce the minions to a proper array so we can sort it.
    minions = table.values(minions)
    if checkXp then 
        table.sort(minions,function(a,b) return b.level > a.level end)
    else
        table.sort(minions,function(left,right)
            local a = bestMinionStat(left,stats)
            local b = bestMinionStat(right,stats)
            return b < a
        end)
    end
    local minion = minions[1]

    nextAction = function()
        print('Sending '..minion.name..'('..tostring(minion.level)..') on '..adventure.name)
        Command.Minion.Send(minion.id,adventure.id,"none")
    end
    print('Found '..adventure.name..' for '..minion.name..'('..tostring(minion.level)..')')
    layout.adventure:SetText(adventure.name)
    layout.minion:SetText(minion.name)
    closeButton:SetText('Send')
    smallWindow:SetVisible(true)
end

local function adventureDidChange(handle,adventures)
    updateAdventureUI()
end

nextAction = updateAdventureUI

-- Attach event listeners to the UI
closeButton:EventAttach(Event.UI.Button.Left.Press,closeMinionWindow,"MinionClose")
-- Attach an Adventure Change listener. This drives our GUI
Command.Event.Attach(Event.Minion.Adventure.Change,adventureDidChange,"OnAdventureChange")
