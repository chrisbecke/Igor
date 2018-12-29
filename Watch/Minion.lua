local addon, lib = ...

local summary = lib.summary
local table = lib.table

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

-- Adventure.List
-- [{ .mn.adv.5D270FE7742C66F1=true }]
--
-- Adventure.Detail
-- statArtifact
-- statAssasination = true
-- statEarth=true
-- statDimension
-- statWater
-- statLife
-- statDeath
-- statAir
-- statHunting
-- duration = 60 / 300 / 900 / 28800 / 14400
-- id='mn.adv.1F....'
-- costStamina=7
-- reward='material', 'artifact', 'dimension', 'material', 'experience', 'hunt'
-- costCredit=0
-- name='name'
-- costAdventurine=0
-- mode = nil, 'available', 'finished', 'working'
-- minion = 'mn.mn.1Cblah'

-- Minion.Detail
-- level=15
-- id='mn.mn.1C7...'
-- rarity='common'
-- stamina=15
-- experienceAccumulated=2183
-- experienceNeeded=4400
-- statLife=14
-- staminaMax=15
-- name='Ivy'
-- description=''

local function stats(adventure)
    local list = {}
    for key,value in pairs(adventure) do
        local stat = key:match('^stat(.*)$')
        if stat ~= nil then
            list[#list+1] = stat
        end
    end
    return list
end

local function listAdventure(n, adventure)
    print("Adventure #"..n..": "..adventure.name)
    print("Type: "..table.concat(stats(adventure),','))
    fulldump(adventure,"adventure")
end

local function printAdventure(n, adventure)
    print(tostring(n)..": ["..adventure.id.."] "..adventure.name.. " ("..tostring(adventure.mode)..") ")
end

local function printAdventures(adventures)
    for key,adventure in pairs(adventures) do
        print("["..adventure.id.."] "..adventure.name.. " ("..tostring(adventure.mode)..") ")
    end
end

local function OnAdventureChange(handle, adventures)
    print("Event.Minion.Adventure.Change")
    for key in pairs(adventures) do
        local adventure = Inspect.Minion.Adventure.Detail(key);
        if adventure then
            printAdventure('-',adventure)
        else
            print(key..' deleted')
        end
    end
end

Command.Event.Attach(Event.Minion.Adventure.Change,OnAdventureChange,"OnAdventureChange")

local array={}

local function listAdventures(handle,param)
    if param=='' then
        print("Listing Adventures "..tostring(param))
        local adventures = Inspect.Minion.Adventure.List();
        array={}
        local n=1;
        for key,value in pairs(adventures) do
            array[#array+1] = key
            local adventure = Inspect.Minion.Adventure.Detail(key)
            printAdventure(#array,adventure)
        end
    else
        local idx = tonumber(param)
        local key = array[idx]
        local adventure = Inspect.Minion.Adventure.Detail(key)
        listAdventure(param,adventure)
    end
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

local function minionAction(handle,param)
    local adventures = Inspect.Minion.Adventure.List()

    -- First, see if there are adventures to claim
    local details = Inspect.Minion.Adventure.Detail(adventures)
    local list = filterAdventures(details,{mode='finished'})
    local id,adventure = next(list)
    if id ~= nil then
        print('Claiming '..adventure.name)
        Command.Minion.Claim(id)
        return
    end

    -- next see if there are slots to work with
    local slots = Inspect.Minion.Slot()
    local list = filterAdventures(details,{mode='working'})
    local working = table.count(list)
    if working == slots then
        print('Returning. '..tostring(working).."/"..tostring(slots).." minions all working.")
        return
    end

    -- prepare the minion list
    local minions = Inspect.Minion.Minion.List()
    for key,value in pairs(details) do
        if value.minion then
            minions[value.minion] = nil
        end
    end

    -- try for experience missions?
    list = filterAdventures(details,{mode='available',duration=60})
    print('Searching...')
    local id,adventure = next(list)
    if id ~= nil then
        local minions = filterMinions(minions,adventure)
        if #minions then
            table.sort(minions,function(a,b) return b.level > a.level end)
            local minion = minions[1]
            print('Sending '..minion.name..' on '..adventure.name)
            Command.Minion.Send(minion.id,adventure.id,"none")
        end
    end
end

Command.Event.Attach(
    Command.Slash.Register("la"),listAdventures,
    "MinionListAdventure")

Command.Event.Attach(
    Command.Slash.Register("min"),minionAction,
    "MinionMinion")    
